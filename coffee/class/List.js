// Generated by CoffeeScript 1.6.2
var List,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

List = (function() {
  function List(oktell, panelEl, dropdownEl, afterOktellConnect, debugMode) {
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
    this.userWithGeneratedButtons = {};
    this.debugMode = debugMode;
    this.dropdownPaddingBottomLeft = 3;
    this.dropdownOpenedOnPanel = false;
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
    this.keypadEl = this.panelEl.find('.j_phone_keypad');
    this.keypadIsVisible = false;
    this.usersListBlockEl = this.panelEl.find('.j_main_list');
    this.usersListEl = this.usersListBlockEl.find('tbody');
    this.abonentsListBlock = this.panelEl.find('.j_abonents');
    this.abonentsListEl = this.abonentsListBlock.find('tbody');
    this.holdBlockEl = this.panelEl.find('.j_hold');
    this.holdListEl = this.holdBlockEl.find('tbody');
    this.queueBlockEl = this.panelEl.find('.j_queue');
    this.queueListEl = this.queueBlockEl.find('tbody');
    this.filterInput = this.panelEl.find('input');
    this.filterClearCross = this.panelEl.find('.jInputClear_close');
    debouncedSetFilter = false;
    this.addScroll();
    this.filterClearCross.bind('click', function() {
      return _this.clearFilter();
    });
    this.filterInput.bind('keyup', function(e) {
      if (!debouncedSetFilter) {
        debouncedSetFilter = debounce(function() {
          return _this.setFilter(_this.filterInput.val());
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
        return _this.showDropdown(user, dropdown.closest('.b_button_action'), user.loadOktellActions(), true);
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
      return _this.filterInput.keydown();
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

  List.prototype.getUserButtonForPlagin = function(phone) {
    var button, user,
      _this = this;

    user = this.getUser(phone);
    this.userWithGeneratedButtons[phone] = user;
    button = user.getButtonEl();
    button.find('.drop_down').bind('click', function() {
      return _this.showDropdown(user, button, user.loadOktellActions());
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
        return this.keypadEl.slideDown(200);
      } else {
        return this.keypadEl.slideUp(200);
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

  List.prototype.reloadActions = function() {
    var _this = this;

    return setTimeout(function() {
      var phone, user, _i, _len, _ref, _results;

      _ref = _this.userWithGeneratedButtons;
      _results = [];
      for (user = _i = 0, _len = _ref.length; _i < _len; user = ++_i) {
        phone = _ref[user];
        _results.push(user.loadActions());
      }
      return _results;
    }, 100);
  };

  List.prototype.addScroll = function() {
    var $el, END_EVENT, MOVE_EVENT, START_EVENT, WHEEL_EV, get_koef, get_pageY, get_position, init, isTouch, jscroll_timer, move_by_bar, pageY_end, pageY_start, params, pos, pos_start, scrollClick, scrollTo, scrollWheelPos, scroll_hide, scroll_show, scrollbar_cont, scrollbar_inner, scroller, scroller_left_while_scrolling, scrolling, set_bar_bounds, set_position, vendor, wrapper,
      _this = this;

    $el = this.usersListBlockEl;
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
      var myScroll, scrollbar_bar, scroller_inner;

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
      if (isTouch) {
        scroller.after('<div class="jscroll_scroller_inner" />');
        scroller_inner = $(".jscroll_scroller_inner", wrapper);
        scroller_inner.appendTo('<div></div>');
        myScroll = new iScroll(wrapper.attr("id"), {
          hScrollbar: false,
          scrollbarClass: 'jscroll_scroller_inner',
          checkDOMChanges: true,
          bounceLock: true,
          onScrollMove: function() {
            params.onScroll();
            return true;
          },
          onScrollEnd: function() {
            params.onScroll();
            return true;
          }
        });
        return true;
      } else {
        return set_bar_bounds(wrapper, scroller, scrollbar_cont, scrollbar_inner);
      }
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

  return List;

})();
