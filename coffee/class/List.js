// Generated by CoffeeScript 1.6.2
var List,
  __hasProp = {}.hasOwnProperty;

List = (function() {
  function List(oktell, panelEl, dropdownEl, afterOktellConnect, debugMode) {
    var debouncedSetFilter, debouncedSetHeight, dropdownHideTimer, oktellConnected,
      _this = this;

    this.allActions = {
      call: {
        icon: '/img/icons/action/call.png',
        iconWhite: '/img/icons/action/white/call.png',
        text: this.langs.call
      },
      conference: {
        icon: '/img/icons/action/confinvite.png',
        iconWhite: '/img/icons/action/white/confinvite.png',
        text: this.langs.conference
      },
      transfer: {
        icon: '/img/icons/action/transfer.png',
        text: this.langs.transfer
      },
      toggle: {
        icon: '/img/icons/action/toggle.png',
        text: this.langs.toggle
      },
      intercom: {
        icon: '/img/icons/action/intercom.png',
        text: this.langs.intercom
      },
      endCall: {
        icon: '/img/icons/action/endcall.png',
        iconWhite: '/img/icons/action/white/endcall.png',
        text: this.langs.endCall
      },
      ghostListen: {
        icon: '/img/icons/action/ghost_monitor.png',
        text: this.langs.ghostListen
      },
      ghostHelp: {
        icon: '/img/icons/action/ghost_help.png',
        text: this.langs.ghostHelp
      }
    };
    this.actionCssPrefix = 'i_';
    this.lastDropdownUser = false;
    this.usersShowRules();
    this.departments = [];
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
    this.usersListEl = this.usersListBlockEl.find('tbody');
    this.abonentsListBlock = this.panelEl.find('.j_abonents');
    this.abonentsListEl = this.abonentsListBlock.find('tbody');
    this.talkTimeEl = this.abonentsListBlock.find('.b_marks_time');
    this.holdBlockEl = this.panelEl.find('.j_hold');
    this.holdListEl = this.holdBlockEl.find('tbody');
    this.queueBlockEl = this.panelEl.find('.j_queue');
    this.queueListEl = this.queueBlockEl.find('tbody');
    this.filterInput = this.panelEl.find('input');
    this.filterClearCross = this.panelEl.find('.jInputClear_close');
    debouncedSetFilter = false;
    this.usersWithBeforeConnectButtons = [];
    this.jScroll(this.usersListBlockEl);
    this.usersScroller = this.usersListBlockEl.find('.jscroll_scroller');
    this.userScrollerToTop = function() {
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
          var user;

          user = _this.panelUsersFiltered[0];
          user.doLastFirstAction();
          return _this.clearFilter();
        }, 50);
      } else {
        debouncedSetFilter();
      }
      return true;
    });
    this.panelEl.bind('mouseenter', function() {
      var _ref;

      return (_ref = $(this).data('user')) != null ? _ref.isHovered(true) : void 0;
    });
    this.panelEl.bind('mouseleave', function() {
      var _ref;

      return (_ref = $(this).data('user')) != null ? _ref.isHovered(false) : void 0;
    });
    this.panelEl.bind('click', function(e) {
      var buttonEl, target, user;

      target = $(e.target);
      if (!target.is('.b_contact .drop_down') && target.closest('.b_contact .drop_down').size() === 0) {
        return true;
      }
      buttonEl = target.closest('.oktell_button_action');
      if (buttonEl.size() === 0) {
        return true;
      }
      user = buttonEl.data('user');
      if (user) {
        return _this.showDropdown(user, buttonEl, user.loadOktellActions(), true);
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
        return _this.dropdownEl.fadeOut(150, function() {
          return _this.dropdownOpenedOnPanel = false;
        });
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
      return _this.usersListBlockEl.css({
        height: $(window).height() - _this.usersListBlockEl[0].offsetTop + 'px'
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
    oktell.on('disconnect', function() {
      var phone, user, _ref, _results;

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
      var createdDeps, d, dep, depsEls, oId, oInfo, oUser, oUsers, otherDep, strNumber, user, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4;

      _this.oktellConnected = true;
      oInfo = oktell.getMyInfo();
      oInfo.userid = oInfo.userid.toString().toLowerCase();
      _this.myNumber = (_ref = oInfo.number) != null ? _ref.toString() : void 0;
      CUser.prototype.defaultAvatar = oInfo.defaultAvatar;
      CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32;
      CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64;
      _this.departments = [];
      createdDeps = {};
      otherDep = new Department();
      oUsers = oktell.getUsers();
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
          if (((_ref2 = user.numberObj) != null ? _ref2.departmentid : void 0) && user.numberObj.departmentid !== '00000000-0000-0000-0000-000000000000') {
            dep = createdDeps[user.numberObj.departmentid] || (createdDeps[user.numberObj.departmentid] = new Department(user.numberObj.departmentid, user.numberObj.department));
            dep.addUser(user);
            _this.departments.push(deps);
          } else {
            otherDep.addUser(user);
          }
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
      _this.sortPanelUsers(_this.panelUsers);
      oktell.on('stateChange', function(newState, oldState) {
        return _this.reloadActions();
      });
      oktell.onNativeEvent('pbxnumberstatechanged', function(data) {
        var n, numStr, _i, _len, _ref3, _ref4, _results;

        _ref3 = data.numbers;
        _results = [];
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          n = _ref3[_i];
          numStr = n.num.toString();
          _results.push((_ref4 = _this.usersByNumber[numStr]) != null ? _ref4.setState(n.numstateid) : void 0);
        }
        return _results;
      });
      oktell.on('abonentsChange', function(abonents) {
        _this.setAbonents(abonents);
        return _this.reloadActions();
      });
      oktell.on('holdStateChange', function(holdInfo) {
        _this.setHold(holdInfo);
        return _this.reloadActions();
      });
      oktell.on('talkTimer', function(seconds, formattedTime) {
        if (seconds === false) {
          return _this.talkTimeEl.text('');
        } else {
          return _this.talkTimeEl.text(formattedTime);
        }
      });
      _this.setAbonents(oktell.getAbonents());
      _this.setHold(oktell.getHoldInfo());
      depsEls = $();
      _ref3 = _this.departments;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        d = _ref3[_i];
        depsEls = depsEls.add(d.getEl());
      }
      _this.usersListBlockEl.html(depsEls);
      _this.setFilter('', true);
      oktell.on('queueChange', function(queue) {
        return _this.setQueue(queue);
      });
      oktell.getQueue(function(data) {
        if (data.result) {
          return _this.setQueue(data.queue);
        }
      });
      _ref4 = _this.usersWithBeforeConnectButtons;
      for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
        user = _ref4[_j];
        user.loadActions();
      }
      if (typeof afterOktellConnect === 'function') {
        return afterOktellConnect();
      }
    });
  }

  List.prototype.usersShowRules = function(showOffline, showDeps) {
    var showDepsKey, showOfflineKey;

    showOfflineKey = 'oktell-panel-show-offline-users';
    showDepsKey = 'oktell-panel-show-departments';
    this.showOffline = showOffline != null ? showOffline : (cookie(showOfflineKey) != null ? cookie(showOfflineKey) : true);
    this.showDeps = showDeps != null ? showDeps : (cookie(showDepsKey) != null ? cookie(showDepsKey) : true);
    cookie(showOfflineKey, this.showOffline, {
      path: '/',
      expires: 1209600
    });
    cookie(showDepsKey, this.showDeps, {
      path: '/',
      expires: 1209600
    });
    return [this.showOffline, this.showDeps];
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
        return this.keypadEl.slideDown(200, this.setUserListHeight);
      } else {
        return this.keypadEl.slideUp(200, this.setUserListHeight);
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
      _results.push(log(u.getInfo()));
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
      abs = [holdInfo.abonent];
    }
    this.syncAbonentsAndUserlist(abs, this.hold);
    return this.setHoldHtml();
  };

  List.prototype.setPanelUsersHtml = function(usersArray) {
    this._setUsersHtml(usersArray, this.usersListEl, this.showOffline, this.showDeps);
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
    this._setUsersHtml(usersArray, listEl);
    if (usersArray.length && blockEl.is(':not(:visible)')) {
      return blockEl.slideDown(200, this.setUserListHeight);
    } else if (usersArray.length === 0 && blockEl.is(':visible')) {
      return blockEl.slideUp(200, this.setUserListHeight);
    }
  };

  List.prototype._setUsersHtml = function(usersArray, $el, showOffline, showDeps) {
    var depEl, depEls, html, lastDepId, u, uEl;

    html = [];
    lastDepId = null;
    depEls = (function() {
      var _i, _len, _results;

      _results = [];
      for (_i = 0, _len = usersArray.length; _i < _len; _i++) {
        u = usersArray[_i];
        uEl = null;
        if (showOffline || (!showOffline && u.state !== 0)) {
          uEl = u.getEl();
        }
        if (uEl && showDeps && u.departmentId && u.departmentId !== lastDepId) {
          depEl = $(this.depTemplates[u.departmentId] || (this.depTemplates[u.departmentId] = this.departmentTemplate.replace(this.regexps.dep, u.department)));
          depEls.push(depEl);
          html.push(depEl);
        }
        lastDepId = u.departmentId;
        if (uEl) {
          _results.push(html.push(uEl));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }).call(this);
    return $el.html(html);
  };

  List.prototype.sortPanelUsers = function(usersArray) {
    var _this = this;

    return usersArray.sort(function(a, b) {
      if (a.departmentId === _this.withoutDepName && b.departmentId !== _this.withoutDepName) {
        return 1;
      } else if (b.departmentId === _this.withoutDepName && a.departmentId !== _this.withoutDepName) {
        return -1;
      } else {
        if (a.department > b.department) {
          return 1;
        } else if (b.department > a.department) {
          return -1;
        } else {
          if (a.number && !b.number) {
            return -1;
          } else if (!a.number && b.number) {
            return 1;
          } else {
            if (a.state && !b.state) {
              return -1;
            } else if (!a.state && b.state) {
              return 1;
            } else {
              if (a.name > b.name) {
                return 1;
              } else if (a.name < b.name) {
                return -1;
              }
            }
          }
        }
      }
    });
  };

  List.prototype.setFilter = function(filter, reloadAnyway) {
    var dep, el, exactMatch, filteredUsers, oldFilter, u, users, _i, _j, _len, _len1, _ref, _ref1, _results;

    if (this.filter === filter && !reloadAnyway) {
      return false;
    }
    oldFilter = this.filter;
    this.filter = filter;
    if (this.showDeps) {
      _ref = this.departments;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dep = _ref[_i];
        el = dep.getEl();
        _results.push(users = dep.getUsers(filter));
      }
      return _results;
    } else {
      if (filter === '') {
        this.panelUsersFiltered = [].concat(this.panelUsers);
        this.afterSetFilter(this.panelUsersFiltered);
        return this.panelUsersFiltered;
      }
      filteredUsers = [];
      exactMatch = false;
      _ref1 = this.panelUsers;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        u = _ref1[_j];
        if (u.isFiltered(filter)) {
          filteredUsers.push(u);
          if (u.number === filter && !exactMatch) {
            exactMatch = u;
          }
        }
      }
      if (!exactMatch && filter.match(/[0-9\(\)\+\-]/)) {
        this.filterFantomUser = this.getUser({
          name: filter,
          number: filter
        }, true);
        this.panelUsersFiltered = [this.filterFantomUser].concat(filteredUsers);
      } else {
        this.panelUsersFiltered = filteredUsers;
      }
      this.afterSetFilter(this.panelUsersFiltered);
      return this.panelUsersFiltered;
    }
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

  return List;

})();
