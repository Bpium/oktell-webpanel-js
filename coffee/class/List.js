// Generated by CoffeeScript 1.6.2
var List;

List = (function() {
  function List(oktell, panelEl, dropdownEl, debugMode) {
    var debouncedSetFilter, dropdownHideTimer, oktellConnected,
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
    this.debugMode = debugMode;
    this.regexps = {
      actionText: /\{\{actionText\}\}/,
      action: /\{\{action\}\}/,
      css: /\{\{css\}\}/
    };
    oktellConnected = false;
    this.usersByNumber = {};
    this.me = false;
    this.panelUsers = [];
    this.panelUsersFiltered = [];
    this.abonents = {};
    this.hold = {};
    this.oktell = oktell;
    CUser.prototype.oktell = oktell;
    this.filter = false;
    this.panelEl = panelEl;
    this.dropdownEl = dropdownEl;
    this.dropdownElLiTemplate = this.dropdownEl.html();
    this.dropdownEl.empty();
    this.usersListEl = this.panelEl.find('.b_main_list tbody');
    this.abonentsListEl = this.panelEl.find('.j_abonents tbody');
    this.abonentsListBlock = this.panelEl.find('.j_abonents');
    this.holdListEl = this.panelEl.find('.j_hold tbody');
    this.holdBlockEl = this.panelEl.find('.j_hold');
    this.queueListEl = this.panelEl.find('.j_queue tbody');
    this.queueBlockEl = this.panelEl.find('.j_queue');
    this.filterInput = this.panelEl.find('input');
    debouncedSetFilter = false;
    this.filterInput.bind('keydown', function(e) {
      if (!debouncedSetFilter) {
        debouncedSetFilter = debounce(function() {
          return _this.setFilter(_this.filterInput.val());
        }, 100);
      }
      if (e.keyCode === 13) {
        _this.filterInput.blur();
        setTimeout(function() {
          var user;

          user = _this.panelUsersFiltered[0];
          user.doLastFirstAction();
          _this.filterInput.val('');
          return _this.setFilter('');
        }, 50);
      } else {
        debouncedSetFilter();
      }
      return true;
    });
    this.panelEl.on('mouseenter', '.b_contact', function() {
      var _ref;

      return (_ref = $(this).data('user')) != null ? _ref.isHovered(true) : void 0;
    });
    this.panelEl.on('mouseleave', '.b_contact', function() {
      var _ref;

      return (_ref = $(this).data('user')) != null ? _ref.isHovered(false) : void 0;
    });
    this.panelEl.on('click', '.b_contact .drop_down', function(e) {
      var dropdown, user;

      dropdown = $(e.currentTarget);
      user = dropdown.closest('.b_button_action').data('user');
      if (user) {
        return _this.showDropdown(user, dropdown.closest('.b_button_action'), user.loadOktellActions());
      }
    });
    this.dropdownEl.on('click', '[data-action]', function(e) {
      var action, actionEl, user;

      actionEl = $(e.currentTarget);
      action = actionEl.data('action');
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
        var x;

        return x = 1;
      }, 500);
    });
    oktell.on('disconnect', function() {
      return oktellConnected = false;
    });
    oktell.on('connect', function() {
      var oId, oInfo, oUser, oUsers, user, _ref;

      oktellConnected = true;
      oInfo = oktell.getMyInfo();
      oInfo.userid = oInfo.userid.toString().toLowerCase();
      _this.myNumber = (_ref = oInfo.number) != null ? _ref.toString() : void 0;
      CUser.prototype.defaultAvatar = oInfo.defaultAvatar;
      CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32;
      CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64;
      oUsers = oktell.getUsers();
      for (oId in oUsers) {
        oUser = oUsers[oId];
        user = new CUser(oUser);
        if (user.number) {
          _this.usersByNumber[user.number] = user;
        }
        if (user.id !== oInfo.userid) {
          _this.panelUsers.push(user);
        } else {
          _this.me = user;
        }
      }
      _this.sortPanelUsers(_this.panelUsers);
      oktell.on('stateChange', function(newState, oldState) {
        return _this.reloadActions();
      });
      oktell.onNativeEvent('pbxnumberstatechanged', function(data) {
        var n, numStr, _i, _len, _ref1, _ref2, _results;

        _ref1 = data.numbers;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          n = _ref1[_i];
          numStr = n.num.toString();
          _results.push((_ref2 = _this.usersByNumber[numStr]) != null ? _ref2.setState(n.numstateid) : void 0);
        }
        return _results;
      });
      oktell.on('abonentsChange', function(abonents) {
        return _this.setAbonents(abonents);
      });
      oktell.on('holdStateChange', function(holdInfo) {
        return _this.setHold(holdInfo);
      });
      _this.setAbonents(oktell.getAbonents());
      _this.setHold(oktell.getHoldInfo());
      _this.setFilter('');
      setInterval(function() {
        if (oktellConnected) {
          return oktell.getQueue(function(data) {
            if (data.result) {
              return _this.setQueue(data.queue);
            }
          });
        }
      }, debugMode ? 999999999 : 5000);
      if (typeof afterOktellConnect === 'function') {
        return afterOktellConnect();
      }
    });
  }

  List.prototype.addEventListenersForButton = function(user, button) {
    var _this = this;

    return button.bind('click', function() {
      user;      if (user) {
        return _this.showDropdown(user, $(_this));
      }
    });
  };

  List.prototype.showDropdown = function(user, buttonEl, actions) {
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
          'top': buttonEl.offset().top,
          'left': buttonEl.offset().left - this.dropdownEl.width() + buttonEl.width(),
          'visibility': 'visible'
        });
        return this.dropdownEl.fadeIn(100);
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
          state: 5
        });
        return userlist[u.number] = u;
      }
    });
    _results = [];
    for (uNumber in userlist) {
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
    this.syncAbonentsAndUserlist(queue, this.queue);
    return this.setQueueHtml();
  };

  List.prototype.setHold = function(holdInfo) {
    var abs;

    abs = [];
    if (holdInfo.hasHold) {
      abs = [holdInfo];
    }
    this.syncAbonentsAndUserlist(abs, this.hold);
    return this.setHoldHtml();
  };

  List.prototype.setPanelUsersHtml = function(usersArray) {
    return this._setUsersHtml(usersArray, this.usersListEl);
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
      u = users[k];
      usersArray.push(u);
    }
    this._setUsersHtml(usersArray, listEl);
    if (usersArray.length && blockEl.is(':not(:visible)')) {
      return blockEl.slideDown(200);
    } else if (usersArray.length === 0 && blockEl.is(':visible')) {
      return blockEl.slideUp(200);
    }
  };

  List.prototype._setUsersHtml = function(usersArray, $el) {
    var html, u, _i, _len;

    html = [];
    for (_i = 0, _len = usersArray.length; _i < _len; _i++) {
      u = usersArray[_i];
      html.push(u.getEl());
    }
    return $el.html(html);
  };

  List.prototype.sortPanelUsers = function(usersArray) {
    return usersArray.sort(function(a, b) {
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
    });
  };

  List.prototype.setFilter = function(filter) {
    var exactMatch, filteredUsers, forFilter, oldFilter, u, _i, _len, _ref;

    if (this.filter === filter) {
      return false;
    }
    oldFilter = this.filter;
    this.filter = filter;
    if (filter === '') {
      this.panelUsersFiltered = [].concat(this.panelUsers);
      this.afterSetFilter(this.panelUsersFiltered);
      return this.panelUsersFiltered;
    }
    filteredUsers = [];
    exactMatch = false;
    if (oldFilter.indexOf(this.filter) === 0) {
      forFilter = this.panelUsersFiltered;
    } else {
      forFilter = this.panelUsers;
    }
    _ref = this.panelUsers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      u = _ref[_i];
      if (u.isFiltered(filter)) {
        filteredUsers.push(u);
        if (u.number === filter && !exactMatch) {
          exactMatch = u;
        }
      }
    }
    this.panelUsersFiltered = !exactMatch ? [
      this.getUser({
        name: filter,
        number: filter
      }, true)
    ].concat(filteredUsers) : filteredUsers;
    this.afterSetFilter(this.panelUsersFiltered);
    return this.panelUsersFiltered;
  };

  List.prototype.afterSetFilter = function(filteredUsersArray) {
    return this.setPanelUsersHtml(filteredUsersArray);
  };

  List.prototype.getUser = function(data, dontRemember) {
    var fantom, strNumber;

    if (typeof data === 'string' || typeof data === 'number') {
      strNumber = data.toString();
    } else {
      strNumber = data.number.toString();
    }
    if (this.usersByNumber[strNumber]) {
      return this.usersByNumber[strNumber];
    }
    fantom = new CUser({
      number: strNumber,
      name: data.name,
      isFantom: true,
      state: ((data != null ? data.state : void 0) != null ? data.state : 5)
    });
    if (!dontRemember) {
      this.usersByNumber[strNumber] = fantom;
    }
    return fantom;
  };

  List.prototype.reloadActions = function() {};

  return List;

})();
