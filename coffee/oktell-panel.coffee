do ($)->
	if not $
		throw new Error('Error init oktell panel, jQuery ( $ ) is not defined')

	#includecoffee coffee/utils.coffee
	#includecoffee coffee/jScroll.coffee
	#includecoffee coffee/class/CUser.coffee
	#includecoffee coffee/class/List.coffee
	#includecoffee coffee/class/Popup.coffee

	defaultOptions =
		position: 'right'
		dynamic: false
		#animateTimout: 200
		oktell: window.oktell
		#buttonCss: 'oktellActionButton'
		debug: false
		lang: 'ru'

	langs = {
		ru:
			panel: { inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер' },
			actions: { call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь' }
		en:
			panel: { inTalk: 'In conversation', onHold: 'On hold', queue: 'Wait queue', inputPlaceholder: 'Enter name or number' },
			actions: { call: 'Dial', conference: 'Conference', transfer: 'Transfer', toggle: 'Switch', intercom: 'Intercom', endCall: 'End', ghostListen: 'Audition', ghostHelp: 'Help' }
	}

	options = null
	actionListEl = null
	oktell = null
	oktellConnected = false
	afterOktellConnect = null
	list = null
	popup = null

	getOptions = ->
		options or defaultOptions

	log = ->
		if not getOptions().debug then return
		try
			console.log.apply(console, arguments);
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
	panelHtml = loadTemplate '/templates/panel.html'
	popupHtml = loadTemplate '/templates/callPopup.html'

	List.prototype.jScroll = jScroll

	CUser.prototype.buttonTemplate = actionButtonHtml
	CUser.prototype.log = log

	panelWasInitialized = false

	initPanel = (opts)->
		panelWasInitialized = true

		options = $.extend defaultOptions, opts or {}

		langs = langs[options.lang] or langs.ru
		CUser.prototype.template = userTemplateHtml.replace '{{button}}', actionButtonHtml
		panelHtml = panelHtml.replace('{{inTalk}}',langs.panel.inTalk)
			.replace('{{onHold}}',langs.panel.onHold)
			.replace('{{queue}}',langs.panel.queue)
			.replace('{{inputPlaceholder}}',langs.panel.inputPlaceholder)
		List.prototype.langs = langs.actions
		panelEl = $(panelHtml)

		popupEl = $(popupHtml)
		$('body').append(popupEl)

		$user = $(userTemplateHtml)
		$userActionButton = $(actionButtonHtml)
		oldBinding = $userActionButton.attr 'data-bind'
		$userActionButton.attr 'data-bind', oldBinding + ', visible: $data.actionBarIsVisible'
		$user.find('td.b_contact_title').append $userActionButton

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell

		popup = new Popup popupEl, oktell

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
				panelBookmarkEl.animate bookmarkAnimOptShow, 50, 'swing'
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
				setTimeout ->
				   panelBookmarkEl.animate bookmarkAnimOptHide, 50, 'swing'
				, 150


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
			log 'generated button for ' + phone, button
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
