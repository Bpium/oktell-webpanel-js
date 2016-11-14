do ($)->
	if not $
		throw new Error('Error init oktell panel, jQuery ( $ ) is not defined')

	#includecoffee coffee/utils.coffee
	#includecoffee coffee/class/Notify.coffee
	#includecoffee coffee/class/Department.coffee
	#includecoffee coffee/class/CUser.coffee
	#includecoffee coffee/class/List.coffee
	#includecoffee coffee/class/Popup.coffee
	#includecoffee coffee/class/PermissionsPopup.coffee
	#includecoffee coffee/class/Error.coffee

	defaultOptions =
		position: 'right'
		dynamic: false
		#animateTimout: 200
		oktell: window.oktell
		oktellVoice: window.oktellVoice
		ringtone: 'ringtone.mp3'
		#buttonCss: 'oktellActionButton'
		debug: false
		lang: 'ru'
		showAvatar: false
		hideOnDisconnect: true
		useNotifies: false
		withoutPermissionsPopup: false
		withoutCallPopup: false
		withoutError: false

	langs = {
		ru:
			panel: { dtmf: 'донабор', dtmfPanelName: 'Донабор', inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер', withoutDepartment: 'без отдела', showDepartments: 'Группировать по отделам', showDepartmentsClicked: 'Показать общим списком', showOnlineOnly: 'Показать только online', showOnlineOnlyCLicked: 'Показать всех' },
			actions: { commutate: 'Соединить', answer: 'Ответить', call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь', hold: 'Удержание', resume: 'Продолжить', dtmf: 'Донабор' }
			callPopup: { title: 'Входящий вызов', hide: 'Скрыть', answer: 'Ответить', reject: 'Отклонить', undefinedNumber: 'Номер не определен', goPickup: 'Поднимите трубку', answer: 'Ответить' }
			permissionsPopup: { header: 'Запрос на доступ к микрофону', text: 'Для использования веб-телефона необходимо разрешить браузеру доступ к микрофону.' }
			error:
				title: 'Ошибка'
				usingOktellClient: { header: 'Пользователь «%username%» использует стандартный Oktell-клиент.', message: 'Одновременная работа двух типов клиентских приложений невозможна.', message2: 'Закройте стандартный Oktell-клиент и повторите попытку.' }
				loginPass: { header: 'Пароль для пользователя «%username%» не подходит.', message: 'Проверьте правильность имени пользователя и пароля.' }
				unavailable: { header: 'Сервер телефонии Oktell не доступен.', message: 'Убедитесь что сервер телефонии работает и проверьте настройки соединения.'}
				#tryAgain: 'Повторить попытку'
		en:
			panel: { dtmf: 'dtmf', dtmfPanelName: 'DTMF', inTalk: 'In conversation', onHold: 'On hold', queue: 'Wait queue', inputPlaceholder: 'Enter name or number', withoutDepartment: 'Without department', showDepartments: 'Show departments', showDepartmentsClicked: 'Hide departments', showOnlineOnly: 'Show online only', showOnlineOnlyCLicked: 'Show all' },
			actions: { commutate: 'Commutate', answer: 'Answer', call: 'Dial', conference: 'Conference', transfer: 'Transfer', toggle: 'Switch', intercom: 'Intercom', endCall: 'End', ghostListen: 'Audition', ghostHelp: 'Help', hold: 'Hold', resume: 'Resume', dtmf: 'DTMF' }
			callPopup: { title: 'Incoming call', hide: 'Hide', answer: 'Answer', reject: 'Decline', undefinedNumber: 'Phone number is not defined', goPickup: 'Pick up the phone', answer: 'Answer' }
			permissionsPopup: { header: 'Request for access to the microphone', text: 'To use the web-phone you need to allow browser access to the microphone.' }
			error:
				title: 'Error'
				usingOktellClient: { header: 'User «%username%» uses standard Oktell client application.', message: 'Simultaneous work of two types of client applications is not possible.', message2: 'Close standard Oktell client application and try again.' }
				loginPass: { header: 'Wrong password for user «%username%».', message: 'Make sure that the username and password are correct.' }
				unavailable: { header: 'Oktell server is not available.', message: 'Make sure that Oktell server is running and check your connection.'}
				#tryAgain: 'Try again'
		cz:
			panel: { dtmf: 'dtmf', dtmfPanelName: 'DTMF', inTalk: 'V rozhovoru', onHold: 'Na hold', queue: 'Fronta čekaní', inputPlaceholder: 'zadejte jméno nebo číslo', withoutDepartment: 'Bez oddělení', showDepartments: 'Zobrazit oddělení', showDepartmentsClicked: 'Skrýt oddělení', showOnlineOnly: 'Zobrazit pouze online', showOnlineOnlyCLicked: 'Zobrazit všechny' },
			actions: { commutate: 'Commutate', answer: 'Odpověď', call: 'Zavolat', conference: 'Konference', transfer: 'Převést', toggle: 'Přepnout', intercom: 'Intercom', endCall: 'Ukončit', ghostListen: 'Odposlech', ghostHelp: 'Nápověda', hold: 'Udržet', resume: 'Pokračovat', dtmf: 'DTMF' }
			callPopup: { title: 'Příchozí hovor', hide: 'Schovat', answer: 'Odpovědět', reject: 'Odmítnout', undefinedNumber: '', goPickup: 'Zvedněte sluchátko', answer: 'Odpovědět' }
			permissionsPopup: { header: 'Žádost o přístup k mikrofonu', text: 'Abyste mohli používat telefon, musíte povolit prohlížeče přístup k mikrofonu.' }
			error:
				title: 'Chyba'
				usingOktellClient: { header: 'Uživatel «%username%» používá standardní Oktell klientské aplikace.', message: 'Současnou práci dvou typů klientských aplikací není možné.', message2: 'Zavřít Oktell standardní klientskou aplikaci a zkuste to znovu.' }
				loginPass: { header: 'Chybné heslo uživatele «%username%».', message: 'Ujistěte se, že uživatelské jméno a heslo jsou správné.' }
				unavailable: { header: 'Oktell server není k dispozici.', message: 'Ujistěte se, že Oktell server běží a zkontrolujte připojení.'}
				#tryAgain: 'Try again'
	}

	options = null
	actionListEl = null
	oktell = null
	oktellConnected = false
	afterOktellConnect = null
	list = null
	popup = null
	permissionsPopup = null
	error = null
	panelEl = null
	contEl = null
	actionButtonContainerClass = 'oktellPanelActionButton'

	getOptions = ->
		options or defaultOptions

	isMobileDevice = if navigator.userAgent.match(/(Android|webOS|iPhone|iPad|iPod|BlackBerry|Windows Phone)/i) then true else false

	useSticky = not isMobileDevice
	useNativeScroll = isMobileDevice

	checkCssAnimationSupport = =>
		div = document.createElement("div")
		divStyle = div.style
		suffix = "Transform"
		testProperties = ["o" + suffix, "ms" + suffix, "webkit" + suffix, "Webkit" + suffix, "Moz" + suffix, 'transform']
		for v in testProperties
			if divStyle[v]?
				return true
		return divStyle
		return false

	logStr = ''
	log = (args...)->
		if not getOptions().debug then return
		d = new Date()
		dd =  d.getFullYear() + '-' + (if d.getMonth()<10 then '0' else '') + d.getMonth() + '-' + (if d.getDate()<10 then '0' else '') + d.getDate();
		t = (if d.getHours()<10 then '0' else '') + d.getHours() + ':' + (if d.getMinutes()<10 then '0' else '')+d.getMinutes() + ':' +  (if d.getSeconds()<10 then '0' else '')+d.getSeconds() + ':' +	(d.getMilliseconds() + 1000).toString().substr(1)
		logStr += dd + ' ' + t + ' | '
		fnName = 'log'
		if args[0].toString().toLowerCase() is 'error'
			fnName = 'error'
		for val, i in args
			if typeof val == 'object'
				try
					logStr += JSON.stringify(val)
				catch e
					logStr += val.toString()
			else
				logStr += val
			logStr += ' | '
		logStr += "\n\n"
		args.unshift 'Oktell-Panel.js ' + t + ' |' + ( if typeof @logGroup is 'string' then ' ' + @logGroup + ' |' else '' )
		try
			console[fnName].apply( console, args || [])
		catch e

	templates = {}

	loadTemplate = (path) ->
		path = path.substr(1) if path[0] is '/'
		if templates[path]?
			return templates[path]
		# for dev mode
		html = ''
		$.ajax
			url: path
			async: false
			success: (data)-> html = data
		html

	actionButtonHtml = loadTemplate '/templates/actionButton.html'
	actionListHtml = loadTemplate '/templates/actionList.html'
	userTemplateHtml = loadTemplate '/templates/user.html'
	departmentTemplateHtml = loadTemplate '/templates/department.html'
	departmentTemplateHtml = loadTemplate '/templates/dep.html'
	usersTableHtml = loadTemplate '/templates/usersTable.html'
	panelHtml = loadTemplate '/templates/panel.html'
	popupHtml = loadTemplate '/templates/callPopup.html'
	permissionsPopupHtml = loadTemplate '/templates/permissionsPopup.html'
	errorHtml = loadTemplate '/templates/error.html'

#	List.prototype.jScroll = jScroll
	List.prototype.usersTableTemplate = usersTableHtml

	CUser.prototype.buttonTemplate = actionButtonHtml
	CUser.prototype.log = log
	List.prototype.log = log
	Popup.prototype.log = log
	PermissionsPopup.prototype.log = log
	Department.prototype.log = log
	ErrorView.prototype.log = log

	Department.prototype.template = departmentTemplateHtml

	panelWasInitialized = false

#	isAndroid = (/android/gi).test(navigator.appVersion)
#	isIDevice = (/iphone|ipad/gi).test(navigator.appVersion)
#	isTouchPad = (/hp-tablet/gi).test(navigator.appVersion)
#	hasTouch = 'ontouchstart' in window and not isTouchPad

	initPanel = (opts)->

		panelWasInitialized = true

		options = $.extend {}, defaultOptions, opts or {}

		useContainer = false
		contOpt = getOptions().container?[0] or getOptions().container
		contEl = null
		# check if contOpt is DOM
		if contOpt and ( typeof HTMLElement is "object" and contOpt instanceof HTMLElement ) or ( contOpt?.nodeType is 1 and typeof contOpt.nodeName is "string" )
			contEl = $(contOpt)
			useContainer = true
		else
			contEl = $('body')

		if useContainer
			useSticky = false
			useNativeScroll = true

		if options.oktellVoice
			if options.oktellVoice.isOktellVoice is true
				options.oktellVoice = options.oktellVoice
			else if window.oktellVoice window.oktellVoice.isOktellVoice is true
				options.oktellVoice = window.oktellVoice

		if getOptions().useNotifies and window.webkitNotifications and window.webkitNotifications.checkPermission() is 1
			webkitNotifications.requestPermission =>

		Department.prototype.withoutDepName = List.prototype.withoutDepName = CUser.prototype.withoutDepName = 'zzzzz_without'
		langs = langs[options.lang] or langs.ru
		CUser.prototype.template = userTemplateHtml.replace '{{button}}', actionButtonHtml
		panelHtml = panelHtml.replace('{{inTalk}}',langs.panel.inTalk)
			.replace('{{dtmfPanelName}}',langs.panel.dtmfPanelName)
			.replace('{{onHold}}',langs.panel.onHold)
			.replace('{{queue}}',langs.panel.queue)
			.replace('{{inputPlaceholder}}',langs.panel.inputPlaceholder)
		List.prototype.langs = langs
		List.prototype.departmentTemplate = departmentTemplateHtml
		ErrorView.prototype.langs = langs.error
		CUser.prototype.langs = langs
		Department.prototype.langs = langs
		panelEl = $(panelHtml)

		if not getOptions().showAvatar
			panelEl.addClass('noavatar')
#		if hasTouch
#			panelEl.addClass('touch')

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell
		CUser.prototype.formatPhone = oktell.formatPhone

		ringtone = null
		if getOptions().ringtone
			ringtone = $('<audio src="'+getOptions().ringtone+'" id="oktell_panel_ringtone" preload="auto"></audio>')[0]
			$("body").append ringtone
			ringtone.loop = true

		if not getOptions().withoutCallPopup
			popupHtml = popupHtml.replace('{{title}}', langs.callPopup.title)
				.replace('{{goPickup}}', langs.callPopup.goPickup)
				.replace('{{answer}}', langs.callPopup.answer)
				.replace('{{hide}}', langs.callPopup.hide)
				.replace('{{reject}}', langs.callPopup.reject)

			popupEl = $(popupHtml)
			$('body').append(popupEl)
			popup = new Popup popupEl, oktell, ringtone

		# TODO перевести пермишнз попап
		if not getOptions().withoutPermissionsPopup
			permissionsPopupHtml = permissionsPopupHtml.replace('{{header}}', langs.permissionsPopup.header).replace('{{text}}', langs.permissionsPopup.text)
			permissionsPopupEl = $(permissionsPopupHtml)
			$('body').append(permissionsPopupEl)
			permissionsPopup = new PermissionsPopup permissionsPopupEl, getOptions().oktellVoice

		if not getOptions().withoutError
			errorHtml = errorHtml.replace('{{title}}', langs.error.title)
			errorEl = $(errorHtml)
			panelEl.find('.h_panel_bg:first').append errorEl
			#errorEl.hide()
			error = new ErrorView errorEl, oktell

		panelPos = getOptions().position
		animOptShow = {}
		animOptShow[panelPos] = '0px'
		animOptHide = {}
		animOptHide[panelPos] = '-281px'
		panelMinPos = -281

		panelEl.hide()

		if useContainer
			panelEl.addClass 'contained'

		contEl.append panelEl

		list = new List oktell, panelEl, actionListEl, afterOktellConnect, getOptions(), useContainer, useSticky, useNativeScroll, getOptions().debug
		window.__list = list;

#		if error
#			error.onShow = =>
#				list.resetStickyHeaders()
#			error.onHide = =>
#				list.initStickyHeaders()

		if getOptions().debug
			window.wList = list
			window.wPopup = popup
			window.wError = error

		if panelPos is "right"
			panelEl.addClass("right");
		else if panelPos is "left"
			panelEl.addClass("left");

		if getOptions().dynamic
			panelEl.addClass("dynamic");

		if not useContainer
			panelBookmarkEl = panelEl.find('.i_panel_bookmark')
			bookmarkAnimOptShow = {}
			bookmarkPos = if panelPos is 'left' then 'right' else 'left'
			bookmarkAnimOptShow[bookmarkPos] = '0px'
			bookmarkAnimOptHide = {}
			bookmarkAnimOptHide[bookmarkPos] = '-40px'

			# Panel Bookmark hover
			mouseOnPanel = false
			panelHideTimer = false
			_panelStatus = 'closed'
			panelStatus = (st)=>
				if st and st isnt _panelStatus
					#@log 'set panel status - ' + st
					_panelStatus = st
				_panelStatus

			killPanelHideTimer = ->
				clearTimeout panelHideTimer
				panelHideTimer = false

			useCssAnim = checkCssAnimationSupport()
			showTimer = null
			hideTimer = null
			cssAnimNow = false

			showPanel = =>
				list.beforeShow()
				panelStatus 'opening'
				#panelBookmarkEl.stop(true,true)
				#panelBookmarkEl.animate bookmarkAnimOptShow, 1, 'swing'
				panelBookmarkEl.css bookmarkAnimOptShow
				if useCssAnim
					if not cssAnimNow
						cssAnimNow = true
						panelEl.css 'right', ''
						clearTimeout showTimer
						panelEl.removeClass('hide_t_'+panelPos).addClass('show_t_'+panelPos)
						showTimer = setTimeout =>
							panelEl.css 'right', '0px'
							panelEl.removeClass 'show_t_'+panelPos
							list.afterShow()
							panelEl.addClass("g_hover")
							panelStatus 'open'
							panelBookmarkEl.css bookmarkAnimOptShow
							cssAnimNow = false
						, 200
				else
					panelEl.stop true, true
					panelEl.animate animOptShow, 100, "swing", ->
						list.afterShow()
						panelEl.addClass("g_hover")
						panelStatus 'open'
						panelBookmarkEl.css bookmarkAnimOptShow


			hidePanel = ->
				#if panelEl.hasClass "g_hover" #and ( panelStatus is 'open' or panelStatus is '' )
				if useCssAnim
					if not cssAnimNow
						panelStatus 'closing'
						list.beforeHide()
						cssAnimNow = true
						panelEl.css 'right', ''
						clearTimeout hideTimer
						panelEl.removeClass('show_t_'+panelPos).addClass('hide_t_'+panelPos)
						hideTimer = setTimeout =>
							panelEl.css 'right', '-281px'
							panelEl.removeClass 'hide_t_'+panelPos
							list.afterHide()
							panelEl.removeClass("g_hover");
							panelBookmarkEl.css bookmarkAnimOptHide
							panelStatus 'closed'
							cssAnimNow = false
						, 400
				else
					panelStatus 'closing'
					list.beforeHide()
					panelEl.stop(true, true);
					panelEl.animate animOptHide, 300, "swing", ->
						panelEl.css({panelPos: 0});
						list.afterHide()
						panelEl.removeClass("g_hover");
						panelBookmarkEl.css bookmarkAnimOptHide
						panelStatus 'closed'
			#setTimeout ->
			#panelBookmarkEl.stop(true,true)
			#panelBookmarkEl.animate bookmarkAnimOptHide, 50, 'swing'
			#, 49


			panelEl.bind "mouseenter", =>
				mouseOnPanel = true
				killPanelHideTimer()
				if parseInt(panelEl.css(panelPos)) < 0 and ( panelStatus() is 'closed' or panelStatus() is 'closing' )
					#@log 'show panel on mouseenter'
					showPanel()
				true

			pageX = false
			minPosOpen = -250
			maxPosClose = 30
			touchMoving = false
			enableMoving = false

			panelBookmarkEl.bind 'touchstart', =>
				#@log 'touchstart'
				if panelStatus() is 'closed'
					panelStatus 'touchopening'
				else if panelStatus() is 'open'
					panelStatus 'touchclosing'
				true

			panelBookmarkEl.bind 'touchmove', (e)=>
				if panelStatus() is 'touchopening' or panelStatus() is 'touchclosing'
					touchMoving = true

				if enableMoving and touchMoving
					t = e?.originalEvent?.touches?[0]
					if t
						if pageX isnt false
							pos = parseInt panelEl.css panelPos
	#						@log 'moving pos='+pos+' pageX='+pageX+' t.pageX='+t.pageX
							panelEl.css panelPos, Math.max( panelMinPos, Math.min( 0, pos + pageX - t.pageX ) ) + 'px'
						pageX = t.pageX
				true


			panelBookmarkEl.bind 'touchend', =>
				#@log 'touchend'
				if not touchMoving
					if panelStatus() is 'touchopening'
						#@log 'show panel on touch end'
						showPanel()
				else
					touchMoving = false
					pos = parseInt panelEl.css panelPos
					#@log 'pos = ' + pos
					if panelStatus() is 'touchopening'
						if pos > minPosOpen
							showPanel()
						else
							hidePanel()
					else if panelStatus() is 'touchclosing'
						if pos < maxPosClose
							hidePanel()
						else
							openPanel()
				true


			panelBookmarkEl.bind 'touchcancel', =>
				true


			$(window).bind 'touchcancel', (e)=>
				#@log 'touchcancel'
				true

			$(window).bind 'touchend', (e)=>
				target = $(e.target)
				parents = target.parents()
				parentsArr = parents.toArray()
				if parentsArr.indexOf( panelEl[0] ) is -1
					hidePanel()
				true

			panelEl.bind "mouseleave", ->
				mouseOnPanel = false
				true

			$('html').bind 'mouseleave', (e) ->
				killPanelHideTimer()
				return true


			$('html').bind 'mousemove', (e) ->
				if panelStatus() is 'open' and not mouseOnPanel and panelHideTimer is false and not list.dropdownOpenedOnPanel
					panelHideTimer = setTimeout ->
						hidePanel()
					, 100
					1
				return true


		# handle touch on action buttons
#		touchClickedContact = null
#		touchClickedCss = 'm_touch_clicked'
#		touchClickedContactClear = =>
#			touchClickedContact?.removeClass touchClickedCss
#			touchClickedContact = null
#
#		$(window).bind 'touchend', (e)=>
#			if not target.is('.oktell_button_action .drop_down') and parents.filter('.oktell_button_action .drop_down').size() is 0 # and parentsArr.indexOf( actionListEl[0] ) is -1
#				list?.hideActionListDropdown?()
#			true
#
#		panelEl.bind 'touchend', (e)=>
#			#@log 'touchstart'
#			target = $(e.target)
#			parents = target.parents()
#			if not target.is('.oktell_button_action .drop_down') and parents.filter('.oktell_button_action .drop_down').size() is 0 # and parentsArr.indexOf( actionListEl[0] ) is -1
#				list?.hideActionListDropdown?()
#			contact = if target.is('.oktell_panel .b_contact') then target else parents.filter('.oktell_panel .b_contact')
#			if contact.size() > 0
#				if not contact.hasClass(touchClickedCss)
#					touchClickedContactClear()
#					touchClickedContact = contact
#					contact.addClass touchClickedCss
#					return false
#			else
#				touchClickedContactClear()
#
#			true

		# close actions dropdown if touched anything else in body
		$('.oktell_actions_group_list').on 'touchstart', (e)->
			e.stopPropagation()
			return true

		$('body').on 'touchstart', (e)->
			list?.hideActionListDropdown?()


	afterOktellConnect = ->
		oktellConnected = true

	initButtonOnElement = (el) ->
		el.addClass(getOptions().buttonCss)
		phone = el.attr('data-phone')
		el.empty()
		if phone
			button = list.getUserButtonForPlugin phone.replace(/\+/g, "")
			#log 'generated button for ' + phone, button
			el.html button

	addActionButtonToEl = (el) ->
		initButtonOnElement el

	initActionButtons = (selector) ->
		$(selector+":not(."+ actionButtonContainerClass + ")").each ->
			addActionButtonToEl $(this)

	$.oktellPanel = (arg) ->
		if typeof arg is 'string'
			if panelWasInitialized
				initActionButtons(arg)
		else if not panelWasInitialized
			initPanel(arg)

	$.fn.oktellButton = ->
		$(this).each ->
			addActionButtonToEl $(this)


	$.fn.oktellPanel = (args...)->
		if not panelWasInitialized
			# create panel on given element
			args.container = $(this)
			$.oktellPanel.apply window, args

		else if $(this)[0] is panelEl?[0]
			$.oktellPanel.apply window, args

	$.oktellPanel.show = =>
		list.showPanel()
	$.oktellPanel.hide = =>
		list.hidePanel()

	customActions = {}
	customActionAutoincrement = 1

	$.oktellPanel.appendPhoneAction = (number, {title, callback})=>
		user = list.usersByNumber[number] || list.getUser(number)
		id = String(customActionAutoincrement++)
		customActions[id] = user
		list.allActions[id] = {icon: '', text: title}
		user.addAction(id, callback)
		id

	$.oktellPanel.removePhoneAction = (id)=>
		user = customActions[id]
		return false if not user
		delete list.allActions[id]
		delete customActions[id]
		user.removeAction(id)
		true


#	$.fn.oktellActions = ->
#		$(this).each ->
#			$(this).bind 'click', (e)->
#				e.preventDefault()
#				el = $(this)
#				phone = el.data 'phone'
