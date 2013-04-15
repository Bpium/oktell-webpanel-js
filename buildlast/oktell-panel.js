var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty;

(function($) {
  var CUser, List, Popup, actionButtonHtml, actionListEl, actionListHtml, addActionButtonToEl, afterOktellConnect, debounce, defaultOptions, escapeHtml, getOptions, initActionButtons, initButtonOnElement, initPanel, jScroll, langs, list, loadTemplate, log, oktell, oktellConnected, options, panelHtml, panelWasInitialized, popup, popupHtml, templates, userTemplateHtml;

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
        if (window.iScroll != null) {
          myScroll = new window.iScroll(wrapper.attr("id"), {
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
        }
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
  CUser = (function() {
    function CUser(data) {
      this.doAction = __bind(this.doAction, this);
      var _ref, _ref1, _ref2;

      this.id = (_ref = data.id) != null ? _ref.toString().toLowerCase() : void 0;
      this.isFantom = data.isFantom || false;
      this.number = ((_ref1 = data.number) != null ? _ref1.toString() : void 0) || '';
      this.numberFormatted = ((_ref2 = data.numberFormatted) != null ? _ref2.toString() : void 0) || this.number;
      this.numberHtml = escapeHtml(this.numberFormatted);
      this.name = data.name;
      this.nameHtml = data.name ? escapeHtml(data.name) : this.numberHtml;
      this.state = false;
      this.avatarLink32x32 = data.avatarLink32x32 || this.defaultAvatar32 || '';
      this.defaultAvatarCss = this.avatarLink32x32 ? '' : 'm_default';
      this.hasHover = false;
      this.buttonLastAction = '';
      this.firstLiCssPrefix = 'm_button_action_';
      this.els = $();
      this.buttonEls = $();
      this.init(data);
    }

    CUser.prototype.init = function(data) {
      var _ref, _ref1, _ref2, _ref3;

      this.id = (_ref = data.id) != null ? _ref.toString().toLowerCase() : void 0;
      this.isFantom = data.isFantom || false;
      this.number = ((_ref1 = data.number) != null ? _ref1.toString() : void 0) || '';
      this.numberFormatted = ((_ref2 = data.numberFormatted) != null ? _ref2.toString() : void 0) || this.number;
      this.numberHtml = escapeHtml(this.numberFormatted);
      this.name = data.name;
      this.nameHtml = data.name && data.name.toString() !== this.number ? escapeHtml(data.name) : this.numberHtml;
      this.avatarLink32x32 = data.avatarLink32x32 || this.defaultAvatar32 || '';
      this.defaultAvatarCss = this.avatarLink32x32 ? '' : 'm_default';
      this.loadActions();
      if (((_ref3 = data.numberObj) != null ? _ref3.state : void 0) != null) {
        return this.setState(data.numberObj.state);
      } else if (data.state != null) {
        return this.setState(data.state);
      } else {
        return this.setState(1);
      }
    };

    CUser.prototype.regexps = {
      name: /\{\{name\}\}/,
      number: /\{\{number\}\}/,
      avatarLink32x32: /\{\{avatarLink32x32\}\}/,
      css: /\{\{css\}\}/
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

    CUser.prototype.isFiltered = function(filter) {
      if (!filter || typeof filter !== 'string') {
        return true;
      }
      if ((this.number && this.number.indexOf(filter) !== -1) || (' ' + this.name).toLowerCase().indexOf(filter) !== -1) {
        return true;
      }
      return false;
    };

    CUser.prototype.getEl = function() {
      var $el, str;

      str = this.template.replace(this.regexps.name, this.nameHtml).replace(this.regexps.number, this.numberHtml !== this.nameHtml ? this.numberHtml : '').replace(this.regexps.avatarLink32x32, this.avatarLink32x32).replace(this.regexps.css, this.defaultAvatarCss);
      $el = $(str);
      this.els = this.els.add($el);
      this.setStateCss();
      $el.data('user', this);
      this.initButtonEl($el.find('.oktell_button_action'));
      return $el;
    };

    CUser.prototype.initButtonEl = function($el) {
      var _this = this;

      this.buttonEls = this.buttonEls.add($el);
      $el.data('user', this);
      $el.children(':first').bind('click', function() {
        return _this.doAction(_this.buttonLastAction);
      });
      if (this.buttonLastAction) {
        return $el.addClass(this.firstLiCssPrefix + this.buttonLastAction.toLowerCase());
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
        return this.loadActions();
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
        this.buttonEls.addClass(this.firstLiCssPrefix + this.buttonLastAction.toLowerCase());
      } else {
        this.buttonLastAction = '';
      }
      return actions;
    };

    CUser.prototype.doAction = function(action) {
      var target;

      if (!action) {
        return;
      }
      target = this.number;
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

    return CUser;

  })();
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
      this.filterFantomUserNumber = false;
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
        var oId, oInfo, oUser, oUsers, strNumber, user, _i, _len, _ref, _ref1, _ref2;

        _this.oktellConnected = true;
        oInfo = oktell.getMyInfo();
        oInfo.userid = oInfo.userid.toString().toLowerCase();
        _this.myNumber = (_ref = oInfo.number) != null ? _ref.toString() : void 0;
        CUser.prototype.defaultAvatar = oInfo.defaultAvatar;
        CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32;
        CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64;
        oUsers = oktell.getUsers();
        for (oId in oUsers) {
          if (!__hasProp.call(oUsers, oId)) continue;
          oUser = oUsers[oId];
          strNumber = ((_ref1 = oUser.number) != null ? _ref1.toString() : void 0) || '';
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
          } else {
            _this.me = user;
          }
        }
        _this.sortPanelUsers(_this.panelUsers);
        oktell.on('stateChange', function(newState, oldState) {
          return _this.reloadActions();
        });
        oktell.onNativeEvent('pbxnumberstatechanged', function(data) {
          var n, numStr, _i, _len, _ref2, _ref3, _results;

          _ref2 = data.numbers;
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            n = _ref2[_i];
            numStr = n.num.toString();
            _results.push((_ref3 = _this.usersByNumber[numStr]) != null ? _ref3.setState(n.numstateid) : void 0);
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
        _this.setFilter('', true);
        oktell.on('queueChange', function(queue) {
          return _this.setQueue(queue);
        });
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
        if (typeof afterOktellConnect === 'function') {
          return afterOktellConnect();
        }
      });
    }

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
      this._setUsersHtml(usersArray, listEl);
      if (usersArray.length && blockEl.is(':not(:visible)')) {
        return blockEl.slideDown(200, this.setUserListHeight);
      } else if (usersArray.length === 0 && blockEl.is(':visible')) {
        return blockEl.slideUp(200, this.setUserListHeight);
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

    List.prototype.setFilter = function(filter, reloadAnyway) {
      var exactMatch, filteredUsers, forFilter, oldFilter, u, _i, _len, _ref;

      if (this.filter === filter && !reloadAnyway) {
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
      if (!exactMatch) {
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
  Popup = (function() {
    function Popup(popupEl, oktell) {
      var _this = this;

      this.el = popupEl;
      this.absContainer = this.el.find('.b_content');
      this.abonentEl = this.absContainer.find('.b_abonent').remove();
      this.isBack101 = false;
      this.el.find('.j_abort_action').bind('click', function() {
        _this.hide();
        return oktell.endCall();
      });
      this.el.find('.j_close_action').bind('click', function() {
        return _this.hide();
      });
      this.el.find('i.o_close').bind('click', function() {
        return _this.hide();
      });
      oktell.on('ringStart', function(abonents) {
        if (!_this.isBack101) {
          _this.setAbonents(abonents);
        }
        return _this.show();
      });
      oktell.on('ringStop', function() {
        _this.isBack101 = false;
        return _this.hide();
      });
    }

    Popup.prototype.show = function() {
      return this.el.fadeIn(200);
    };

    Popup.prototype.hide = function() {
      this.el.fadeOut(200);
      return this.isBack101 = false;
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

    return Popup;

  })();
  defaultOptions = {
    position: 'right',
    dynamic: false,
    oktell: window.oktell,
    debug: false,
    lang: 'ru'
  };
  langs = {
    ru: {
      panel: {
        inTalk: 'В разговоре',
        onHold: 'На удержании',
        queue: 'Очередь ожидания',
        inputPlaceholder: 'введите имя или номер'
      },
      actions: {
        call: 'Позвонить',
        conference: 'Конференция',
        transfer: 'Перевести',
        toggle: 'Переключиться',
        intercom: 'Интерком',
        endCall: 'Завершить',
        ghostListen: 'Прослушка',
        ghostHelp: 'Помощь'
      }
    },
    en: {
      panel: {
        inTalk: 'In conversation',
        onHold: 'On hold',
        queue: 'Wait queue',
        inputPlaceholder: 'Enter name or number'
      },
      actions: {
        call: 'Dial',
        conference: 'Conference',
        transfer: 'Transfer',
        toggle: 'Switch',
        intercom: 'Intercom',
        endCall: 'End',
        ghostListen: 'Audition',
        ghostHelp: 'Help'
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
  getOptions = function() {
    return options || defaultOptions;
  };
  log = function() {
    var e;

    if (!getOptions().debug) {
      return;
    }
    try {
      return console.log.apply(console, arguments);
    } catch (_error) {
      e = _error;
    }
  };
  templates = {
    'templates/actionButton.html': '<ul class="oktell_button_action"><li class="g_first"><i></i></li><li class="g_last drop_down"><i></i></li></ul>',
    'templates/actionList.html': '<ul class="oktell_actions_group_list"><li class="{{css}}" data-action="{{action}}"><i></i><span>{{actionText}}</span></li></ul>',
    'templates/user.html': '<tr class="b_contact"><td class="b_contact_avatar {{css}}"><img src="{{avatarLink32x32}}"><i></i><div class="o_busy"></div></td><td class="b_contact_title"><div class="wrapword"><a><b>{{name}}</b><span class="o_number">{{number}}</span></a></div>{{button}}</td></tr>',
    'templates/panel.html': '<div class="oktell_panel"><div class="i_panel_bookmark"><div class="i_panel_bookmark_bg"></div></div><div class="h_panel_bg"><div class="h_padding"><div class="b_marks i_conference j_abonents"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{inTalk}}</span><span class="b_marks_time"></span></p><table><tbody></tbody></table></div></div><div class="b_marks i_flash j_hold"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{onHold}}</span></p><table class="j_table_favorite"><tbody></tbody></table></div></div><div class="b_marks i_flash j_queue"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{queue}}</span></p><table class="j_table_queue"><tbody></tbody></table></div></div><div class="b_inconversation j_phone_block"><table class="j_table_phone"><tbody></tbody></table></div><div class="b_marks i_phone"><div class="h_shadow_bottom"><div class="h_phone_number_input"><div class="i_phone_state_bg"></div><div class="h_input_padding"><div class="i_phone_popup_button j_keypad_expand"><i></i></div><div class="jInputClear_hover"><input class="b_phone_number_input" type="text" placeholder="{{inputPlaceholder}}"><span class="jInputClear_close">&times;</span></div></div><div class="b_phone_keypad j_phone_keypad"><div class="l_column_group"><div class="h_phone_keypad"><ul class="b_phone_panel"><li class="g_top_left g_first"><button data-num="1" class="g_button m_big">1</button></li><li><button data-num="2" class="g_button m_big">2</button></li><li class="g_top_right g_right"><button data-num="3" class="g_button m_big">3</button></li><li class="g_float_celar g_first"><button data-num="4" class="g_button m_big">4</button></li><li><button data-num="5" class="g_button m_big">5</button></li><li class="g_right"><button data-num="6" class="g_button m_big">6</button></li><li class="g_float_celar g_first"><button data-num="7" class="g_button m_big">7</button></li><li><button data-num="8" class="g_button m_big">8</button></li><li class="g_right"><button data-num="9" class="g_button m_big">9</button></li><li class="g_bottom_left g_float_celar g_first"><button data-num="*" class="g_button m_big">&lowast;</button></li><li class="g_bottom_center"><button data-num="0" class="g_button m_big">0</button></li><li class="g_bottom_right g_right"><button data-num="#" class="g_button m_big">#</button></li></ul></div></div></div></div></div></div><div class="h_main_list j_main_list"><table class="b_main_list"><tbody></tbody></table></div></div></div></div>',
    'templates/callPopup.html': '<div class="oktell_panel_popup" style="display: none"><div class="m_popup_staff"><div class="m_popup_data"><header><div class="h_header_bg"><i class="o_close"></i><h2>Входящий вызов</h2></div></header><div class="b_content"><div class="b_abonent"><span data-bind="text: name"></span>&nbsp;<span class="g_light" data-bind="textPhone: number"></span></div></div><div class="footer"><div class="b_take_phone"><i></i>&nbsp;<span>Поднимите трубку</span></div><button class="oktell_panel_btn m_big j_close_action">Скрыть</button><button class="oktell_panel_btn m_big m_button_red j_abort_action"><i></i>Отклонить</button></div></div></div></div>'
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
  panelHtml = loadTemplate('/templates/panel.html');
  popupHtml = loadTemplate('/templates/callPopup.html');
  List.prototype.jScroll = jScroll;
  CUser.prototype.buttonTemplate = actionButtonHtml;
  CUser.prototype.log = log;
  panelWasInitialized = false;
  initPanel = function(opts) {
    var $user, $userActionButton, animOptHide, animOptShow, bookmarkAnimOptHide, bookmarkAnimOptShow, bookmarkPos, closeClass, critWidth, cssPos, element, elementWidth, hidePanel, killPanelHideTimer, mouseOnPanel, newCssPos, oldBinding, openClass, panelBookmarkEl, panelEl, panelHideTimer, panelPos, panelStatus, popupEl, walkAway, xPos, xStartPos;

    panelWasInitialized = true;
    options = $.extend(defaultOptions, opts || {});
    langs = langs[options.lang] || langs.ru;
    CUser.prototype.template = userTemplateHtml.replace('{{button}}', actionButtonHtml);
    panelHtml = panelHtml.replace('{{inTalk}}', langs.panel.inTalk).replace('{{onHold}}', langs.panel.onHold).replace('{{queue}}', langs.panel.queue).replace('{{inputPlaceholder}}', langs.panel.inputPlaceholder);
    List.prototype.langs = langs.actions;
    panelEl = $(panelHtml);
    popupEl = $(popupHtml);
    $('body').append(popupEl);
    $user = $(userTemplateHtml);
    $userActionButton = $(actionButtonHtml);
    oldBinding = $userActionButton.attr('data-bind');
    $userActionButton.attr('data-bind', oldBinding + ', visible: $data.actionBarIsVisible');
    $user.find('td.b_contact_title').append($userActionButton);
    actionListEl = $(actionListHtml);
    $('body').append(actionListEl);
    oktell = getOptions().oktell;
    popup = new Popup(popupEl, oktell);
    panelPos = getOptions().position;
    animOptShow = {};
    animOptShow[panelPos] = '0px';
    animOptHide = {};
    animOptHide[panelPos] = '-281px';
    $("body").append(panelEl);
    list = new List(oktell, panelEl, actionListEl, afterOktellConnect, getOptions().debug);
    if (getOptions().debug) {
      window.wList = list;
      window.wPopup = popup;
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
    panelEl.on("mouseenter", function() {
      mouseOnPanel = true;
      killPanelHideTimer();
      if (parseInt(panelEl.css(panelPos)) < 0 && (panelStatus === 'closed' || panelStatus === 'closing')) {
        panelStatus = 'opening';
        panelBookmarkEl.stop(true, true);
        panelBookmarkEl.animate(bookmarkAnimOptShow, 50, 'swing');
        panelEl.stop(true, true);
        panelEl.animate(animOptShow, 100, "swing", function() {
          panelEl.addClass("g_hover");
          return panelStatus = 'open';
        });
      }
      return true;
    });
    hidePanel = function() {
      if (panelEl.hasClass("g_hover")) {
        panelStatus = 'closing';
        panelEl.stop(true, true);
        panelEl.animate(animOptHide, 300, "swing", function() {
          panelEl.css({
            panelPos: 0
          });
          panelEl.removeClass("g_hover");
          return panelStatus = 'closed';
        });
        return setTimeout(function() {
          return panelBookmarkEl.animate(bookmarkAnimOptHide, 50, 'swing');
        }, 150);
      }
    };
    panelEl.on("mouseleave", function() {
      mouseOnPanel = false;
      return true;
    });
    $('html').bind('mouseleave', function(e) {
      killPanelHideTimer();
      return true;
    });
    $('html').bind('mousemove', function(e) {
      if (!mouseOnPanel && panelHideTimer === false && !list.dropdownOpenedOnPanel) {
        panelHideTimer = setTimeout(function() {
          return hidePanel();
        }, 100);
      }
      return true;
    });
    if (window.navigator.userAgent.indexOf('iPad') !== -1) {
      xStartPos = 0;
      xPos = 0;
      element = panelEl;
      elementWidth = 0;
      critWidth = 0;
      cssPos = -281;
      walkAway = 0;
      newCssPos = 0;
      openClass = "j_open";
      closeClass = "j_close";
      if (parseInt(element[0].style.right) < 0) {
        element.addClass(closeClass);
      }
      element.live("click", function() {
        if (element.hasClass(closeClass)) {
          return element.animate(animOptShow, 200, "swing", function() {
            element.removeClass(closeClass).addClass(openClass);
            return walkAway = 0;
          });
        }
      });
      element.live("touchstart", function(e) {
        xStartPos = e.originalEvent.touches[0].pageX;
        elementWidth = element.width();
        critWidth = (elementWidth / 100) * 13;
        return cssPos = parseInt(element.css(panelPos));
      });
      element.bind("touchmove", function(e) {
        e.preventDefault();
        xPos = e.originalEvent.touches[0].pageX;
        walkAway = xPos - xStartPos;
        newCssPos = cssPos - walkAway;
        if (newCssPos < -281) {
          newCssPos = -281;
        } else if (newCssPos > 0) {
          newCssPos = 0;
        }
        return element[0].style.right = newCssPos + 'px';
      });
      element.bind("touchend", function(e) {
        if (walkAway >= critWidth && walkAway < 0) {
          return element.animate(animOptHide, 200, "swing");
        }
      });
      if (walkAway * -1 >= critWidth && walkAway > 0) {
        element.animate(animOptShow, 200, "swing");
      }
      if (walkAway < critWidth && walkAway < 0) {
        element.animate(animOptShow, 100, "swing", function() {
          return element.removeClass(closeClass).addClass(openClass);
        });
      }
      if (walkAway * -1 < critWidth && walkAway > 0) {
        return element.animate(animOptHide, 100, "swing", function() {
          return element.removeClass(openClass).addClass(closeClass);
        });
      }
    }
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
      log('generated button for ' + phone, button);
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
  return $.fn.oktellButton = function() {
    return $(this).each(function() {
      return addActionButtonToEl($(this));
    });
  };
})($);
