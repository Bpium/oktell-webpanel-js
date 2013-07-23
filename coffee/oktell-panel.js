// Generated by CoffeeScript 1.6.2
var __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function($) {
  var actionButtonContainerClass, actionButtonHtml, actionListEl, actionListHtml, addActionButtonToEl, afterOktellConnect, defaultOptions, departmentTemplateHtml, error, errorHtml, getOptions, hasTouch, initActionButtons, initButtonOnElement, initPanel, isAndroid, isIDevice, isTouchPad, langs, list, loadTemplate, log, logStr, oktell, oktellConnected, options, panelHtml, panelWasInitialized, permissionsPopup, permissionsPopupHtml, popup, popupHtml, templates, userTemplateHtml, usersTableHtml,
    _this = this;

  if (!$) {
    throw new Error('Error init oktell panel, jQuery ( $ ) is not defined');
  }
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
        dtmf: 'донабор',
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
        dtfm: 'ext',
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
        dtmf: 'ext',
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
  templates = {};
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
    var $user, $userActionButton, animOptHide, animOptShow, bookmarkAnimOptHide, bookmarkAnimOptShow, bookmarkPos, errorEl, hidePanel, killPanelHideTimer, maxPosClose, minPosOpen, mouseOnPanel, oldBinding, pageX, panelBookmarkEl, panelEl, panelHideTimer, panelMinPos, panelPos, panelStatus, permissionsPopupEl, popupEl, showPanel, touchClickedContact, touchClickedContactClear, touchClickedCss, touchMoving, _panelStatus,
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
    if (hasTouch) {
      panelEl.addClass('touch');
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
    panelMinPos = -281;
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
    _panelStatus = 'closed';
    panelStatus = function(st) {
      if (st && st !== _panelStatus) {
        _panelStatus = st;
      }
      return _panelStatus;
    };
    killPanelHideTimer = function() {
      clearTimeout(panelHideTimer);
      return panelHideTimer = false;
    };
    showPanel = function() {
      panelStatus('opening');
      panelBookmarkEl.css(bookmarkAnimOptShow);
      panelEl.stop(true, true);
      return panelEl.animate(animOptShow, 100, "swing", function() {
        panelEl.addClass("g_hover");
        panelStatus('open');
        return panelBookmarkEl.css(bookmarkAnimOptShow);
      });
    };
    panelEl.bind("mouseenter", function() {
      mouseOnPanel = true;
      killPanelHideTimer();
      if (parseInt(panelEl.css(panelPos)) < 0 && (panelStatus() === 'closed' || panelStatus() === 'closing')) {
        showPanel();
      }
      return true;
    });
    pageX = false;
    minPosOpen = -250;
    maxPosClose = 30;
    touchMoving = false;
    panelBookmarkEl.bind('touchstart', function() {
      if (panelStatus() === 'closed') {
        return panelStatus('touchopening');
      } else if (panelStatus() === 'open') {
        return panelStatus('touchclosing');
      }
    });
    panelBookmarkEl.bind('touchmove', function(e) {
      var pos, t, _ref, _ref1;

      if (panelStatus() === 'touchopening' || panelStatus() === 'touchclosing') {
        touchMoving = true;
      }
      if (touchMoving) {
        t = e != null ? (_ref = e.originalEvent) != null ? (_ref1 = _ref.touches) != null ? _ref1[0] : void 0 : void 0 : void 0;
        if (t) {
          if (pageX !== false) {
            pos = parseInt(panelEl.css(panelPos));
            panelEl.css(panelPos, Math.max(panelMinPos, Math.min(0, pos + pageX - t.pageX)) + 'px');
          }
          return pageX = t.pageX;
        }
      }
    });
    panelBookmarkEl.bind('touchend', function() {
      var pos;

      if (!touchMoving) {
        if (panelStatus() === 'touchopening') {
          return showPanel();
        }
      } else {
        touchMoving = false;
        pos = parseInt(panelEl.css(panelPos));
        if (panelStatus() === 'touchopening') {
          if (pos > minPosOpen) {
            return showPanel();
          } else {
            return hidePanel();
          }
        } else if (panelStatus() === 'touchclosing') {
          if (pos < maxPosClose) {
            return hidePanel();
          } else {
            return openPanel();
          }
        }
      }
    });
    panelBookmarkEl.bind('touchcancel', function() {});
    touchClickedContact = null;
    touchClickedCss = 'm_touch_clicked';
    touchClickedContactClear = function() {
      if (touchClickedContact != null) {
        touchClickedContact.removeClass(touchClickedCss);
      }
      return touchClickedContact = null;
    };
    $(window).bind('touchcancel', function(e) {});
    $(window).bind('touchend', function(e) {
      var parents, parentsArr, target;

      target = $(e.target);
      parents = target.parents();
      parentsArr = parents.toArray();
      if (parentsArr.indexOf(panelEl[0]) === -1) {
        return hidePanel();
      }
    });
    panelEl.bind('touchend', function(e) {
      var contact, parents, parentsArr, target;

      target = $(e.target);
      parents = target.parents();
      parentsArr = parents.toArray();
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
      panelStatus('closing');
      panelEl.stop(true, true);
      return panelEl.animate(animOptHide, 300, "swing", function() {
        panelEl.css({
          panelPos: 0
        });
        panelEl.removeClass("g_hover");
        panelBookmarkEl.css(bookmarkAnimOptHide);
        return panelStatus('closed');
      });
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
