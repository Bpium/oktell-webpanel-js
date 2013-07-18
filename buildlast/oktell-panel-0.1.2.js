/* Oktell-panel.js 0.1.2 http://js.oktell.ru/webpanel */

var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __slice = [].slice,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty;

(function($) {
  var CUser, Department, Error, List, Notify, PermissionsPopup, Popup, actionButtonContainerClass, actionButtonHtml, actionListEl, actionListHtml, addActionButtonToEl, afterOktellConnect, cookie, debounce, defaultOptions, departmentTemplateHtml, error, errorHtml, escapeHtml, getOptions, hasTouch, initActionButtons, initButtonOnElement, initPanel, isAndroid, isIDevice, isTouchPad, jScroll, langs, list, loadTemplate, log, logStr, newGuid, oktell, oktellConnected, options, panelHtml, panelWasInitialized, permissionsPopup, permissionsPopupHtml, popup, popupHtml, templates, userTemplateHtml, usersTableHtml,
    _this = this;

  if (!$) {
    throw new Error('Error init oktell panel, jQuery ( $ ) is not defined');
  }
  debounce = function(func, wait, immediate) {
    var timeout;

    timeout = '';
    return function() {
      var args, callNow, context, later, result;

      context = this;
      args = arguments;
      later = function() {
        var result;

        timeout = null;
        if (!immediate) {
          return result = func.apply(context, args);
        }
      };
      callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) {
        result = func.apply(context, args);
      }
      return result;
    };
  };
  escapeHtml = function(string) {
    return ('' + string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g, '&#x2F;');
  };
  log = function() {
    var e;

    try {
      return console.log.apply(console, arguments);
    } catch (_error) {
      e = _error;
    }
  };
  cookie = function(key, value, options) {
    var decode, result, seconds, t;

    if (arguments.length > 1 && String(value) !== "[object Object]") {
      options = $.extend({}, options);
      if (value == null) {
        options.expires = -1;
      }
      if (typeof options.expires === 'number') {
        seconds = options.expires;
        t = options.expires = new Date();
        t.setSeconds(t.getSeconds() + seconds);
      }
      value = String(value);
      return document.cookie = [encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value), options.expires ? '; expires=' + options.expires.toUTCString() : '', options.path ? '; path=' + options.path : '', options.domain ? '; domain=' + options.domain : '', options.secure ? '; secure' : ''].join('');
    }
    options = value || {};
    result = '';
    if (options.raw) {
      decode = function(s) {
        return s;
      };
    } else {
      decode = decodeURIComponent;
    }
    if ((result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie))) {
      return decode(result[1]);
    } else {
      return null;
    }
  };
  newGuid = function() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r, v;

      r = Math.random() * 16 | 0;
      v = c === 'x' ? r : r & 0x3 | 0x8;
      return v.toString(16);
    });
  };
  jScroll = function($el) {
    var END_EVENT, MOVE_EVENT, START_EVENT, WHEEL_EV, get_koef, get_pageY, get_position, init, isTouch, jscroll_timer, move_by_bar, pageY_end, pageY_start, params, pos, pos_start, scrollClick, scrollTo, scrollWheelPos, scroll_hide, scroll_show, scrollbar_cont, scrollbar_inner, scroller, scroller_left_while_scrolling, scrolling, set_bar_bounds, set_position, vendor, wrapper,
      _this = this;

    wrapper = '';
    scroller = '';
    scrollbar_cont = '';
    scrollbar_inner = '';
    scroller_left_while_scrolling = '';
    move_by_bar = '';
    pageY_end = '';
    pageY_start = '';
    pos = '';
    pos_start = '';
    scrolling = '';
    params = {};
    scrollWheelPos = function(e, wrapper, scroller, scrollbar_cont, scrollbar_inner) {
      var wheelDeltaY;

      e = e.originalEvent;
      wheelDeltaY = e.detail ? e.detail * (-14) : e.wheelDelta / 3;
      pos_start = get_position(scroller);
      pageY_end = get_pageY(e);
      if (pos_start >= 0 && wheelDeltaY > 0 || (pos_start + wheelDeltaY) > 0) {
        wheelDeltaY = 0;
        pos_start = 0;
      }
      if ((pos_start <= (wrapper.height() - scroller.height())) && wheelDeltaY < 0 || (pos_start + wheelDeltaY) < wrapper.height() - scroller.height()) {
        pos_start = wrapper.height() - scroller.height();
        wheelDeltaY = 0;
      }
      pos = pos_start + wheelDeltaY;
      return pos;
    };
    scrollClick = function(e, wrapper, scroller, scrollbar_cont, scrollbar_inner) {
      var koef_bar, max_pos;

      if (e.type === START_EVENT) {
        if (params.noMoveMouse) {
          return;
        }
        pageY_start = get_pageY(e);
        pos_start = get_position(scroller);
        scrolling = true;
        return $('body').css({
          '-moz-user-select': 'none',
          '-ms-user-select': 'none',
          '-khtml-user-select': 'none',
          '-webkit-user-select': 'none',
          '-webkit-touch-callout': 'none',
          'user-select': 'none'
        });
      } else if (e.type === MOVE_EVENT) {
        if (!scrolling) {
          return;
        }
        if (isTouch) {
          scroll_show(scrollbar_inner);
        }
        koef_bar = get_koef(wrapper, scroller);
        pageY_end = get_pageY(e);
        if (move_by_bar) {
          pos = pos_start * koef_bar - (pageY_end - pageY_start);
          pos = pos / koef_bar;
        } else {
          pos = pos_start + (pageY_end - pageY_start);
        }
        if (pos >= 0) {
          pos_start = get_position(scroller);
          pageY_start = pageY_end;
          pos = 0;
        }
        max_pos = wrapper.height() - scroller.height();
        if (pos <= max_pos) {
          pos_start = get_position(scroller);
          pageY_start = pageY_end;
          pos = max_pos;
        }
        scrollTo(pos, wrapper, scroller, scrollbar_cont, scrollbar_inner);
        return params.noMoveMouse = true;
      } else if (e.type === END_EVENT) {
        if (!scrolling) {
          return;
        }
        scrolling = false;
        move_by_bar = false;
        if (isTouch) {
          scroll_hide(scrollbar_inner);
        }
        $('body').css({
          '-moz-user-select': '',
          '-ms-user-select': '',
          '-khtml-user-select': '',
          '-webkit-user-select': '',
          '-webkit-touch-callout': '',
          'user-select': ''
        });
        if (scroller_left_while_scrolling) {
          return scroll_hide(scrollbar_inner);
        }
      } else {

      }
    };
    scrollTo = function(posTop, wrapper, scroller, scrollbar_cont, scrollbar_inner) {
      scroll_show(scrollbar_inner);
      set_position(scroller, posTop);
      return set_bar_bounds(wrapper, scroller, scrollbar_cont, scrollbar_inner);
    };
    get_pageY = function(e) {
      if (isTouch) {
        return e.originalEvent.targetTouches[0].clientY;
      } else {
        return e.clientY;
      }
    };
    set_position = function(object, pos) {
      return object.css({
        'position': 'relative',
        'top': pos
      });
    };
    get_position = function(object) {
      var position;

      position = object.css('top');
      if (position === 'auto') {
        position = 0;
      }
      return parseInt(position);
    };
    get_koef = function(wrapper, scroller) {
      var koef, s_height, w_height;

      w_height = wrapper.height();
      s_height = scroller.height();
      koef = w_height / s_height;
      return koef;
    };
    scroll_show = function(scrollbar_inner) {
      scrollbar_inner.stop(true, true);
      return scrollbar_inner.fadeIn(100);
    };
    scroll_hide = function(scrollbar_inner) {
      scrollbar_inner.stop(true, true);
      return scrollbar_inner.fadeOut("slow");
    };
    set_bar_bounds = function(wrapper, scroller, scrollbar_cont, scrollbar_inner) {
      var c_height, inner_height, koef, pos_koef, scroller_height, scroller_position, visibility, wrapper_height;

      c_height = scrollbar_cont.height();
      koef = get_koef(wrapper, scroller);
      inner_height = c_height * koef;
      if (koef >= 1) {
        visibility = 'hidden';
      } else {
        visibility = 'visible';
      }
      scrollbar_inner.css({
        'height': inner_height,
        'visibility': visibility
      });
      scroller_position = get_position(scroller);
      wrapper_height = wrapper.height();
      scroller_height = scroller.height();
      if (scroller_position <= 0 && scroller_position <= (wrapper_height - scroller_height)) {
        pos = wrapper_height - scroller_height;
        pos = Math.min(pos, 0);
        set_position(scroller, pos);
      }
      pos_koef = scroller_position / wrapper_height;
      pos = wrapper_height * pos_koef;
      set_position(scrollbar_inner, pos * koef * -1);
      return params != null ? typeof params.onScroll === "function" ? params.onScroll({
        wrapper: wrapper,
        scroller: scroller,
        position: scroller_position,
        length: scroller_height
      }) : void 0 : void 0;
    };
    scrolling = false;
    move_by_bar = false;
    vendor = /webkit/i.test(navigator.appVersion) ? 'webkit' : /firefox/i.test(navigator.userAgent) ? 'Moz' : __indexOf.call(window, 'opera') >= 0 ? 'O' : '';
    isTouch = typeof window['ontouchstart'] !== 'undefined';
    START_EVENT = isTouch ? 'touchstart' : 'mousedown';
    MOVE_EVENT = isTouch ? 'touchmove' : 'mousemove';
    END_EVENT = isTouch ? 'touchend' : 'mouseup';
    WHEEL_EV = vendor === 'Moz' ? 'DOMMouseScroll' : 'mousewheel';
    if (!isTouch && $('.jscroll_wrapper', $el).size()) {
      return;
    }
    init = function() {
      var scrollbar_bar;

      $el.wrapInner('<div class="jscroll_wrapper" />');
      wrapper = $(".jscroll_wrapper", $el);
      wrapper.attr("id", "jscroll_id" + Math.round(Math.random() * 10000000));
      scroller = wrapper.wrapInner('<div class="jscroll_scroller" />');
      scroller = $(".jscroll_scroller", wrapper);
      scrollbar_cont = $('<div class="jscroll_scrollbar_cont"></div>').insertAfter(scroller);
      scrollbar_cont.css({
        'position': 'absolute',
        'right': '0px',
        'width': '13px',
        'top': '3px',
        'bottom': '6px'
      });
      scrollbar_inner = $('<div class="jscroll_scrollbar_inner"></div>').appendTo(scrollbar_cont);
      scrollbar_inner.css({
        'position': 'relative',
        'width': '100%',
        'display': 'none',
        'opacity': '0.4',
        'cursor': 'pointer'
      });
      scrollbar_bar = $('<div class="jscroll_scrollbar_bar"></div>').appendTo(scrollbar_inner);
      scrollbar_bar.css({
        'position': 'relative',
        'background': 'black',
        'width': '5px',
        'margin': '0 auto',
        'border-radius': '3px',
        'height': '100%',
        '-webkit-border-radius': '3px'
      });
      wrapper.css({
        "position": "relative",
        "height": "100%",
        "overflow": "hidden"
      });
      scroller.css({
        "min-height": "100%",
        "overflow": "hidden"
      });
      return set_bar_bounds(wrapper, scroller, scrollbar_cont, scrollbar_inner);
    };
    init();
    if (isTouch) {
      return;
    }
    jscroll_timer = new Array;
    wrapper.bind('resize', function(e) {
      var timer_id;

      timer_id = wrapper.attr('id');
      if (typeof jscroll_timer[timer_id] !== 'undefined') {
        clearTimeout(jscroll_timer[timer_id]);
      }
      jscroll_timer[timer_id] = setTimeout(function() {
        set_bar_bounds(wrapper, scroller, scrollbar_cont, scrollbar_inner);
        return delete jscroll_timer[timer_id];
      }, 100);
    });
    if (!isTouch) {
      wrapper.hover(function() {
        scroller_left_while_scrolling = false;
        set_bar_bounds(wrapper, scroller, scrollbar_cont, scrollbar_inner);
        scroll_show(scrollbar_inner);
      }, function() {
        scroller_left_while_scrolling = true;
        if (scrolling) {
          return;
        }
        scroll_hide(scrollbar_inner);
      });
    }
    scrollbar_inner.bind(START_EVENT, function(e) {
      move_by_bar = true;
      params.noMoveMouse = false;
      return true;
    });
    wrapper.bind(START_EVENT, function(e) {
      scrollClick(e, wrapper, scroller, scrollbar_cont, scrollbar_inner);
      return true;
    });
    $(document).bind(MOVE_EVENT, function(e) {
      scrollClick(e, wrapper, scroller, scrollbar_cont, scrollbar_inner);
      return true;
    });
    $(document).bind(END_EVENT, function(e) {
      scrollClick(e, wrapper, scroller, scrollbar_cont, scrollbar_inner);
      return true;
    });
    return wrapper.on(WHEEL_EV, function(e) {
      var wheelPos;

      wheelPos = scrollWheelPos(e, wrapper, scroller, scrollbar_cont, scrollbar_inner);
      scrollTo(wheelPos, wrapper, scroller, scrollbar_cont, scrollbar_inner);
      return false;
    });
  };
  Notify = (function() {
    function Notify(title, autoHide, message, group, onClick) {
      var notify,
        _this = this;

      if (autoHide == null) {
        autoHide = 0;
      }
      if (!(typeof title === 'string' && title) || window.webkitNotifications.checkPermission() !== 0) {
        return;
      }
      if (typeof message === 'function') {
        onClick = message;
        message = '';
        group = null;
      } else if (typeof group === 'function') {
        onClick = group;
        group = null;
      }
      notify = window.webkitNotifications.createNotification('favicon.ico', title, message || '');
      if (group) {
        notify.tag = group;
      }
      notify.show();
      autoHide = parseInt(autoHide);
      if (autoHide) {
        setTimeout(function() {
          return notify.close();
        }, autoHide * 1000);
      }
      notify.onclick = function() {
        var args, e;

        e = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (typeof window.focus === "function") {
          window.focus();
        }
        notify.close();
        if (typeof onClick === 'function') {
          return onClick.apply(window, []);
        }
      };
      this.close = function() {
        return notify != null ? typeof notify.close === "function" ? notify.close() : void 0 : void 0;
      };
    }

    return Notify;

  })();
  Department = (function() {
    Department.prototype.logGroup = 'Department';

    function Department(id, name) {
      this.usersVisibilityCss = 'invisibleDep';
      this.lastFilteredUsers = [];
      this.isSorted = false;
      this.visible = true;
      this.users = [];
      this.id = id && id !== '00000000-0000-0000-0000-000000000000' ? id : this.withoutDepName;
      this.name = this.id === this.withoutDepName || !name ? this.langs.panel.withoutDepartment : name;
      this.isOpen = this.config().departmentVisibility[this.id] != null ? this.config().departmentVisibility[this.id] : true;
    }

    Department.prototype.getEl = function(usersVisible) {
      var _this = this;

      if (!this.el) {
        this.el = $(this.template.replace(/\{\{department}\}/g, escapeHtml(this.name)));
        this.el.find('.b_department_header').bind('click', function() {
          return _this.showUsers();
        });
      }
      if (usersVisible) {
        this._oldIsOpen = this.isOpen;
        this.showUsers(true, true);
      } else {
        this.showUsers(this._oldIsOpen != null ? this._oldIsOpen : this.isOpen);
      }
      return this.el;
    };

    Department.prototype.getContainer = function() {
      return this.el.find('tbody');
    };

    Department.prototype.showUsers = function(val, notSave) {
      var c;

      if (typeof val === 'undefined') {
        val = !this.isOpen;
      }
      if (!this.hideEl) {
        this.hideEl = this.el.find('table');
      }
      this.hideEl.stop(true, true);
      if (!notSave) {
        this.isOpen = val;
        c = this.config();
        c.departmentVisibility[this.id] = this.isOpen;
        this.config(c);
      }
      if (val) {
        this.el.toggleClass(this.usersVisibilityCss, false);
        return this.hideEl.show();
      } else {
        this.el.toggleClass(this.usersVisibilityCss, true);
        return this.hideEl.hide();
      }
    };

    Department.prototype.getInfo = function() {
      return this.name + ' ' + this.id;
    };

    Department.prototype.clearUsers = function() {
      return this.users = [];
    };

    Department.prototype.show = function(withAnimation) {
      if (!this.el || this.visible) {
        return;
      }
      if (withAnimation) {
        this.el.slideDown(200);
      } else {
        this.el.show();
      }
      return this.visible = true;
    };

    Department.prototype.hide = function(withAnimation) {
      if (!this.el || !this.visible) {
        return;
      }
      if (withAnimation) {
        this.el.slideUp(200);
      } else {
        this.el.hide();
      }
      return this.visible = false;
    };

    Department.prototype.getUsers = function(filter, showOffline, filterLang) {
      var exactMatch, u, users, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

      if (!this.isSorted) {
        this.sortUsers();
      }
      users = [];
      exactMatch = false;
      if (filter === '') {
        if (showOffline) {
          _ref = this.users;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            u = _ref[_i];
            u.setSelection();
            users.push(u);
          }
        } else {
          _ref1 = this.users;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            u = _ref1[_j];
            if (u.state !== 0) {
              u.setSelection();
              users.push(u);
            }
          }
        }
      } else {
        _ref2 = this.users;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          u = _ref2[_k];
          if (u.isFiltered(filter, showOffline, filterLang)) {
            users.push(u);
            if (u.number === filter && !exactMatch) {
              exactMatch = u;
            }
          }
        }
      }
      this.lastFilteredUsers = users;
      return [users, exactMatch];
    };

    Department.prototype.sortUsers = function() {
      return this.users.sort(this.sortFn);
    };

    Department.prototype.sortFn = function(a, b) {
      if (a.nameLower > b.nameLower) {
        return 1;
      } else if (a.nameLower < b.nameLower) {
        return -1;
      } else {
        if (a.number > b.number) {
          return 1;
        } else if (a.number < b.number) {
          return -1;
        } else {
          return 0;
        }
      }
    };

    Department.prototype.addUser = function(user) {
      if (user.number) {
        return this.users.push(user);
      }
    };

    return Department;

  })();
  CUser = (function() {
    CUser.prototype.logGroup = 'User';

    function CUser(data) {
      this.doAction = __bind(this.doAction, this);      this.state = false;
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
      ns = this.nameHtml.split(/\s+/);
      if (ns.length > 1 && data.name.toString() !== this.number) {
        this.nameHtml1 = ns[0];
        this.nameHtml2 = ' ' + ns.splice(1).join('');
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
      name1: /\{\{name1\}\}/,
      name2: /\{\{name2\}\}/,
      number: /\{\{number\}\}/,
      avatarLink32x32: /\{\{avatarLink32x32\}\}/,
      css: /\{\{css\}\}/,
      letter: /\{\{letter\}\}/
    };

    CUser.prototype.setState = function(state) {
      var _this = this;

      state = parseInt(state);
      if (state === this.state) {
        return;
      }
      this.state = state;
      this.setStateCss();
      if (this.buttonEls.length) {
        this.loadActions();
        return setTimeout(function() {
          return _this.loadActions();
        }, 100);
      }
    };

    CUser.prototype.setStateCss = function() {
      if (this.els.length) {
        if (this.state === 0) {
          return this.els.removeClass('m_busy').addClass('m_offline');
        } else if (this.state === 5) {
          return this.els.removeClass('m_offline').addClass('m_busy');
        } else {
          return this.els.removeClass('m_offline').removeClass('m_busy');
        }
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
        str = this.template.replace(this.regexps.name1, this.nameHtml1).replace(this.regexps.name2, this.nameHtml2).replace(this.regexps.number, this.numberHtml).replace(this.regexps.avatarLink32x32, this.avatarLink32x32).replace(this.regexps.css, this.defaultAvatarCss);
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
      var _this = this;

      this.buttonEls = this.buttonEls.add($el);
      $el.data('user', this);
      $el.children(':first').bind('click', function() {
        return _this.doAction(_this.buttonLastAction);
      });
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
      var actions;

      actions = this.oktell.getPhoneActions(this.id || this.number);
      return actions;
    };

    CUser.prototype.loadActions = function() {
      var action, actions;

      actions = this.loadOktellActions();
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
      var target, _base, _base1, _base2;

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
      var _this = this;

      return str.replace(/[A-z\/,.;\'\]\[]/g, function(x) {
        if (x === x.toLowerCase()) {
          return _this.replacerToRu[x];
        } else {
          return _this.replacerToRu[x.toLowerCase()].toUpperCase();
        }
      });
    };

    CUser.prototype.toEn = function(str) {
      var _this = this;

      return str.replace(/[А-яёЁ]/g, function(x) {
        if (x === x.toLowerCase()) {
          return _this.replacerToEn[x];
        } else {
          return _this.replacerToEn[x.toLowerCase()].toUpperCase();
        }
      });
    };

    return CUser;

  })();
  List = (function() {
    List.prototype.logGroup = 'List';

    function List(oktell, panelEl, dropdownEl, afterOktellConnect, options, debugMode) {
      this.onPbxNumberStateChange = __bind(this.onPbxNumberStateChange, this);
      var debouncedSetFilter, debouncedSetHeight, dropdownHideTimer, oktellConnected, ringNotify, self,
        _this = this;

      this.defaultConfig = {
        departmentVisibility: {},
        showDeps: true,
        showOffline: false
      };
      this.allActions = {
        answer: {
          icon: '/img/icons/action/call.png',
          iconWhite: '/img/icons/action/white/call.png',
          text: this.langs.actions.answer
        },
        call: {
          icon: '/img/icons/action/call.png',
          iconWhite: '/img/icons/action/white/call.png',
          text: this.langs.actions.call
        },
        conference: {
          icon: '/img/icons/action/confinvite.png',
          iconWhite: '/img/icons/action/white/confinvite.png',
          text: this.langs.actions.conference
        },
        transfer: {
          icon: '/img/icons/action/transfer.png',
          text: this.langs.actions.transfer
        },
        toggle: {
          icon: '/img/icons/action/toggle.png',
          text: this.langs.actions.toggle
        },
        intercom: {
          icon: '/img/icons/action/intercom.png',
          text: this.langs.actions.intercom
        },
        endCall: {
          icon: '/img/icons/action/endcall.png',
          iconWhite: '/img/icons/action/white/endcall.png',
          text: this.langs.actions.endCall
        },
        ghostListen: {
          icon: '/img/icons/action/ghost_monitor.png',
          text: this.langs.actions.ghostListen
        },
        ghostHelp: {
          icon: '/img/icons/action/ghost_help.png',
          text: this.langs.actions.ghostHelp
        },
        hold: {
          icon: '/img/icons/action/ghost_help.png',
          text: this.langs.actions.hold
        },
        resume: {
          icon: '/img/icons/action/ghost_help.png',
          text: this.langs.actions.resume
        }
      };
      this.actionCssPrefix = 'i_';
      this.lastDropdownUser = false;
      self = this;
      CUser.prototype.beforeAction = function(action) {
        return self.beforeUserAction(this, action);
      };
      this.departments = [];
      this.departmentsById = {};
      this.simpleListEl = $(this.usersTableTemplate);
      this.filterFantomUserNumber = false;
      this.userWithGeneratedButtons = {};
      this.debugMode = debugMode;
      this.dropdownPaddingBottomLeft = 3;
      this.dropdownOpenedOnPanel = false;
      this.regexps = {
        actionText: /\{\{actionText\}\}/,
        action: /\{\{action\}\}/,
        css: /\{\{css\}\}/,
        dep: /\{\{department}\}/g
      };
      oktellConnected = false;
      this.options = options;
      this.usersByNumber = {};
      this.me = false;
      this.oktell = oktell;
      this.panelUsers = [];
      this.panelUsersFiltered = [];
      this.abonents = {};
      this.hold = {};
      this.queue = {};
      this.oktell = oktell;
      CUser.prototype.oktell = oktell;
      this.filter = false;
      this.panelEl = panelEl;
      this.dropdownEl = dropdownEl;
      this.dropdownElLiTemplate = this.dropdownEl.html();
      this.dropdownEl.empty();
      this.keypadEl = this.panelEl.find('.j_phone_keypad');
      this.keypadIsVisible = false;
      this.usersListBlockEl = this.panelEl.find('.j_main_list');
      this.usersListEl = this.simpleListEl.find('tbody');
      this.abonentsListBlock = this.panelEl.find('.j_abonents');
      this.abonentsListEl = this.abonentsListBlock.find('tbody');
      this.abonentsHeaderTextEl = this.abonentsListBlock.find('b_marks_label');
      this.talkTimeEl = this.abonentsListBlock.find('.b_marks_time');
      this.holdBlockEl = this.panelEl.find('.j_hold');
      this.holdListEl = this.holdBlockEl.find('tbody');
      this.queueBlockEl = this.panelEl.find('.j_queue');
      this.queueListEl = this.queueBlockEl.find('tbody');
      this.filterInput = this.panelEl.find('input');
      this.filterClearCross = this.panelEl.find('.jInputClear_close');
      debouncedSetFilter = false;
      this.buttonShowOffline = this.panelEl.find('.b_list_filter .i_online');
      this.buttonShowDeps = this.panelEl.find('.b_list_filter .i_group');
      this.buttonShowOffline.bind('click', function() {
        _this.config({
          showOffline: !_this.showOffline
        });
        return _this.setFilter(_this.filter, true);
      });
      this.buttonShowDeps.bind('click', function() {
        _this.config({
          showDeps: !_this.showDeps
        });
        return _this.setFilter(_this.filter, true);
      });
      this.usersWithBeforeConnectButtons = [];
      this.config();
      Department.prototype.config = function() {
        var args;

        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.config.apply(_this, args);
      };
      this.allUserDep = new Department('all_user_dep', 'allUsers');
      this.allUserDep.template = this.usersTableTemplate;
      this.exactMatchUserDep = new Department('exact_match_user_dep', 'exactUser');
      this.exactMatchUserDep.template = this.usersTableTemplate;
      this.userScrollerToTop = function() {
        if (!_this._jScrolled) {
          _this.jScroll(_this.usersListBlockEl);
          _this.usersScroller = _this.usersListBlockEl.find('.jscroll_scroller');
        }
        return _this.usersScroller.css({
          top: '0px'
        });
      };
      this.filterClearCross.bind('click', function() {
        return _this.clearFilter();
      });
      this.filterInput.bind('keyup', function(e) {
        if (!_this.oktellConnected) {
          return true;
        }
        if (!debouncedSetFilter) {
          debouncedSetFilter = debounce(function() {
            return _this.setFilter(_this.filterInput.val().toString().toLowerCase());
          }, 100);
        }
        if (_this.filterInput.val()) {
          _this.filterClearCross.show();
        } else {
          _this.filterClearCross.hide();
        }
        if (e.keyCode === 13) {
          _this.filterInput.blur();
          setTimeout(function() {
            var _ref;

            if ((_ref = _this.usersListBlockEl.find('tr:first').data('user')) != null) {
              _ref.doLastFirstAction();
            }
            return _this.clearFilter();
          }, 50);
        } else {
          debouncedSetFilter();
        }
        return true;
      });
      this.panelEl.bind('click', function(e) {
        var actionButton, buttonEl, target, user;

        target = $(e.target);
        if (target.is('.oktell_button_action .g_first')) {
          actionButton = target.parent();
        } else if (target.is('.oktell_button_action .g_first i')) {
          actionButton = target.parent().parent();
        } else if (target.is('.b_contact .drop_down')) {
          buttonEl = target.parent();
        } else if (target.is('.b_contact .drop_down i')) {
          buttonEl = target.parent().parent();
        }
        if (((actionButton == null) && (buttonEl == null)) || (actionButton && actionButton.size() === 0) || (buttonEl && buttonEl.size() === 0)) {
          return true;
        }
        if ((actionButton != null) && actionButton.size()) {
          return true;
        }
        if ((buttonEl != null) && buttonEl.size()) {
          user = buttonEl.data('user');
          if (user) {
            _this.showDropdown(user, buttonEl, user.loadOktellActions(), true);
          }
          return true;
        }
      });
      this.dropdownEl.bind('click', function(e) {
        var action, actionEl, target, user;

        target = $(e.target);
        if (target.is('[data-action]')) {
          actionEl = target;
        } else if (target.closest('[data-action]').size() !== 0) {
          actionEl = target.closest('[data-action]');
        } else {
          return true;
        }
        action = actionEl.data('action');
        if (!action) {
          return;
        }
        user = _this.dropdownEl.data('user');
        if (action && user) {
          user.doAction(action);
        }
        return _this.dropdownEl.hide();
      });
      dropdownHideTimer = '';
      this.dropdownEl.hover(function() {
        return clearTimeout(dropdownHideTimer);
      }, function() {
        return dropdownHideTimer = setTimeout(function() {
          return _this.hideActionListDropdown();
        }, 500);
      });
      this.panelEl.find('.j_keypad_expand').bind('click', function() {
        _this.toggleKeypadVisibility();
        return _this.filterInput.focus();
      });
      this.keypadEl.find('li').bind('click', function(e) {
        _this.filterInput.focus();
        _this.filterInput.val(_this.filterInput.val() + $(e.currentTarget).find('button').data('num'));
        return _this.filterInput.keyup();
      });
      this.setUserListHeight = function() {
        var h;

        h = $(window).height() - _this.usersListBlockEl[0].offsetTop - 5 + 'px';
        return _this.usersListBlockEl.css({
          height: h
        });
      };
      this.setUserListHeight();
      debouncedSetHeight = debounce(function() {
        _this.userScrollerToTop();
        return _this.setUserListHeight();
      }, 50);
      $(window).bind('resize', function() {
        return debouncedSetHeight();
      });
      this.hidePanel(true);
      oktell.on('disconnect', function() {
        var phone, user, _ref, _results;

        if (_this.options.hideOnDisconnect) {
          _this.hidePanel();
        }
        _this.oktellConnected = false;
        _this.usersByNumber = {};
        _this.panelUsers = [];
        _this.setPanelUsersHtml([]);
        _this.setAbonents([]);
        _this.setHold({
          hasHold: false
        });
        _this.filterInput.val('');
        _this.setFilter('', true);
        _this.setQueue([]);
        _ref = _this.userWithGeneratedButtons;
        _results = [];
        for (phone in _ref) {
          user = _ref[phone];
          _results.push(user.loadActions());
        }
        return _results;
      });
      oktell.on('connect', function() {
        var createdDeps, dep, id, numObj, number, oId, oInfo, oNumbers, oUser, oUsers, otherDep, strNumber, user, _i, _len, _ref, _ref1, _ref2;

        _this.oktellConnected = true;
        oInfo = oktell.getMyInfo();
        oInfo.userid = oInfo.userid.toString().toLowerCase();
        _this.myNumber = (_ref = oInfo.number) != null ? _ref.toString() : void 0;
        CUser.prototype.defaultAvatar = oInfo.defaultAvatar;
        CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32;
        CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64;
        _this.departments = [];
        _this.departmentsById = {};
        createdDeps = {};
        otherDep = new Department();
        oUsers = oktell.getUsers();
        oNumbers = oktell.getNumbers();
        for (id in oUsers) {
          if (!__hasProp.call(oUsers, id)) continue;
          user = oUsers[id];
          delete oNumbers[user.number];
        }
        for (number in oNumbers) {
          if (!__hasProp.call(oNumbers, number)) continue;
          numObj = oNumbers[number];
          id = newGuid();
          oUsers[id] = {
            id: id,
            number: number,
            name: numObj.caption,
            numberObj: numObj
          };
        }
        for (oId in oUsers) {
          if (!__hasProp.call(oUsers, oId)) continue;
          oUser = oUsers[oId];
          strNumber = ((_ref1 = oUser.number) != null ? _ref1.toString() : void 0) || '';
          if (!strNumber) {
            continue;
          }
          if (_this.usersByNumber[strNumber]) {
            user = _this.usersByNumber[strNumber];
            oUser.isFantom = false;
            user.init(oUser);
          } else {
            user = new CUser(oUser);
            if (user.number) {
              _this.usersByNumber[user.number] = user;
            }
          }
          if (user.id !== oInfo.userid) {
            _this.panelUsers.push(user);
            if (user.departmentId && user.departmentId !== '00000000-0000-0000-0000-000000000000') {
              if (createdDeps[user.departmentId]) {
                dep = createdDeps[user.departmentId];
              } else {
                dep = createdDeps[user.departmentId] = new Department(user.departmentId, user.department);
                _this.departments.push(dep);
                _this.departmentsById[user.departmentId] = dep;
              }
              dep.addUser(user);
            } else {
              otherDep.addUser(user);
            }
            _this.allUserDep.addUser(user);
          } else {
            _this.me = user;
          }
        }
        _this.departments.sort(function(a, b) {
          if (a.name > b.name) {
            return 1;
          } else if (b.name > a.name) {
            return -1;
          } else {
            return 0;
          }
        });
        _this.departments.push(otherDep);
        oktell.onNativeEvent('pbxnumberstatechanged', _this.onPbxNumberStateChange);
        setTimeout(function() {
          _this.setAbonents(oktell.getAbonents());
          return _this.setHold(oktell.getHoldInfo());
        }, 1000);
        _this.setFilter('', true);
        oktell.getQueue(function(data) {
          if (data.result) {
            return _this.setQueue(data.queue);
          }
        });
        _ref2 = _this.usersWithBeforeConnectButtons;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          user = _ref2[_i];
          user.loadActions();
        }
        _this.showPanel();
        if (typeof afterOktellConnect === 'function') {
          return afterOktellConnect();
        }
      });
      oktell.on('abonentsChange', function(abonents) {
        if (_this.oktellConnected) {
          _this.setAbonents(abonents);
          return _this.reloadActions();
        }
      });
      oktell.on('holdStateChange', function(holdInfo) {
        if (_this.oktellConnected) {
          _this.setHold(holdInfo);
          return _this.reloadActions();
        }
      });
      oktell.on('talkTimer', function(seconds, formattedTime) {
        if (_this.oktellConnected) {
          if (seconds === false) {
            return _this.talkTimeEl.text('');
          } else {
            return _this.talkTimeEl.text(formattedTime);
          }
        }
      });
      oktell.on('stateChange', function(newState, oldState) {
        if (_this.oktellConnected) {
          return _this.reloadActions();
        }
      });
      oktell.on('queueChange', function(queue) {
        if (_this.oktellConnected) {
          return _this.setQueue(queue);
        }
      });
      oktell.on('connectError', function() {
        if (!_this.options.hideOnDisconnect) {
          return _this.showPanel();
        }
      });
      ringNotify = null;
      oktell.on('ringStart', function(abonents) {
        if (_this.options.useNotifies) {
          return ringNotify = new Notify(_this.langs.callPopup.title);
        }
      });
      oktell.on('ringStop', function() {
        if (ringNotify != null) {
          if (typeof ringNotify.close === "function") {
            ringNotify.close();
          }
        }
        return ringNotify = null;
      });
    }

    List.prototype.onPbxNumberStateChange = function(data) {
      var dep, index, n, numStr, user, userNowIsFiltered, wasFiltered, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results;

      _ref = data.numbers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        numStr = n.num.toString();
        user = this.usersByNumber[numStr];
        if (user) {
          if (this.showDeps) {
            dep = this.departmentsById[user.departmentId];
          } else {
            dep = this.allUserDep;
          }
          wasFiltered = user.isFiltered(this.filter, this.showOffline, this.filterLang);
          user.setState(n.numstateid);
          userNowIsFiltered = user.isFiltered(this.filter, this.showOffline, this.filterLang);
          if (!userNowIsFiltered) {
            if (dep.getContainer().children().length === 1) {
              _results.push(this.setFilter(this.filter, true));
            } else {
              _results.push((_ref1 = user.el) != null ? typeof _ref1.remove === "function" ? _ref1.remove() : void 0 : void 0);
            }
          } else if (!wasFiltered) {
            dep.getUsers(this.filter, this.showOffline, this.filterLang);
            index = dep.lastFilteredUsers.indexOf(user);
            if (index !== -1) {
              if (!dep.getContainer().is(':visible')) {
                _results.push(this.setFilter(this.filter, true));
              } else {
                if (index === 0) {
                  dep.getContainer().prepend(user.getEl());
                } else {
                  if ((_ref2 = dep.lastFilteredUsers[index - 1]) != null) {
                    if ((_ref3 = _ref2.el) != null) {
                      _ref3.after(user.getEl());
                    }
                  }
                }
                if (((_ref4 = dep.lastFilteredUsers[index - 1]) != null ? _ref4.letter : void 0) === user.letter) {
                  _results.push(user.letterVisibility(false));
                } else if (((_ref5 = dep.lastFilteredUsers[index + 1]) != null ? _ref5.letter : void 0) === user.letter) {
                  _results.push(dep.lastFilteredUsers[index + 1].letterVisibility(false));
                } else {
                  _results.push(void 0);
                }
              }
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    List.prototype.hideActionListDropdown = function() {
      var _this = this;

      return this.dropdownEl.fadeOut(150, function() {
        return _this.dropdownOpenedOnPanel = false;
      });
    };

    List.prototype.showPanel = function(notAnimate) {
      var w,
        _this = this;

      w = this.panelEl.data('width');
      if (w > 0 && this.panelEl.data('hided')) {
        this.log('show panel');
        this.log('Set width showpanel ' + w);
        this.panelEl.data('width', w);
        this.panelEl.data('hided', false);
        this.panelEl.css({
          display: ''
        });
        if (!notAnimate) {
          return this.panelEl.css({
            overflow: '',
            width: w + 'px'
          });
        } else {
          return this.panelEl.animate({
            width: w + 'px'
          }, 200, function() {
            return _this.panelEl.css({
              overflow: ''
            });
          });
        }
      }
    };

    List.prototype.hidePanel = function(notAnimate) {
      var w,
        _this = this;

      w = this.panelEl.data('width') != null ? this.panelEl.data('width') : this.panelEl.width();
      if (w > 0 && !this.panelEl.data('hided')) {
        this.log('hide panel');
        this.log('Set width hidepanel ' + w);
        this.panelEl.data('width', w);
        this.panelEl.data('hided', true);
        if (notAnimate) {
          return this.panelEl.css({
            display: '',
            overflow: 'hidden',
            width: '0px'
          });
        } else {
          return this.panelEl.animate({
            width: '0px'
          }, 200, function() {
            return _this.panelEl.css({
              display: '',
              overflow: 'hidden'
            });
          });
        }
      }
    };

    List.prototype.getUserButtonForPlugin = function(phone) {
      var button, user,
        _this = this;

      user = this.getUser(phone);
      if (!this.oktellConnected) {
        this.usersWithBeforeConnectButtons.push(user);
      }
      this.userWithGeneratedButtons[phone] = user;
      button = user.getButtonEl();
      button.find('.drop_down').bind('click', function() {
        var actions;

        actions = user.loadActions();
        return _this.showDropdown(user, button, actions);
      });
      return button;
    };

    List.prototype.clearFilter = function() {
      this.filterInput.val('');
      this.setFilter('');
      return this.filterInput.keyup();
    };

    List.prototype.toggleKeypadVisibility = function() {
      return this.setKeypadVisibility(!this.keypadIsVisible);
    };

    List.prototype.setKeypadVisibility = function(visible) {
      if ((visible != null) && Boolean(this.keypadIsVisible) !== Boolean(visible)) {
        this.keypadIsVisible = Boolean(visible);
        this.keypadEl.stop(true, true);
        if (this.keypadIsVisible) {
          return this.keypadEl.slideDown({
            duration: 200,
            easing: 'linear',
            done: this.setUserListHeight
          });
        } else {
          return this.keypadEl.slideUp({
            duration: 200,
            easing: 'linear',
            done: this.setUserListHeight
          });
        }
      }
    };

    List.prototype.addEventListenersForButton = function(user, button) {
      var _this = this;

      return button.bind('click', function() {
        user;        if (user) {
          return _this.showDropdown(user, $(_this));
        }
      });
    };

    List.prototype.showDropdown = function(user, buttonEl, actions, onPanel) {
      var a, aEls, t, _i, _len, _ref;

      t = this.dropdownElLiTemplate;
      this.dropdownEl.empty();
      if (actions != null ? actions.length : void 0) {
        aEls = [];
        for (_i = 0, _len = actions.length; _i < _len; _i++) {
          a = actions[_i];
          if (typeof a === 'string' && ((_ref = this.allActions[a]) != null ? _ref.text : void 0)) {
            aEls.push(t.replace(this.regexps.actionText, this.allActions[a].text).replace(this.regexps.action, a).replace(this.regexps.css, this.actionCssPrefix + a.toLowerCase()));
          }
        }
        if (aEls.length) {
          this.dropdownEl.append(aEls);
          this.dropdownEl.data('user', user);
          this.dropdownEl.css({
            'top': this.dropdownEl.height() + buttonEl.offset().top > $(window).height() ? $(window).height() - this.dropdownEl.height() - this.dropdownPaddingBottomLeft : buttonEl.offset().top,
            'left': Math.max(this.dropdownPaddingBottomLeft, buttonEl.offset().left - this.dropdownEl.width() + buttonEl.width()),
            'visibility': 'visible'
          });
          this.dropdownEl.fadeIn(100);
          if (onPanel) {
            return this.dropdownOpenedOnPanel = true;
          }
        } else {
          return this.dropdownEl.hide();
        }
      } else {
        return this.dropdownEl.hide();
      }
    };

    List.prototype.logUsers = function() {
      var k, u, _ref, _results;

      _ref = this.panelUsersFiltered;
      _results = [];
      for (k in _ref) {
        if (!__hasProp.call(_ref, k)) continue;
        u = _ref[k];
        _results.push(this.log(u.getInfo()));
      }
      return _results;
    };

    List.prototype.syncAbonentsAndUserlist = function(abonents, userlist) {
      var absByNumber, uNumber, user, _results,
        _this = this;

      absByNumber = {};
      $.each(abonents, function(i, ab) {
        var number, u;

        if (!ab) {
          return;
        }
        number = ab.phone.toString() || '';
        if (!number) {
          return;
        }
        absByNumber[number] = ab;
        if (!userlist[ab.phone.toString()]) {
          u = _this.getUser({
            name: ab.name,
            number: ab.phone,
            id: ab.userid,
            state: 1
          });
          return userlist[u.number] = u;
        }
      });
      _results = [];
      for (uNumber in userlist) {
        if (!__hasProp.call(userlist, uNumber)) continue;
        user = userlist[uNumber];
        if (!absByNumber[user.number]) {
          _results.push(delete userlist[user.number]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    List.prototype.setAbonents = function(abonents) {
      this.syncAbonentsAndUserlist(abonents, this.abonents);
      return this.setAbonentsHtml();
    };

    List.prototype.setQueue = function(queue) {
      var ab, key, user, _i, _len, _ref;

      if (this.oktell.getState() === 'ring') {
        for (key = _i = 0, _len = queue.length; _i < _len; key = ++_i) {
          ab = queue[key];
          if (this.abonents[ab.phone]) {
            delete queue[key];
          }
        }
      }
      this.syncAbonentsAndUserlist(queue, this.queue);
      _ref = this.queue;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        user = _ref[key];
        user.loadActions();
      }
      return this.setQueueHtml();
    };

    List.prototype.setHold = function(holdInfo) {
      var abs;

      abs = [];
      if (holdInfo.hasHold) {
        if (holdInfo.conferenceid) {
          abs = [
            {
              number: holdInfo.conferenceRoom,
              id: holdInfo.conferenceid,
              name: holdInfo.conferenceName
            }
          ];
        } else {
          abs = [holdInfo.abonent];
        }
      }
      this.syncAbonentsAndUserlist(abs, this.hold);
      return this.setHoldHtml();
    };

    List.prototype.setPanelUsersHtml = function(usersArray) {
      this._setUsersHtml(usersArray, this.usersListEl);
      return this.userScrollerToTop();
    };

    List.prototype.setAbonentsHtml = function() {
      return this._setActivityPanelUserHtml(this.abonents, this.abonentsListEl, this.abonentsListBlock);
    };

    List.prototype.setHoldHtml = function() {
      return this._setActivityPanelUserHtml(this.hold, this.holdListEl, this.holdBlockEl);
    };

    List.prototype.setQueueHtml = function() {
      return this._setActivityPanelUserHtml(this.queue, this.queueListEl, this.queueBlockEl);
    };

    List.prototype._setActivityPanelUserHtml = function(users, listEl, blockEl) {
      var k, u, usersArray;

      usersArray = [];
      for (k in users) {
        if (!__hasProp.call(users, k)) continue;
        u = users[k];
        usersArray.push(u);
      }
      this._setUsersHtml(usersArray, listEl, true);
      if (usersArray.length && blockEl.is(':not(:visible)')) {
        blockEl.stop(true, true);
        return blockEl.slideDown(50, this.setUserListHeight);
      } else if (usersArray.length === 0 && blockEl.is(':visible')) {
        blockEl.stop(true, true);
        return blockEl.slideUp(50, this.setUserListHeight);
      }
    };

    List.prototype._setUsersHtml = function(usersArray, $el, useIndependentCopies) {
      var html, lastDepId, prevLetter, u, _i, _len;

      html = [];
      lastDepId = null;
      prevLetter = '';
      for (_i = 0, _len = usersArray.length; _i < _len; _i++) {
        u = usersArray[_i];
        html.push(u.getEl(useIndependentCopies));
        u.showLetter(prevLetter !== u.letter ? true : false);
        prevLetter = u.letter;
      }
      $el.children().detach();
      return $el.html(html);
    };

    List.prototype.setFilter = function(filter, reloadAnyway) {
      var allDeps, dep, el, exactMatch, oldFilter, renderDep, _i, _len, _ref,
        _this = this;

      if (this.filter === filter && !reloadAnyway) {
        return false;
      }
      oldFilter = this.filter;
      this.filter = filter;
      this.filterLang = filter.match(/^[^А-яёЁ]+$/) ? 'en' : filter.match(/^[^A-z]+$/) ? 'ru' : '';
      exactMatch = false;
      this.timer();
      this.panelUsersFiltered = [];
      allDeps = [];
      renderDep = function(dep) {
        var depExactMatch, el, users, _ref;

        el = dep.getEl(filter !== '');
        depExactMatch = false;
        _ref = dep.getUsers(filter, _this.showOffline, _this.filterLang), users = _ref[0], depExactMatch = _ref[1];
        _this.panelUsersFiltered = _this.panelUsersFiltered.concat(users);
        if (users.length !== 0) {
          if (!exactMatch) {
            exactMatch = depExactMatch;
          }
          _this._setUsersHtml(users, dep.getContainer());
          if (depExactMatch && exactMatch === depExactMatch) {
            return allDeps.unshift(el);
          } else {
            return allDeps.push(el);
          }
        }
      };
      if (this.showDeps) {
        _ref = this.departments;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dep = _ref[_i];
          renderDep(dep);
        }
      } else {
        renderDep(this.allUserDep);
      }
      if (!exactMatch && filter.match(/[0-9\(\)\+\-]/)) {
        this.filterFantomUser = this.getUser({
          name: filter,
          number: filter
        }, true);
        this.exactMatchUserDep.clearUsers();
        this.exactMatchUserDep.addUser(this.filterFantomUser);
        el = this.exactMatchUserDep.getEl();
        this._setUsersHtml([this.filterFantomUser], this.exactMatchUserDep.getContainer());
        this.filterFantomUser.showLetter(false);
        allDeps.unshift(el);
      } else {
        this.filterFantomUser = false;
      }
      this.usersListBlockEl.children().detach();
      this.usersListBlockEl.html(allDeps);
      if (allDeps.length > 0) {
        allDeps[allDeps.length - 1].find('tr:last').addClass('g_last');
      }
      this.userScrollerToTop();
      this.setUserListHeight();
      return this.timer(true);
    };

    List.prototype.afterSetFilter = function(filteredUsersArray) {
      return this.setPanelUsersHtml(filteredUsersArray);
    };

    List.prototype.getUser = function(data, dontRemember) {
      var fantom, numberFormatted, strNumber, _ref;

      if (typeof data === 'string' || typeof data === 'number') {
        strNumber = data.toString();
        data = {
          number: strNumber
        };
      } else {
        strNumber = data.number.toString();
      }
      numberFormatted = data.phoneFormatted || (typeof oktell.formatPhone === "function" ? oktell.formatPhone(strNumber) : void 0) || strNumber;
      if (!data.numberFormatted) {
        data.numberFormatted = numberFormatted;
      }
      if (!dontRemember && ((_ref = this.filterFantomUser) != null ? _ref.number : void 0) === strNumber) {
        this.usersByNumber[strNumber] = this.filterFantomUser;
        data.isFantom = true;
        this.filterFantomUser = false;
      }
      if (this.usersByNumber[strNumber]) {
        if (this.usersByNumber[strNumber].isFantom) {
          this.usersByNumber[strNumber].init(data);
        }
        return this.usersByNumber[strNumber];
      }
      fantom = new CUser({
        number: strNumber,
        numberFormatted: numberFormatted,
        name: data.name,
        isFantom: true,
        state: ((data != null ? data.state : void 0) != null ? data.state : 1)
      });
      if (!dontRemember) {
        this.usersByNumber[strNumber] = fantom;
      }
      return fantom;
    };

    List.prototype.reloadActions = function() {
      var _this = this;

      return setTimeout(function() {
        var actions, phone, user, _ref, _ref1, _ref2, _ref3, _results;

        _ref = _this.userWithGeneratedButtons;
        for (phone in _ref) {
          if (!__hasProp.call(_ref, phone)) continue;
          user = _ref[phone];
          actions = user.loadActions();
        }
        _ref1 = _this.abonents;
        for (phone in _ref1) {
          user = _ref1[phone];
          user.loadActions();
        }
        _ref2 = _this.queue;
        for (phone in _ref2) {
          user = _ref2[phone];
          user.loadActions();
        }
        _ref3 = _this.panelUsersFiltered;
        _results = [];
        for (phone in _ref3) {
          user = _ref3[phone];
          _results.push(user.loadActions());
        }
        return _results;
      }, 100);
    };

    List.prototype.timer = function(stop) {
      if (stop && this._time) {
        1;
      }
      if (!stop) {
        return this._time = Date.now();
      }
    };

    List.prototype.beforeUserAction = function(user, action) {
      if (this.filterFantomUser && user === this.filterFantomUser) {
        return this.clearFilter();
      }
    };

    List.prototype.config = function(data) {
      var e, k, v, _ref;

      if (!this._config) {
        if ((typeof localStorage !== "undefined" && localStorage !== null ? localStorage.oktellPanel : void 0) && (typeof JSON !== "undefined" && JSON !== null ? JSON.parse : void 0)) {
          try {
            this._config = JSON.parse(localStorage.oktellPanel);
          } catch (_error) {
            e = _error;
          }
          if ((this._config == null) || typeof this._config !== 'object') {
            this._config = {};
          }
        } else {
          this._config = {};
        }
        _ref = this.defaultConfig;
        for (k in _ref) {
          if (!__hasProp.call(_ref, k)) continue;
          v = _ref[k];
          if (this._config[k] == null) {
            this._config[k] = v;
          }
        }
      }
      if (data != null) {
        for (k in data) {
          if (!__hasProp.call(data, k)) continue;
          v = data[k];
          this._config[k] = v;
        }
        if (localStorage && (typeof JSON !== "undefined" && JSON !== null ? JSON.stringify : void 0)) {
          localStorage.setItem('oktellPanel', JSON.stringify(this._config));
        }
      }
      this.showDeps = this._config.showDeps;
      this.showOffline = this._config.showOffline;
      this.buttonShowOffline.toggleClass('g_active', !this.showOffline);
      this.buttonShowOffline.attr('title', this.showOffline ? this.langs.panel.showOnlineOnly : this.langs.panel.showOnlineOnlyCLicked);
      this.buttonShowDeps.toggleClass('g_active', this.showDeps);
      this.buttonShowDeps.attr('title', this.showDeps ? this.langs.panel.showDepartmentsClicked : this.langs.panel.showDepartments);
      return this._config;
    };

    return List;

  })();
  Popup = (function() {
    Popup.prototype.logGroup = 'Popup';

    function Popup(popupEl, oktell) {
      var _this = this;

      this.el = popupEl;
      this.absContainer = this.el.find('.b_content');
      this.abonentEl = this.absContainer.find('.b_abonent').remove();
      this.answerActive = false;
      this.answerButttonEl = this.el.find('.j_answer');
      this.puckupEl = this.el.find('.j_pickup');
      this.el.find('.j_abort_action').bind('click', function() {
        _this.hide();
        return oktell.endCall();
      });
      this.el.find('.j_answer').bind('click', function() {
        _this.hide();
        return oktell.answer();
      });
      this.el.find('.j_close_action').bind('click', function() {
        return _this.hide();
      });
      this.el.find('i.o_close').bind('click', function() {
        return _this.hide();
      });
      oktell.on('ringStart', function(abonents) {
        _this.setAbonents(abonents);
        _this.answerButtonVisible(oktell.webphoneIsActive());
        return _this.show();
      });
      oktell.on('ringStop', function() {
        return _this.hide();
      });
    }

    Popup.prototype.show = function(abonents) {
      this.log('Popup show! ', abonents);
      return this.el.fadeIn(200);
    };

    Popup.prototype.hide = function() {
      return this.el.fadeOut(200);
    };

    Popup.prototype.setAbonents = function(abonents) {
      var _this = this;

      this.absContainer.empty();
      return $.each(abonents, function(i, abonent) {
        var el, name, phone;

        phone = abonent.phone.toString();
        name = abonent.name.toString() || phone;
        if (name === phone) {
          phone = '';
        }
        el = _this.abonentEl.clone();
        el.find('span:first').text(name);
        el.find('span:last').text(phone);
        return _this.absContainer.append(el);
      });
    };

    Popup.prototype.answerButtonVisible = function(val) {
      if (val) {
        this.answerActive = true;
        this.answerButttonEl.show();
        this.puckupEl.hide();
      } else {
        this.answerActive = false;
        this.answerButttonEl.hide();
        this.puckupEl.show();
      }
      return this.answerActive;
    };

    Popup.prototype.setCallbacks = function(onAnswer, onTerminate) {
      this.onAnswer = onAnswer;
      return this.onTerminate = onTerminate;
    };

    return Popup;

  })();
  PermissionsPopup = (function() {
    function PermissionsPopup(popupEl, oktellVoice) {
      var _this = this;

      this.el = popupEl;
      if (oktellVoice) {
        oktellVoice.on('mediaPermissionsRequest', function() {
          return _this.show();
        });
        oktellVoice.on('mediaPermissionsAccept', function() {
          return _this.hide();
        });
        oktellVoice.on('mediaPermissionsRefuse', function() {
          if (typeof oktell !== "undefined" && oktell !== null) {
            oktell.endCall();
          }
          return _this.hide();
        });
      }
    }

    PermissionsPopup.prototype.show = function() {
      this.log('Permissions Popup show!');
      return this.el.show();
    };

    PermissionsPopup.prototype.hide = function() {
      return this.el.fadeOut(200);
    };

    return PermissionsPopup;

  })();
  Error = (function() {
    Error.prototype.logGroup = 'Error';

    Error.prototype.errorTypes = {
      1: 'usingOktellClient',
      2: 'loginPass',
      3: 'unavailable'
    };

    function Error(errorEl, oktell) {
      var _this = this;

      this.el = errorEl;
      oktell.on('connecting', function() {
        return _this.hide();
      });
      oktell.on('disconnect', function(reason) {
        _this.log('disconnect with reason ' + reason.code + ' ' + reason.message);
        if (reason.code === 12) {
          return _this.show(3, oktell.getMyInfo().login);
        }
      });
      oktell.on('connectError', function(error) {
        _this.log('connect error ' + error.errorCode + ' ' + error.errorMessage);
        switch (error.errorCode) {
          case 12:
            return _this.show(1, oktell.getMyInfo().login);
          case 13:
            return _this.show(2, oktell.getMyInfo().login);
          case 1204:
            return _this.show(1, oktell.getMyInfo().login);
          case 1202:
            return _this.show(2, oktell.getMyInfo().login);
          default:
            return _this.show(3, oktell.getMyInfo().login);
        }
      });
    }

    Error.prototype.show = function(errorType, username) {
      var type, _ref, _ref1;

      if (!this.errorTypes[errorType]) {
        return false;
      }
      this.log('show ' + errorType);
      type = this.errorTypes[errorType];
      this.el.find('p:eq(0)').text(this.langs[type].header.replace('%username%', username));
      this.el.find('p:eq(1)').text(((_ref = this.langs[type].message) != null ? _ref.replace('%username%', username) : void 0) || '');
      this.el.find('p:eq(3)').text(((_ref1 = this.langs[type].message2) != null ? _ref1.replace('%username%', username) : void 0) || '');
      return this.el.fadeIn(200);
    };

    Error.prototype.hide = function() {
      return this.el.fadeOut(200);
    };

    return Error;

  })();
  defaultOptions = {
    position: 'right',
    dynamic: false,
    oktell: window.oktell,
    oktellVoice: window.oktellVoice,
    debug: false,
    lang: 'ru',
    noavatar: true,
    hideOnDisconnect: true,
    useNotifies: false,
    withoutPermissionsPopup: false,
    withoutCallPopup: false,
    withoutError: false
  };
  langs = {
    ru: {
      panel: {
        inTalk: 'В разговоре',
        onHold: 'На удержании',
        queue: 'Очередь ожидания',
        inputPlaceholder: 'введите имя или номер',
        withoutDepartment: 'без отдела',
        showDepartments: 'Группировать по отделам',
        showDepartmentsClicked: 'Показать общим списком',
        showOnlineOnly: 'Показать только online',
        showOnlineOnlyCLicked: 'Показать всех'
      },
      actions: {
        answer: 'Ответить',
        call: 'Позвонить',
        conference: 'Конференция',
        transfer: 'Перевести',
        toggle: 'Переключиться',
        intercom: 'Интерком',
        endCall: 'Завершить',
        ghostListen: 'Прослушка',
        ghostHelp: 'Помощь',
        hold: 'Удержание',
        resume: 'Продолжить'
      },
      callPopup: {
        title: 'Входящий вызов',
        hide: 'Скрыть',
        answer: 'Ответить',
        reject: 'Отклонить',
        undefinedNumber: 'Номер не определен',
        goPickup: 'Поднимите трубку'
      },
      permissionsPopup: {
        header: 'Запрос на доступ к микрофону',
        text: 'Для использования веб-телефона необходимо разрешить браузеру доступ к микрофону.'
      },
      error: {
        usingOktellClient: {
          header: 'Пользователь «%username%» использует стандартный Oktell-клиент.',
          message: 'Одновременная работа двух типов клиентских приложений невозможна.',
          message2: 'Закройте стандартный Oktell-клиент и повторите попытку.'
        },
        loginPass: {
          header: 'Пароль для пользователя «%username%» не подходит.',
          message: 'Проверьте правильность имени пользователя и пароля.'
        },
        unavailable: {
          header: 'Сервер телефонии Oktell не доступен.',
          message: 'Убедитесь что сервер телефонии работает и проверьте настройки соединения.'
        }
      }
    },
    en: {
      panel: {
        inTalk: 'In conversation',
        onHold: 'On hold',
        queue: 'Wait queue',
        inputPlaceholder: 'Enter name or number',
        withoutDepartment: 'Without department',
        showDepartments: 'Show departments',
        showDepartmentsClicked: 'Hide departments',
        showOnlineOnly: 'Show online only',
        showOnlineOnlyCLicked: 'Show all'
      },
      actions: {
        answer: 'Answer',
        call: 'Dial',
        conference: 'Conference',
        transfer: 'Transfer',
        toggle: 'Switch',
        intercom: 'Intercom',
        endCall: 'End',
        ghostListen: 'Audition',
        ghostHelp: 'Help',
        hold: 'Hold',
        resume: 'Resume'
      },
      callPopup: {
        title: 'Incoming call',
        hide: 'Hide',
        answer: 'Answer',
        reject: 'Decline',
        undefinedNumber: 'Phone number is not defined',
        goPickup: 'Pick up the phone'
      },
      permissionsPopup: {
        header: 'Request for access to the microphone',
        text: 'To use the web-phone you need to allow browser access to the microphone.'
      },
      error: {
        usingOktellClient: {
          header: 'User «%username%» uses standard Oktell client application.',
          message: 'Simultaneous work of two types of client applications is not possible.',
          message2: 'Close standard Oktell client application and try again.'
        },
        loginPass: {
          header: 'Wrong password for user «%username%».',
          message: 'Make sure that the username and password are correct.'
        },
        unavailable: {
          header: 'Oktell server is not available.',
          message: 'Make sure that Oktell server is running and check your connection.'
        }
      }
    },
    cz: {
      panel: {
        inTalk: 'V rozhovoru',
        onHold: 'Na hold',
        queue: 'Fronta čekaní',
        inputPlaceholder: 'zadejte jméno nebo číslo',
        withoutDepartment: 'Bez oddělení',
        showDepartments: 'Zobrazit oddělení',
        showDepartmentsClicked: 'Skrýt oddělení',
        showOnlineOnly: 'Zobrazit pouze online',
        showOnlineOnlyCLicked: 'Zobrazit všechny'
      },
      actions: {
        answer: 'Odpověď',
        call: 'Zavolat',
        conference: 'Konference',
        transfer: 'Převést',
        toggle: 'Přepnout',
        intercom: 'Intercom',
        endCall: 'Ukončit',
        ghostListen: 'Odposlech',
        ghostHelp: 'Nápověda',
        hold: 'Udržet',
        resume: 'Pokračovat'
      },
      callPopup: {
        title: 'Příchozí hovor',
        hide: 'Schovat',
        answer: 'Odpovědět',
        reject: 'Odmítnout',
        undefinedNumber: '',
        goPickup: 'Zvedněte sluchátko'
      },
      permissionsPopup: {
        header: 'Žádost o přístup k mikrofonu',
        text: 'Abyste mohli používat telefon, musíte povolit prohlížeče přístup k mikrofonu.'
      },
      error: {
        usingOktellClient: {
          header: 'Uživatel «%username%» používá standardní Oktell klientské aplikace.',
          message: 'Současnou práci dvou typů klientských aplikací není možné.',
          message2: 'Zavřít Oktell standardní klientskou aplikaci a zkuste to znovu.'
        },
        loginPass: {
          header: 'Chybné heslo uživatele «%username%».',
          message: 'Ujistěte se, že uživatelské jméno a heslo jsou správné.'
        },
        unavailable: {
          header: 'Oktell server není k dispozici.',
          message: 'Ujistěte se, že Oktell server běží a zkontrolujte připojení.'
        }
      }
    }
  };
  options = null;
  actionListEl = null;
  oktell = null;
  oktellConnected = false;
  afterOktellConnect = null;
  list = null;
  popup = null;
  permissionsPopup = null;
  error = null;
  actionButtonContainerClass = 'oktellPanelActionButton';
  getOptions = function() {
    return options || defaultOptions;
  };
  logStr = '';
  log = function() {
    var args, d, dd, e, fnName, i, t, val, _i, _len;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (!getOptions().debug) {
      return;
    }
    d = new Date();
    dd = d.getFullYear() + '-' + (d.getMonth() < 10 ? '0' : '') + d.getMonth() + '-' + (d.getDate() < 10 ? '0' : '') + d.getDate();
    t = (d.getHours() < 10 ? '0' : '') + d.getHours() + ':' + (d.getMinutes() < 10 ? '0' : '') + d.getMinutes() + ':' + (d.getSeconds() < 10 ? '0' : '') + d.getSeconds() + ':' + (d.getMilliseconds() + 1000).toString().substr(1);
    logStr += dd + ' ' + t + ' | ';
    fnName = 'log';
    if (args[0].toString().toLowerCase() === 'error') {
      fnName = 'error';
    }
    for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
      val = args[i];
      if (typeof val === 'object') {
        try {
          logStr += JSON.stringify(val);
        } catch (_error) {
          e = _error;
          logStr += val.toString();
        }
      } else {
        logStr += val;
      }
      logStr += ' | ';
    }
    logStr += "\n\n";
    args.unshift('Oktell-Panel.js ' + t + ' |' + (typeof this.logGroup === 'string' ? ' ' + this.logGroup + ' |' : ''));
    try {
      return console[fnName].apply(console, args || []);
    } catch (_error) {
      e = _error;
    }
  };
  templates = {
    'templates/actionButton.html': '<ul class="oktell_button_action"><li class="g_first"><i></i></li><li class="g_last drop_down"><i></i></li></ul>',
    'templates/actionList.html': '<ul class="oktell_actions_group_list"><li class="{{css}}" data-action="{{action}}"><i></i><span>{{actionText}}</span></li></ul>',
    'templates/user.html': '<tr class="b_contact"><td class="b_contact_avatar {{css}}"><img src="{{avatarLink32x32}}"><i></i><div class="o_busy"></div></td><td class="b_capital_letter"><span></span></td><td class="b_contact_title"><div class="wrapword"><span class="b_contact_name"><b>{{name1}}</b><span>{{name2}}</span></span><span class="o_number">{{number}}</span></div>{{button}}</td></tr>',
    'templates/department.html': '<tr class="b_contact"><td class="b_contact_department" colspan="3">{{department}}</td></tr>',
    'templates/dep.html': '<div class="b_department"><div class="b_department_header"><div class="h_shadow_top"><span>{{department}}</span></div></div><table class="b_main_list"><tbody></tbody></table></div>',
    'templates/usersTable.html': '<table class="b_main_list m_without_department"><tbody></tbody></table>',
    'templates/panel.html': '<div class="oktell_panel"><div class="i_panel_bookmark"><div class="i_panel_bookmark_bg"></div></div><div class="h_panel_bg"><div class="b_header"><ul class="b_list_filter"><li class="i_group"></li><li class="i_online"></li></ul></div><div class="h_padding"><div class="b_marks i_conference j_abonents"><div class="h_shadow_top"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{inTalk}}</span><span class="b_marks_time"></span></p><table><tbody></tbody></table></div></div></div><div class="b_marks i_extension" style="display: none"><div class="h_shadow_top"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">Донабор</span></p><div class="h_btn-group"><div class="btn-group"><button class="btn btn-small">1</button><button class="btn btn-small">2</button><button class="btn btn-small">3</button><button class="btn btn-small">4</button><button class="btn btn-small">5</button><button class="btn btn-small">6</button><button class="btn btn-small">7</button><button class="btn btn-small">8</button><button class="btn btn-small">9</button><button class="btn btn-small">0</button></div><div class="btn-group"><button class="btn btn-small">&lowast;</button><button class="btn btn-small">#</button></div></div></div></div><i class="o_close"></i></div><div class="b_marks i_flash j_hold"><div class="h_shadow_top"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{onHold}}</span></p><table class="j_table_favorite"><tbody></tbody></table></div></div></div><div class="b_marks i_flash j_queue"><div class="h_shadow_top"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{queue}}</span></p><table class="j_table_queue"><tbody></tbody></table></div></div></div><div class="b_inconversation j_phone_block"><table class="j_table_phone"><tbody></tbody></table></div><div class="b_marks i_phone"><div class="h_shadow_top"><div class="h_phone_number_input"><div class="i_phone_state_bg"></div><div class="h_input_padding"><div class="jInputClear_hover"><input class="b_phone_number_input" type="text" placeholder="{{inputPlaceholder}}"><span class="jInputClear_close">&times;</span></div></div></div></div></div><div class="h_main_list j_main_list"></div></div></div></div>',
    'templates/callPopup.html': '<div class="oktell_panel_popup" style="display: none"><div class="m_popup_staff"><div class="m_popup_data"><header><div class="h_header_bg"><i class="o_close"></i><h2>{{title}}</h2></div></header><div class="b_content"><div class="b_abonent"><span data-bind="text: name"></span>&nbsp;<span class="g_light" data-bind="textPhone: number"></span></div></div><div class="footer"><div class="b_take_phone j_pickup"><i></i>&nbsp;<span>{{goPickup}}</span></div><button class="oktell_panel_btn m_big m_button_green j_answer" style="margin-right: 20px; float: left"><i style="background: url(\'/img/icons/action/white/call.png\') no-repeat; vertical-align: -2px"></i>Ответить</button><button class="oktell_panel_btn m_big j_close_action">{{hide}}</button><button class="oktell_panel_btn m_big m_button_red j_abort_action"><i></i>{{reject}}</button></div></div></div></div>',
    'templates/permissionsPopup.html': '<div class="oktell_panel_popup" style="display: none"><div class="m_popup_staff"><div class="m_popup_data"><header><div class="h_header_bg"><h2>{{header}}</h2></div></header><div class="b_content"><p>{{text}}</p></div></div></div></div>',
    'templates/error.html': '<div class="b_error m_form" style="display: none"><div class="h_padding"><h4>Ошибка</h4><p class="b_error_alert"></p><p class="g_light"></p><p class="g_light"></p></div></div>'
  };
  loadTemplate = function(path) {
    var html;

    if (path[0] === '/') {
      path = path.substr(1);
    }
    if (templates[path] != null) {
      return templates[path];
    }
    html = '';
    $.ajax({
      url: path,
      async: false,
      success: function(data) {
        return html = data;
      }
    });
    return html;
  };
  actionButtonHtml = loadTemplate('/templates/actionButton.html');
  actionListHtml = loadTemplate('/templates/actionList.html');
  userTemplateHtml = loadTemplate('/templates/user.html');
  departmentTemplateHtml = loadTemplate('/templates/department.html');
  departmentTemplateHtml = loadTemplate('/templates/dep.html');
  usersTableHtml = loadTemplate('/templates/usersTable.html');
  panelHtml = loadTemplate('/templates/panel.html');
  popupHtml = loadTemplate('/templates/callPopup.html');
  permissionsPopupHtml = loadTemplate('/templates/permissionsPopup.html');
  errorHtml = loadTemplate('/templates/error.html');
  List.prototype.jScroll = jScroll;
  List.prototype.usersTableTemplate = usersTableHtml;
  CUser.prototype.buttonTemplate = actionButtonHtml;
  CUser.prototype.log = log;
  List.prototype.log = log;
  Popup.prototype.log = log;
  PermissionsPopup.prototype.log = log;
  Department.prototype.log = log;
  Error.prototype.log = log;
  Department.prototype.template = departmentTemplateHtml;
  panelWasInitialized = false;
  isAndroid = /android/gi.test(navigator.appVersion);
  isIDevice = /iphone|ipad/gi.test(navigator.appVersion);
  isTouchPad = /hp-tablet/gi.test(navigator.appVersion);
  hasTouch = __indexOf.call(window, 'ontouchstart') >= 0 && !isTouchPad;
  initPanel = function(opts) {
    var $user, $userActionButton, animOptHide, animOptShow, bookmarkAnimOptHide, bookmarkAnimOptShow, bookmarkPos, errorEl, hidePanel, killPanelHideTimer, mouseOnPanel, oldBinding, panelBookmarkEl, panelEl, panelHideTimer, panelPos, panelStatus, permissionsPopupEl, popupEl, touchClickedContact, touchClickedContactClear, touchClickedCss,
      _this = this;

    panelWasInitialized = true;
    options = $.extend(defaultOptions, opts || {});
    if (getOptions().useNotifies && window.webkitNotifications && window.webkitNotifications.checkPermission() === 1) {
      webkitNotifications.requestPermission(function() {});
    }
    Department.prototype.withoutDepName = List.prototype.withoutDepName = 'zzzzz_without';
    langs = langs[options.lang] || langs.ru;
    CUser.prototype.template = userTemplateHtml.replace('{{button}}', actionButtonHtml);
    panelHtml = panelHtml.replace('{{inTalk}}', langs.panel.inTalk).replace('{{onHold}}', langs.panel.onHold).replace('{{queue}}', langs.panel.queue).replace('{{inputPlaceholder}}', langs.panel.inputPlaceholder);
    List.prototype.langs = langs;
    List.prototype.departmentTemplate = departmentTemplateHtml;
    Error.prototype.langs = langs.error;
    CUser.prototype.langs = langs;
    Department.prototype.langs = langs;
    panelEl = $(panelHtml);
    if (getOptions().noavatar) {
      panelEl.addClass('noavatar');
    }
    $user = $(userTemplateHtml);
    $userActionButton = $(actionButtonHtml);
    oldBinding = $userActionButton.attr('data-bind');
    $userActionButton.attr('data-bind', oldBinding + ', visible: $data.actionBarIsVisible');
    $user.find('td.b_contact_title').append($userActionButton);
    actionListEl = $(actionListHtml);
    $('body').append(actionListEl);
    oktell = getOptions().oktell;
    CUser.prototype.formatPhone = oktell.formatPhone;
    if (!getOptions().withoutCallPopup) {
      popupHtml = popupHtml.replace('{{title}}', langs.callPopup.title).replace('{{goPickup}}', langs.callPopup.goPickup).replace('{{hide}}', langs.callPopup.hide).replace('{{reject}}', langs.callPopup.reject);
      popupEl = $(popupHtml);
      $('body').append(popupEl);
      popup = new Popup(popupEl, oktell);
    }
    if (!getOptions().withoutPermissionsPopup) {
      permissionsPopupHtml = permissionsPopupHtml.replace('{{header}}', langs.permissionsPopup.header).replace('{{text}}', langs.permissionsPopup.text);
      permissionsPopupEl = $(permissionsPopupHtml);
      $('body').append(permissionsPopupEl);
      permissionsPopup = new PermissionsPopup(permissionsPopupEl, getOptions().oktellVoice);
    }
    if (!getOptions().withoutError) {
      errorEl = $(errorHtml);
      panelEl.find('.h_panel_bg:first').append(errorEl);
      error = new Error(errorEl, oktell);
    }
    panelPos = getOptions().position;
    animOptShow = {};
    animOptShow[panelPos] = '0px';
    animOptHide = {};
    animOptHide[panelPos] = '-281px';
    panelEl.hide();
    $("body").append(panelEl);
    list = new List(oktell, panelEl, actionListEl, afterOktellConnect, getOptions(), getOptions().debug);
    if (getOptions().debug) {
      window.wList = list;
      window.wPopup = popup;
      window.wError = error;
    }
    if (panelPos === "right") {
      panelEl.addClass("right");
    } else if (panelPos === "left") {
      panelEl.addClass("left");
    }
    if (getOptions().dynamic) {
      panelEl.addClass("dynamic");
    }
    panelBookmarkEl = panelEl.find('.i_panel_bookmark');
    bookmarkAnimOptShow = {};
    bookmarkPos = panelPos === 'left' ? 'right' : 'left';
    bookmarkAnimOptShow[bookmarkPos] = '0px';
    bookmarkAnimOptHide = {};
    bookmarkAnimOptHide[bookmarkPos] = '-40px';
    mouseOnPanel = false;
    panelHideTimer = false;
    panelStatus = 'closed';
    killPanelHideTimer = function() {
      clearTimeout(panelHideTimer);
      return panelHideTimer = false;
    };
    panelEl.bind("mouseenter", function() {
      mouseOnPanel = true;
      killPanelHideTimer();
      if (parseInt(panelEl.css(panelPos)) < 0 && (panelStatus === 'closed' || panelStatus === 'closing')) {
        panelStatus = 'opening';
        panelBookmarkEl.stop(true, true);
        panelBookmarkEl.css(bookmarkAnimOptShow);
        panelEl.stop(true, true);
        panelEl.animate(animOptShow, 100, "swing", function() {
          panelEl.addClass("g_hover");
          return panelStatus = 'open';
        });
      }
      return true;
    });
    touchClickedContact = null;
    touchClickedCss = 'm_touch_clicked';
    touchClickedContactClear = function() {
      if (touchClickedContact != null) {
        touchClickedContact.removeClass(touchClickedCss);
      }
      return touchClickedContact = null;
    };
    $(window).bind('touchstart', function(e) {
      var contact, parents, parentsArr, target;

      target = $(e.target);
      parents = target.parents();
      parentsArr = parents.toArray();
      if (parentsArr.indexOf(panelEl[0]) === -1) {
        hidePanel();
      }
      if (parentsArr.indexOf(actionListEl[0]) === -1 && !target.is('.oktell_panel .drop_down') && parents.filter('.oktell_panel .drop_down').size() === 0) {
        if (list != null) {
          if (typeof list.hideActionListDropdown === "function") {
            list.hideActionListDropdown();
          }
        }
      }
      contact = target.is('.oktell_panel .b_contact') ? target : parents.filter('.oktell_panel .b_contact');
      if (contact.size() > 0) {
        if (!contact.hasClass(touchClickedCss)) {
          touchClickedContactClear();
          touchClickedContact = contact;
          contact.addClass(touchClickedCss);
          return false;
        }
      } else {
        touchClickedContactClear();
      }
      return true;
    });
    hidePanel = function() {
      if (panelEl.hasClass("g_hover")) {
        panelStatus = 'closing';
        panelEl.stop(true, true);
        return panelEl.animate(animOptHide, 300, "swing", function() {
          panelEl.css({
            panelPos: 0
          });
          panelEl.removeClass("g_hover");
          panelStatus = 'closed';
          panelBookmarkEl.stop(true, true);
          return panelBookmarkEl.css(bookmarkAnimOptHide);
        });
      }
    };
    panelEl.bind("mouseleave", function() {
      mouseOnPanel = false;
      return true;
    });
    $('html').bind('mouseleave', function(e) {
      killPanelHideTimer();
      return true;
    });
    return $('html').bind('mousemove', function(e) {
      if (!mouseOnPanel && panelHideTimer === false && !list.dropdownOpenedOnPanel) {
        panelHideTimer = setTimeout(function() {
          return hidePanel();
        }, 100);
      }
      return true;
    });
  };
  afterOktellConnect = function() {
    return oktellConnected = true;
  };
  initButtonOnElement = function(el) {
    var button, phone;

    el.addClass(getOptions().buttonCss);
    phone = el.attr('data-phone');
    if (phone) {
      button = list.getUserButtonForPlugin(phone);
      return el.html(button);
    }
  };
  addActionButtonToEl = function(el) {
    return initButtonOnElement(el);
  };
  initActionButtons = function(selector) {
    return $(selector + ":not(." + actionButtonContainerClass + ")").each(function() {
      return addActionButtonToEl($(this));
    });
  };
  $.oktellPanel = function(arg) {
    if (typeof arg === 'string') {
      if (panelWasInitialized) {
        return initActionButtons(arg);
      }
    } else if (!panelWasInitialized) {
      return initPanel(arg);
    }
  };
  $.fn.oktellButton = function() {
    return $(this).each(function() {
      return addActionButtonToEl($(this));
    });
  };
  $.oktellPanel.show = function() {
    return list.showPanel();
  };
  return $.oktellPanel.hide = function() {
    return list.hidePanel();
  };
})($);
