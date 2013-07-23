// Generated by CoffeeScript 1.6.2
var List,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty;

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
    this.jScrollPaneParams = {
      mouseWheelSpeed: 50,
      hideFocus: true,
      verticalGutter: -13,
      onScroll: function() {
        return _this.processStickyHeaders.apply(_this);
      }
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
    this.dtmfEl = this.panelEl.find('.i_extension');
    this.dropdownEl = dropdownEl;
    this.dropdownElLiTemplate = this.dropdownEl.html();
    this.dropdownEl.empty();
    this.keypadEl = this.panelEl.find('.j_phone_keypad');
    this.keypadIsVisible = false;
    this.usersListBlockEl = this.panelEl.find('.j_main_list');
    this.scrollContainer = '';
    this.scrollContent = '';
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
    this.dtmfEl.find('.o_close').bind('click', function() {
      return _this.hideDtmf();
    });
    this.dtmfEl.find('.btn-small').bind('click', function(e) {
      return _this.sendDtmf($(e.target).text());
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
    this.initJScrollPane = function() {
      _this.usersListBlockEl.oktellPanelJScrollPane(_this.jScrollPaneParams);
      _this.jScrollPaneAPI = _this.usersListBlockEl.data('jsp');
      _this.scrollContainer = _this.usersListBlockEl.find('.jspContainer');
      return _this.scrollContent = _this.usersListBlockEl.find('.jspPane');
    };
    this.initJScrollPane();
    this.reinitScroll = function() {
      var _ref;

      return (_ref = _this.jScrollPaneAPI) != null ? _ref.reinitialise() : void 0;
    };
    this.userScrollerToTop = function() {
      return _this.jScrollPaneAPI.scrollToY(0);
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

          if ((_ref = _this.scrollContent.find('tr:first').data('user')) != null) {
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
      var actionButton, buttonEl, target, user, _ref;

      target = $(e.target);
      if (target.is('.b_department_header') || target.parents('.b_department_header').size() > 0) {
        if ((_ref = target.parents('.b_department').data('department')) != null) {
          if (typeof _ref.showUsers === "function") {
            _ref.showUsers();
          }
        }
        _this.setUserListHeight();
        return false;
      }
      if (target.is('.o_dtmf')) {
        _this.showDtmf();
        return false;
      }
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

      h = $(window).height() - _this.usersListBlockEl[0].offsetTop + 'px';
      _this.usersListBlockEl.css({
        height: h
      });
      return _this.reinitScroll();
    };
    this.setUserListHeight();
    debouncedSetHeight = debounce(function() {
      _this.userScrollerToTop();
      return _this.setUserListHeight();
    }, 150);
    $(window).bind('resize', function() {
      return debouncedSetHeight();
    });
    this.hidePanel(true);
    oktell.on('webphoneConnect', function() {
      return _this.panelEl.addClass('webphone');
    });
    oktell.on('webphoneDisconnect', function() {
      return _this.panelEl.removeClass('webphone');
    });
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
      oktell.offNativeEvent('pbxnumberstatechanged', _this.onPbxNumberStateChange);
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
      _this.setTalking(oktell.getState() === 'talk');
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
        _this.reloadActions();
        return _this.setTalking(newState === 'talk');
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

  List.prototype.initStickyHeaders = function() {
    var conTop, h, i, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;

    this.resetStickyHeaders();
    this.headerEls = this.usersListBlockEl.find('.b_department_header').toArray();
    if (this.headerEls.length === 0) {
      return;
    } else if ($(this.headerEls[0]).width() === 0) {
      setTimeout(function() {
        return _this.initStickyHeaders();
      }, 500);
      return;
    }
    this.headerFisrt = this.headerEls[0];
    this.headerLast = this.headerEls.length ? this.headerEls[this.headerEls.length - 1] : null;
    _ref = this.headerEls;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      h = _ref[i];
      this.headerEls[i] = $(h);
    }
    conTop = this.scrollContainer.offset().top;
    _ref1 = this.headerEls;
    for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
      h = _ref1[i];
      if (h.offset().top > conTop) {
        this.processStickyHeaders(i - 1);
        break;
      }
    }
    return this.processStickyHeaders();
  };

  List.prototype.headerHeight = 24;

  List.prototype.processStickyHeaders = function(elIndex) {
    var conTop, curTop, nexTop, tt, _ref, _ref1;

    if (((_ref = this.headerEls) != null ? _ref.length : void 0) > 0) {
      if (elIndex != null) {
        this.currentTopIndex = elIndex;
        if ((_ref1 = this.currentTopHeaderClone) != null) {
          _ref1.remove();
        }
        this.currentTopHeaderClone = this.headerEls[this.currentTopIndex].clone();
        this.headerEls[this.currentTopIndex].after(this.currentTopHeaderClone);
        this.currentTopHeaderClone.css({
          position: 'fixed',
          zIndex: 1,
          width: this.scrollContainer.width() + 'px'
        });
        tt = this.scrollContainer.offset().top;
        this.currentTopHeaderClone.offset({
          top: tt
        });
        return this.processStickyHeaders();
      } else if (this.currentTopIndex != null) {
        conTop = this.scrollContainer.offset().top;
        curTop = this.headerEls[this.currentTopIndex].offset().top;
        if (curTop > conTop) {
          return this.processStickyHeaders(this.currentTopIndex - 1);
        } else {
          if (this.headerEls[this.currentTopIndex + 1]) {
            nexTop = this.headerEls[this.currentTopIndex + 1].offset().top;
            if (nexTop > conTop + this.headerHeight) {
              return this.currentTopHeaderClone.offset({
                top: conTop
              });
            } else if (nexTop > conTop) {
              return this.currentTopHeaderClone.offset({
                top: nexTop - this.headerHeight
              });
            } else if (nexTop < conTop) {
              return this.processStickyHeaders(this.currentTopIndex + 1);
            }
          }
        }
      }
    }
  };

  List.prototype.resetStickyHeaders = function() {
    var _ref;

    if ((_ref = this.currentTopHeaderClone) != null) {
      if (typeof _ref.remove === "function") {
        _ref.remove();
      }
    }
    this.currentTopHeaderClone = null;
    this.currentTopIndex = null;
    return this.headerEls = null;
  };

  List.prototype.beforeShow = function() {};

  List.prototype.afterShow = function() {
    return this.initStickyHeaders();
  };

  List.prototype.beforeHide = function() {
    return this.resetStickyHeaders();
  };

  List.prototype.afterHide = function() {};

  List.prototype.setTalking = function(isTalking) {
    if (isTalking) {
      return this.panelEl.addClass('talking');
    } else {
      this.hideDtmf();
      return this.panelEl.removeClass('talking');
    }
  };

  List.prototype.sendDtmf = function(code) {
    return this.oktell.dtmf(code.toString().replace('∗', '*'));
  };

  List.prototype.showDtmf = function(dontAnimate) {
    var _this = this;

    if (this.oktell.getState() === 'talk' && this.panelEl.hasClass('webphone') && !this.panelEl.hasClass('dtmf')) {
      this.panelEl.addClass('dtmf');
      this.dtmfEl.stop(true, true);
      if (dontAnimate) {
        return this.dtmfEl.show();
      } else {
        return this.dtmfEl.slideDown(200, function() {});
      }
    }
  };

  List.prototype.hideDtmf = function(dontAnimate) {
    var _this = this;

    if (this.panelEl.hasClass('dtmf')) {
      this.panelEl.removeClass('dtmf');
      this.dtmfEl.stop(true, true);
      if (dontAnimate) {
        return this.dtmfEl.hide();
      } else {
        return this.dtmfEl.slideUp(200, function() {});
      }
    }
  };

  List.prototype.onPbxNumberStateChange = function(data) {
    var dep, index, n, numStr, user, userNowIsFiltered, wasFiltered, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results;

    _ref = data.numbers;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      n = _ref[_i];
      numStr = n.num.toString();
      user = this.usersByNumber[numStr];
      if (user) {
        dep = null;
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
      this.panelEl.data('width', w);
      this.panelEl.data('hided', false);
      this.panelEl.css({
        display: ''
      });
      if (notAnimate) {
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
      user;      if (user) {
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
        this.dropdownEl.children('li:first').addClass('g_first');
        this.dropdownEl.children('li:last').addClass('g_last');
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
    this.setAbonentsHtml();
    return this.setUserListHeight();
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
    this.scrollContent.children().detach();
    this.scrollContent.html(allDeps);
    if (allDeps.length > 0) {
      allDeps[allDeps.length - 1].find('tr:last').addClass('g_last');
    }
    this.userScrollerToTop();
    this.setUserListHeight();
    this.initStickyHeaders();
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
