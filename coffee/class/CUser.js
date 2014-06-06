var CUser,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty;

CUser = (function() {
  CUser.prototype.logGroup = 'User';

  function CUser(data) {
    this.doAction = __bind(this.doAction, this);
    this.state = false;
    this.additionalActions = {};
    this.hasHover = false;
    this.buttonLastAction = '';
    this.firstLiCssPrefix = 'm_button_action_';
    this.noneActionCss = '';
    this.els = $();
    this.buttonEls = $();
    this.init(data);
  }

  CUser.prototype.init = function(data) {
    var lastHtml, ns, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    this.id = (_ref = data.id) != null ? _ref.toString().toLowerCase() : void 0;
    this.isFantom = data.isFantom || false;
    this.number = ((_ref1 = data.number) != null ? _ref1.toString() : void 0) || '';
    if (!this.number) {
      this.invisible = true;
    }
    this.numberFormatted = ((_ref2 = data.numberFormatted) != null ? _ref2.toString() : void 0) || this.number;
    this.numberHtml = escapeHtml(this.numberFormatted);
    this.name = ((_ref3 = data.name) != null ? _ref3.toString() : void 0) || '';
    this.nameLower = this.name.toLowerCase();
    this.letter = ((_ref4 = this.name[0]) != null ? _ref4.toUpperCase() : void 0) || ((_ref5 = this.number) != null ? _ref5[0].toString().toLowerCase() : void 0);
    this.nameHtml = data.name && data.name.toString() !== this.number ? escapeHtml(data.name) : this.numberHtml;
    if (this.numberHtml === this.nameHtml) {
      this.numberHtml = '';
    }
    this.isIvr = data.isIvr;
    this.ivrName = data.ivrName;
    ns = this.nameHtml.split(/\s+/);
    if (ns.length > 1 && this.name.toString() !== this.number) {
      this.nameHtml1 = ns[0];
      this.nameHtml2 = ' ' + ns.splice(1).join(' ');
    } else {
      this.nameHtml1 = this.nameHtml;
      this.nameHtml2 = '';
    }
    lastHtml = this.elNumberHtml;
    this.elNumberHtml = this.numberHtml !== this.nameHtml ? this.numberHtml : '';
    if (this.elNumberHtml !== lastHtml && (this.el != null)) {
      this.el.find('.o_number').text(this.elNumberHtml);
    }
    if ((_ref6 = this.el) != null) {
      _ref6.find('.b_contact_title wrapword a').text(this.nameHtml);
    }
    this.avatarLink32x32 = data.avatarLink32x32 || this.defaultAvatar32 || '';
    this.defaultAvatarCss = this.avatarLink32x32 ? '' : 'm_default';
    this.departmentId = (data != null ? (_ref7 = data.numberObj) != null ? _ref7.departmentid : void 0 : void 0) && (data != null ? data.numberObj.departmentid : void 0) !== '00000000-0000-0000-0000-000000000000' ? data != null ? data.numberObj.departmentid : void 0 : this.withoutDepName;
    this.department = this.departmentId === 'www_without' ? this.langs.panel.withoutDepartment : data != null ? (_ref8 = data.numberObj) != null ? _ref8.department : void 0 : void 0;
    if (((_ref9 = data.numberObj) != null ? _ref9.state : void 0) != null) {
      this.setState(data.numberObj.state);
    } else if (data.state != null) {
      this.setState(data.state);
    } else {
      this.setState(1);
    }
    return this.loadActions();
  };

  CUser.prototype.regexps = {
    name: /\{\{name\}\}/,
    name1: /\{\{name1\}\}/,
    name2: /\{\{name2\}\}/,
    number: /\{\{number\}\}/,
    dtmf: /\{\{dtmf\}\}/,
    avatarLink32x32: /\{\{avatarLink32x32\}\}/,
    css: /\{\{css\}\}/,
    letter: /\{\{letter\}\}/
  };

  CUser.prototype.setState = function(state) {
    state = parseInt(state);
    if (state === this.state) {
      return;
    }
    this.state = state;
    this.setStateCss();
    if (this.buttonEls.length) {
      this.loadActions();
      return setTimeout((function(_this) {
        return function() {
          return _this.loadActions();
        };
      })(this), 100);
    }
  };

  CUser.prototype.setStateCss = function() {
    if (this.els.length) {
      this.els.toggleClass('m_busy', this.state === 5);
      this.els.toggleClass('m_offline', this.state === 0);
      this.els.toggleClass('m_break', this.state === 2);
      return this.els.toggleClass('m_dnd', this.state === 3);
    }
  };

  CUser.prototype.getInfo = function() {
    return '"' + this.number + '" ' + this.state + ' ' + this.name;
  };

  CUser.prototype.isFiltered = function(filter, showOffline, lang) {
    var fl;
    if ((!filter || typeof filter !== 'string') && (showOffline || (!showOffline && this.state !== 0))) {
      this.setSelection();
      return true;
    }
    if (showOffline || (!showOffline && this.state !== 0)) {
      if ((this.number && this.number.indexOf(filter) !== -1) || (' ' + this.name).toLowerCase().indexOf(filter) !== -1) {
        this.setSelection(filter);
        return true;
      }
      if (lang === 'en' && (fl = this.toRu(filter)) && (' ' + this.name).toLowerCase().indexOf(fl) !== -1) {
        this.setSelection(fl);
        return true;
      }
      if (lang === 'ru' && (fl = this.toEn(filter)) && (' ' + this.name).toLowerCase().indexOf(fl) !== -1) {
        this.setSelection(fl);
        return true;
      }
      return false;
    }
    return false;
  };

  CUser.prototype.showLetter = function(show) {
    var _ref;
    return (_ref = this.el) != null ? _ref.find('.b_capital_letter span').text(show ? this.letter : '') : void 0;
  };

  CUser.prototype.getEl = function(createIndependent) {
    var $el, str;
    if (!this.el || createIndependent) {
      str = this.template.replace(this.regexps.name1, this.nameHtml1).replace(this.regexps.name2, this.nameHtml2).replace(this.regexps.name, this.name + (this.numberHtml ? ' (' + this.numberHtml + ')' : '')).replace(this.regexps.number, this.numberHtml).replace(this.regexps.dtmf, this.langs.panel.dtmf).replace(this.regexps.avatarLink32x32, this.avatarLink32x32).replace(this.regexps.css, this.defaultAvatarCss);
      $el = $(str);
      $el.data('user', this);
      this.initButtonEl($el.find('.oktell_button_action'));
      this.els = this.els.add($el);
      this.setStateCss();
      if (!this.el) {
        this.el = $el;
        this.elName = this.el.find('.b_contact_name b');
        this.elName2 = this.el.find('.b_contact_name span');
        this.elNumber = this.el.find('.o_number');
        this.elDtmf = this.el.find('.o_dtmf');
      }
    }
    $el = $el || this.el;
    return $el;
  };

  CUser.prototype.setSelection = function(str) {
    var rx;
    if (this.el != null) {
      if (!str) {
        if (this.elHasSelection) {
          this.elName.text(this.nameHtml1);
          this.elName2.text(this.nameHtml2);
          this.elNumber.text(this.numberHtml);
          return this.elHasSelection = false;
        }
      } else {
        rx = new RegExp('(' + str + ')', 'gi');
        this.elName.html(this.nameHtml1.replace(rx, '<span class="selected_text">$1</span>'));
        this.elName2.html(this.nameHtml2.replace(rx, '<span class="selected_text">$1</span>'));
        this.elNumber.html(this.numberHtml.replace(rx, '<span class="selected_text">$1</span>'));
        return this.elHasSelection = true;
      }
    }
  };

  CUser.prototype.initButtonEl = function($el) {
    this.buttonEls = this.buttonEls.add($el);
    $el.data('user', this);
    $el.children(':first').bind('click', (function(_this) {
      return function() {
        return _this.doAction(_this.buttonLastAction);
      };
    })(this));
    if (this.buttonLastAction) {
      return $el.removeClass(this.noneActionCss).addClass(this.firstLiCssPrefix + this.buttonLastAction.toLowerCase());
    } else {
      return $el.addClass(this.noneActionCss);
    }
  };

  CUser.prototype.getButtonEl = function() {
    var $el;
    $el = $(this.buttonTemplate);
    this.initButtonEl($el);
    return $el;
  };

  CUser.prototype.isHovered = function(isHovered) {
    if (this.hasHover === isHovered) {
      return;
    }
    this.hasHover = isHovered;
    if (this.hasHover) {
      return this.loadActions(true);
    }
  };

  CUser.prototype.loadOktellActions = function() {
    var action, actions, _ref;
    if (this.isIvr) {
      actions = ['endCall'];
    } else {
      actions = this.oktell.getPhoneActions(this.number || this.id);
    }
    _ref = this.additionalActions;
    for (action in _ref) {
      if (!__hasProp.call(_ref, action)) continue;
      actions.push(action);
    }
    return actions;
  };

  CUser.prototype.addAction = function(action, callback) {
    if (action && typeof action === 'string' && typeof callback === 'function') {
      return this.additionalActions[action] = callback;
    }
  };

  CUser.prototype.removeAction = function(action) {
    return action && delete this.additionalActions[action];
  };

  CUser.prototype.loadActions = function() {
    var action, actions, _ref;
    actions = this.loadOktellActions();
    _ref = this.additionalActions;
    for (action in _ref) {
      if (!__hasProp.call(_ref, action)) continue;
      actions.push(action);
    }
    action = (actions != null ? actions[0] : void 0) || '';
    if (this.buttonLastAction === action) {
      return actions;
    }
    if (this.buttonLastAction) {
      this.buttonEls.removeClass(this.firstLiCssPrefix + this.buttonLastAction.toLowerCase());
    }
    if (action) {
      this.buttonLastAction = action;
      this.buttonEls.removeClass(this.noneActionCss).addClass(this.firstLiCssPrefix + this.buttonLastAction.toLowerCase());
    } else {
      this.buttonLastAction = '';
      this.buttonEls.addClass(this.noneActionCss);
    }
    return actions;
  };

  CUser.prototype.doAction = function(action) {
    var target, _base, _base1, _base2, _base3;
    if (!action) {
      return;
    }
    target = this.number;
    if (typeof this.beforeAction === "function") {
      this.beforeAction(action);
    }
    switch (action) {
      case 'call':
        return this.oktell.call(target);
      case 'conference':
        return this.oktell.conference(target);
      case 'intercom':
        return this.oktell.intercom(target);
      case 'transfer':
        return this.oktell.transfer(target);
      case 'toggle':
        return this.oktell.toggle();
      case 'ghostListen':
        return this.oktell.ghostListen(target);
      case 'ghostHelp':
        return this.oktell.ghostHelp(target);
      case 'ghostConference':
        return this.oktell.ghostConference(target);
      case 'endCall':
        return this.oktell.endCall(target);
      case 'hold':
        return typeof (_base = this.oktell).hold === "function" ? _base.hold() : void 0;
      case 'resume':
        return typeof (_base1 = this.oktell).resume === "function" ? _base1.resume() : void 0;
      case 'answer':
        return typeof (_base2 = this.oktell).answer === "function" ? _base2.answer() : void 0;
      default:
        return typeof (_base3 = this.additionalActions)[action] === "function" ? _base3[action]() : void 0;
    }
  };

  CUser.prototype.doLastFirstAction = function() {
    if (this.buttonLastAction) {
      this.doAction(this.buttonLastAction);
      return true;
    } else {
      return false;
    }
  };

  CUser.prototype.letterVisibility = function(show) {
    if (this.el && this.el.length) {
      if (show) {
        return this.el.find('.b_capital_letter span').text(this.letter);
      } else {
        return this.el.find('.b_capital_letter span').text('');
      }
    }
  };

  CUser.prototype.replacerToRu = {
    "q": "й",
    "w": "ц",
    "e": "у",
    "r": "к",
    "t": "е",
    "y": "н",
    "u": "г",
    "i": "ш",
    "o": "щ",
    "p": "з",
    "[": "х",
    "]": "ъ",
    "a": "ф",
    "s": "ы",
    "d": "в",
    "f": "а",
    "g": "п",
    "h": "р",
    "j": "о",
    "k": "л",
    "l": "д",
    ";": "ж",
    "'": "э",
    "z": "я",
    "x": "ч",
    "c": "с",
    "v": "м",
    "b": "и",
    "n": "т",
    "m": "ь",
    ",": "б",
    ".": "ю",
    "/": "."
  };

  CUser.prototype.replacerToEn = {
    "й": "q",
    "ц": "w",
    "у": "e",
    "к": "r",
    "е": "t",
    "н": "y",
    "г": "u",
    "ш": "i",
    "щ": "o",
    "з": "p",
    "х": "[",
    "ъ": "]",
    "ф": "a",
    "ы": "s",
    "в": "d",
    "а": "f",
    "п": "g",
    "р": "h",
    "о": "j",
    "л": "k",
    "д": "l",
    "ж": ";",
    "э": "'",
    "я": "z",
    "ч": "x",
    "с": "c",
    "м": "v",
    "и": "b",
    "т": "n",
    "ь": "m",
    "б": ",",
    "ю": ".",
    ".": "/"
  };

  CUser.prototype.toRu = function(str) {
    return str.replace(/[A-z\/,.;\'\]\[]/g, (function(_this) {
      return function(x) {
        if (x === x.toLowerCase()) {
          return _this.replacerToRu[x];
        } else {
          return _this.replacerToRu[x.toLowerCase()].toUpperCase();
        }
      };
    })(this));
  };

  CUser.prototype.toEn = function(str) {
    return str.replace(/[А-яёЁ]/g, (function(_this) {
      return function(x) {
        if (x === x.toLowerCase()) {
          return _this.replacerToEn[x];
        } else {
          return _this.replacerToEn[x.toLowerCase()].toUpperCase();
        }
      };
    })(this));
  };

  return CUser;

})();