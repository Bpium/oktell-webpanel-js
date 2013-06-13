do ($)->
	if not $
		throw new Error('Error init oktell panel, jQuery ( $ ) is not defined')

	#includecoffee coffee/utils.coffee
	#includecoffee coffee/jScroll.coffee
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
		#buttonCss: 'oktellActionButton'
		debug: false
		lang: 'ru'
		noavatar: true

	langs = {
		ru:
			panel: { inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер', withoutDepartment: 'без отдела', showDepartments: 'Группировать по отделам', showDepartmentsClicked: 'Показать общим списком', showOnlineOnly: 'Показать только online', showOnlineOnlyCLicked: 'Показать всех' },
			actions: { call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь' }
			callPopup: { title: 'Входящий вызов', hide: 'Скрыть', answer: 'Ответить', reject: 'Отклонить', undefinedNumber: 'Номер не определен', goPickup: 'Поднимите трубку' }
			permissionsPopup: { header: 'Запрос на доступ к микрофону', text: 'Для использования веб-телефона необходимо разрешить браузеру доступ к микрофону.' }
			error:
				usingOktellClient: { header: 'Пользователь «%username%» использует стандартный Oktell-клиент.', message: 'Одновременная работа двух типов клиентских приложений невозможна.', message2: 'Закройте стандартный Oktell-клиент и повторите попытку.' }
				loginPass: { header: 'Пароль для пользователя «%username%» не подходит.', message: 'Проверьте правильность имени пользователя и пароля.' }
				unavailable: { header: 'Сервер телефонии Oktell не доступен.', message: 'Убедитесь что сервер телефонии работает и проверьте настройки соединения.'}
				#tryAgain: 'Повторить попытку'
		en:
			panel: { inTalk: 'In conversation', onHold: 'On hold', queue: 'Wait queue', inputPlaceholder: 'Enter name or number', withoutDepartment: 'Without department', showDepartments: 'Show departments', showDepartmentsClicked: 'Hide departments', showOnlineOnly: 'Show online only', showOnlineOnlyCLicked: 'Show all' },
			actions: { call: 'Dial', conference: 'Conference', transfer: 'Transfer', toggle: 'Switch', intercom: 'Intercom', endCall: 'End', ghostListen: 'Audition', ghostHelp: 'Help' }
			callPopup: { title: 'Incoming call', hide: 'Hide', answer: 'Answer', reject: 'Decline', undefinedNumber: 'Phone number is not defined', goPickup: 'Pick up the phone' }
			permissionsPopup: { header: 'Request for access to the microphone', text: 'To use the phone you need to allow browser access to the microphone.' }
			error:
				usingOktellClient: { header: 'User «%username%» uses standard Oktell client applications.', message: 'Simultaneous work of two types of client applications is not possible..', message2: 'Close standard Oktell client application and try again.' }
				loginPass: { header: 'Wrong password for user «%username%».', message: 'Make sure that the username and password are correct.' }
				unavailable: { header: 'Oktell server is not available.', message: 'Make sure that Oktell server is running and check your connections.'}
				#tryAgain: 'Try again'
		cz:
			panel: { inTalk: 'V rozhovoru', onHold: 'Na hold', queue: 'Fronta čekaní', inputPlaceholder: 'zadejte jméno nebo číslo', withoutDepartment: 'Bez oddělení', showDepartments: 'Zobrazit oddělení', showDepartmentsClicked: 'Skrýt oddělení', showOnlineOnly: 'Zobrazit pouze online', showOnlineOnlyCLicked: 'Zobrazit všechny' },
			actions: { call: 'Zavolat', conference: 'Konference', transfer: 'Převést', toggle: 'Přepnout', intercom: 'Intercom', endCall: 'Ukončit', ghostListen: 'Odposlech', ghostHelp: 'Nápověda' }
			callPopup: { title: 'Příchozí hovor', hide: 'Schovat', answer: 'Odpovědět', reject: 'Odmítnout', undefinedNumber: '', goPickup: 'Zvedněte sluchátko' }
			permissionsPopup: { header: 'Žádost o přístup k mikrofonu', text: 'Abyste mohli používat telefon, musíte povolit prohlížeče přístup k mikrofonu.' }
			error:
				usingOktellClient: { header: 'User «%username%» uses standard Oktell client applications.', message: 'Simultaneous work of two types of client applications is not possible..', message2: 'Close standard Oktell client application and try again.' }
				loginPass: { header: 'Wrong password for user «%username%».', message: 'Make sure that the username and password are correct.' }
				unavailable: { header: 'Oktell server is not available.', message: 'Make sure that Oktell server is running and check your connections.'}
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
	actionButtonContainerClass = 'oktellPanelActionButton'

	getOptions = ->
		options or defaultOptions

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

	List.prototype.jScroll = jScroll
	List.prototype.usersTableTemplate = usersTableHtml

	CUser.prototype.buttonTemplate = actionButtonHtml
	CUser.prototype.log = log
	List.prototype.log = log
	Popup.prototype.log = log
	PermissionsPopup.prototype.log = log
	Department.prototype.log = log
	Error.prototype.log = log

	Department.prototype.template = departmentTemplateHtml

	panelWasInitialized = false

	initPanel = (opts)->
		panelWasInitialized = true

		options = $.extend defaultOptions, opts or {}

		Department.prototype.withoutDepName = List.prototype.withoutDepName = 'zzzzz_without'
		langs = langs[options.lang] or langs.ru
		CUser.prototype.template = userTemplateHtml.replace '{{button}}', actionButtonHtml
		panelHtml = panelHtml.replace('{{inTalk}}',langs.panel.inTalk)
			.replace('{{onHold}}',langs.panel.onHold)
			.replace('{{queue}}',langs.panel.queue)
			.replace('{{inputPlaceholder}}',langs.panel.inputPlaceholder)
		List.prototype.langs = langs
		List.prototype.departmentTemplate = departmentTemplateHtml
		Error.prototype.langs = langs.error
		CUser.prototype.langs = langs
		Department.prototype.langs = langs
		panelEl = $(panelHtml)

		if getOptions().noavatar
			panelEl.addClass('noavatar')

		$user = $(userTemplateHtml)
		$userActionButton = $(actionButtonHtml)
		oldBinding = $userActionButton.attr 'data-bind'
		$userActionButton.attr 'data-bind', oldBinding + ', visible: $data.actionBarIsVisible'
		$user.find('td.b_contact_title').append $userActionButton

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell
		CUser.prototype.formatPhone = oktell.formatPhone

		if not getOptions().withoutCallPopup
			popupHtml = popupHtml.replace('{{title}}', langs.callPopup.title)
				.replace('{{goPickup}}', langs.callPopup.goPickup)
				.replace('{{hide}}', langs.callPopup.hide)
				.replace('{{reject}}', langs.callPopup.reject)

			popupEl = $(popupHtml)
			$('body').append(popupEl)
			popup = new Popup popupEl, oktell

		# TODO перевести пермишнз попап
		if not getOptions().withoutPermissionsPopup
			permissionsPopupHtml = permissionsPopupHtml.replace('{{header}}', langs.permissionsPopup.header).replace('{{text}}', langs.permissionsPopup.text)
			permissionsPopupEl = $(permissionsPopupHtml)
			$('body').append(permissionsPopupEl)
			permissionsPopup = new PermissionsPopup permissionsPopupEl, getOptions().oktellVoice

		if not getOptions().withoutError
			errorEl = $(errorHtml)
			panelEl.find('.h_panel_bg:first').append errorEl
			#errorEl.hide()
			error = new Error errorEl, oktell

		panelPos = getOptions().position
		animOptShow = {}
		animOptShow[panelPos] = '0px'
		animOptHide = {}
		animOptHide[panelPos] = '-281px'


		$("body").append(panelEl)

		list = new List oktell, panelEl, actionListEl, afterOktellConnect, getOptions().debug
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

		panelBookmarkEl = panelEl.find('.i_panel_bookmark')
		bookmarkAnimOptShow = {}
		bookmarkPos = if panelPos is 'left' then 'right' else 'left'
		bookmarkAnimOptShow[bookmarkPos] = '0px'
		bookmarkAnimOptHide = {}
		bookmarkAnimOptHide[bookmarkPos] = '-40px'

		# Panel Bookmark hover
		mouseOnPanel = false
		panelHideTimer = false
		panelStatus = 'closed'

		killPanelHideTimer = ->
			clearTimeout panelHideTimer
			panelHideTimer = false

		panelEl.on "mouseenter", ->
			mouseOnPanel = true
			killPanelHideTimer()
			if parseInt(panelEl.css(panelPos)) < 0 and ( panelStatus is 'closed' or panelStatus is 'closing' )
				panelStatus = 'opening'
				panelBookmarkEl.stop(true,true)
				#panelBookmarkEl.animate bookmarkAnimOptShow, 1, 'swing'
				panelBookmarkEl.css bookmarkAnimOptShow
				panelEl.stop true, true
				panelEl.animate animOptShow, 100, "swing", ->
					panelEl.addClass("g_hover")
					panelStatus = 'open'
			true

		hidePanel = ->
			if panelEl.hasClass "g_hover" #and ( panelStatus is 'open' or panelStatus is '' )
				panelStatus = 'closing'
				panelEl.stop(true, true);
				panelEl.animate animOptHide, 300, "swing", ->
					panelEl.css({panelPos: 0});
					panelEl.removeClass("g_hover");
					panelStatus = 'closed'
				#setTimeout ->
					panelBookmarkEl.stop(true,true)
					#panelBookmarkEl.animate bookmarkAnimOptHide, 50, 'swing'
					panelBookmarkEl.css bookmarkAnimOptHide
				#, 49


		panelEl.on "mouseleave", ->
			mouseOnPanel = false
			true

		$('html').bind 'mouseleave', (e) ->
			killPanelHideTimer()
			return true


		$('html').bind 'mousemove', (e) ->
			if not mouseOnPanel and panelHideTimer is false and not list.dropdownOpenedOnPanel
				panelHideTimer = setTimeout ->
					hidePanel()
				, 100
			return true

		if window.navigator.userAgent.indexOf('iPad') isnt -1

			xStartPos = 0
			xPos = 0
			element = panelEl
			elementWidth = 0
			critWidth = 0
			cssPos = -281
			walkAway = 0
			newCssPos = 0
			openClass = "j_open"
			closeClass = "j_close"

			if parseInt(element[0].style.right) < 0
				element.addClass closeClass

			element.live "click", ->
				if element.hasClass(closeClass)
					element.animate animOptShow, 200, "swing", ->
						element.removeClass(closeClass).addClass openClass
						walkAway = 0

			element.live "touchstart", (e) ->
				xStartPos = e.originalEvent.touches[0].pageX
				elementWidth = element.width()
				critWidth = (elementWidth/100)*13
				cssPos = parseInt(element.css(panelPos))

			element.bind "touchmove", (e) ->
				e.preventDefault()
				xPos = e.originalEvent.touches[0].pageX
				walkAway = xPos - xStartPos
				newCssPos = ( cssPos - walkAway )
				if newCssPos < -281
					newCssPos = -281
				else if newCssPos > 0
					newCssPos = 0
				element[0].style.right = newCssPos + 'px'

			element.bind "touchend", (e) ->
				if walkAway >= critWidth and walkAway < 0
					element.animate animOptHide, 200, "swing"

			if walkAway * -1 >= critWidth and walkAway > 0
				element.animate animOptShow, 200, "swing"

			if walkAway < critWidth and walkAway < 0
				element.animate animOptShow, 100, "swing", ->
					element.removeClass(closeClass).addClass(openClass)

			if walkAway *-1 < critWidth && walkAway > 0
				element.animate animOptHide, 100, "swing", ->
					element.removeClass(openClass).addClass(closeClass)


	afterOktellConnect = ->
		oktellConnected = true

	initButtonOnElement = (el) ->
		el.addClass(getOptions().buttonCss)
		phone = el.attr('data-phone')
		if phone
			button = list.getUserButtonForPlugin phone
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


#	$.fn.oktellActions = ->
#		$(this).each ->
#			$(this).bind 'click', (e)->
#				e.preventDefault()
#				el = $(this)
#				phone = el.data 'phone'
