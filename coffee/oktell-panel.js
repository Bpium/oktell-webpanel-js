// Generated by CoffeeScript 1.6.2
var __slice = [].slice;

(function($) {
  var actionButtonHtml, actionListEl, actionListHtml, addActionButtonToEl, afterOktellConnect, defaultOptions, departmentTemplateHtml, error, errorHtml, getOptions, initActionButtons, initButtonOnElement, initPanel, langs, list, loadTemplate, log, logStr, oktell, oktellConnected, options, panelHtml, panelWasInitialized, popup, popupHtml, templates, userTemplateHtml, usersTableHtml;

  if (!$) {
    throw new Error('Error init oktell panel, jQuery ( $ ) is not defined');
  }
  defaultOptions = {
    position: 'right',
    dynamic: false,
    oktell: window.oktell,
    debug: false,
    lang: 'ru',
    noavatar: true
  };
  langs = {
    ru: {
      panel: {
        inTalk: 'В разговоре',
        onHold: 'На удержании',
        queue: 'Очередь ожидания',
        inputPlaceholder: 'введите имя или номер',
        withoutDepartment: 'без отдела'
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
      },
      callPopup: {
        title: 'Входящий вызов',
        hide: 'Скрыть',
        answer: 'Ответить',
        reject: 'Отклонить',
        undefinedNumber: 'Номер не определен',
        goPickup: 'Поднимите трубку'
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
        withoutDepartment: 'wihtout department'
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
      },
      callPopup: {
        title: 'Incoming call',
        hide: 'Hide',
        answer: 'Answer',
        reject: 'Decline',
        undefinedNumber: 'Phone number is not defined',
        goPickup: 'Pick up the phone'
      },
      error: {
        usingOktellClient: {
          header: 'User «%username%» uses standard Oktell client applications.',
          message: 'Simultaneous work of two types of client applications is not possible..',
          message2: 'Close standard Oktell client application and try again.'
        },
        loginPass: {
          header: 'Wrong password for user «%username%».',
          message: 'Make sure that the username and password are correct.'
        },
        unavailable: {
          header: 'Oktell server is not available.',
          message: 'Make sure that Oktell server is running and check your connections.'
        }
      }
    },
    cz: {
      panel: {
        inTalk: 'V rozhovoru',
        onHold: 'Na hold',
        queue: 'Fronta čekaní',
        inputPlaceholder: 'zadejte jméno nebo číslo',
        withoutDepartment: '!!!!!!!'
      },
      actions: {
        call: 'Zavolat',
        conference: 'Konference',
        transfer: 'Převést',
        toggle: 'Přepnout',
        intercom: 'Intercom',
        endCall: 'Ukončit',
        ghostListen: 'Odposlech',
        ghostHelp: 'Nápověda'
      },
      callPopup: {
        title: 'Příchozí hovor',
        hide: 'Schovat',
        answer: 'Odpovědět',
        reject: 'Odmítnout',
        undefinedNumber: '',
        goPickup: 'Zvedněte sluchátko'
      },
      error: {
        usingOktellClient: {
          header: 'User «%username%» uses standard Oktell client applications.',
          message: 'Simultaneous work of two types of client applications is not possible..',
          message2: 'Close standard Oktell client application and try again.'
        },
        loginPass: {
          header: 'Wrong password for user «%username%».',
          message: 'Make sure that the username and password are correct.'
        },
        unavailable: {
          header: 'Oktell server is not available.',
          message: 'Make sure that Oktell server is running and check your connections.'
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
  error = null;
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
  errorHtml = loadTemplate('/templates/error.html');
  List.prototype.jScroll = jScroll;
  List.prototype.usersTableTemplate = usersTableHtml;
  CUser.prototype.buttonTemplate = actionButtonHtml;
  CUser.prototype.log = log;
  List.prototype.log = log;
  Popup.prototype.log = log;
  Department.prototype.log = log;
  Error.prototype.log = log;
  Department.prototype.template = departmentTemplateHtml;
  panelWasInitialized = false;
  initPanel = function(opts) {
    var $user, $userActionButton, animOptHide, animOptShow, bookmarkAnimOptHide, bookmarkAnimOptShow, bookmarkPos, closeClass, critWidth, cssPos, element, elementWidth, errorEl, hidePanel, killPanelHideTimer, mouseOnPanel, newCssPos, oldBinding, openClass, panelBookmarkEl, panelEl, panelHideTimer, panelPos, panelStatus, popupEl, walkAway, xPos, xStartPos;

    panelWasInitialized = true;
    options = $.extend(defaultOptions, opts || {});
    Department.prototype.withoutDepName = List.prototype.withoutDepName = 'zzzzz_without';
    langs = langs[options.lang] || langs.ru;
    CUser.prototype.template = userTemplateHtml.replace('{{button}}', actionButtonHtml);
    panelHtml = panelHtml.replace('{{inTalk}}', langs.panel.inTalk).replace('{{onHold}}', langs.panel.onHold).replace('{{queue}}', langs.panel.queue).replace('{{inputPlaceholder}}', langs.panel.inputPlaceholder);
    List.prototype.langs = langs.actions;
    List.prototype.departmentTemplate = departmentTemplateHtml;
    Error.prototype.langs = langs.error;
    CUser.prototype.langs = langs;
    Department.prototype.langs = langs;
    panelEl = $(panelHtml);
    if (getOptions().noavatar) {
      panelEl.addClass('noavatar');
    }
    popupHtml = popupHtml.replace('{{title}}', langs.callPopup.title).replace('{{goPickup}}', langs.callPopup.goPickup).replace('{{hide}}', langs.callPopup.hide).replace('{{reject}}', langs.callPopup.reject);
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
      popupEl = $(popupHtml);
      $('body').append(popupEl);
      popup = new Popup(popupEl, oktell);
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
    $("body").append(panelEl);
    list = new List(oktell, panelEl, actionListEl, afterOktellConnect, getOptions().debug);
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
