do ($, ko)->
	if not $ or not ko
		throw new Error('Error init oktell panel, jQuery or Knockout.js is not defined')

	loadTemplate = (path) ->
		html = ''
		$.ajax
			url: path
			async: false
			success: (data)-> html = data
		html

	actionButtonHtml = loadTemplate '/templates/actionButton.html'

	defaultOptions =
		position: 'right'
		dynamic: true
		animateTimout: 200
		oktell: window.oktell
		buttonCss: 'oktellActionButton'
		debug: false

	langs = {
		panel: { inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер' },
		actions: { call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь' }
	}

	options = null
	actionListEl = null
	oktell = null
	oktellConnected = false
	afterOktellConnect = null

	list = null

	getOptions = ->
		options or defaultOptions

	actionListHtml = loadTemplate '/templates/actionList.html'

	List.prototype.langs = langs.actions
	List.prototype.jScroll = jScroll

	userTemplateHtml = loadTemplate '/templates/user.html'

	CUser.prototype.template = userTemplateHtml.replace '<!--button-->', actionButtonHtml
	CUser.prototype.buttonTemplate = actionButtonHtml

	panelHtml = loadTemplate '/templates/panel.html'

	panelEl = $(panelHtml)

	window.p = panelEl

	popupHtml = loadTemplate '/templates/numpad.html'

	panelWasInitialized = false

	initPanel = (opts)->
		panelWasInitialized = true

		options = $.extend defaultOptions, opts or {}

		$user = $(userTemplateHtml)
		$userActionButton = $(actionButtonHtml)
		oldBinding = $userActionButton.attr 'data-bind'
		$userActionButton.attr 'data-bind', oldBinding + ', visible: $data.actionBarIsVisible'
		$user.find('td.b_contact_title').append $userActionButton

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell

		panelPos = getOptions().position
		animOptShow = {}
		animOptShow[panelPos] = '0px'
		animOptHide = {}
		animOptHide[panelPos] = '-281px'

		$("body").append(panelEl)

		panelEl.find(".h_input_padding").after popupHtml

		list = new List oktell, panelEl, actionListEl, afterOktellConnect, getOptions().debug
		window.list = list

		if panelPos is "right"
			panelEl.addClass("right");
		else if panelPos is "left"
			panelEl.addClass("left");

		if getOptions().dynamic
			panelEl.addClass("dynamic");

		panelBookmarkEl = panelEl.find('.i_panel_bookmark')


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
				panelBookmarkEl.animate {left: '0px'}, 50, 'swing'
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
				   panelBookmarkEl.animate {left: '-40px'}, 50, 'swing'
				, 150


		panelEl.on "mouseleave", ->
			mouseOnPanel = false
			true

		$('html').on 'mouseleave', (e) ->
			killPanelHideTimer()
			return true


		$('html').on 'mousemove', (e) ->
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

	elsForInitButtonAfterConnect = []

	afterOktellConnect = ->
		oktellConnected = true
		for el in elsForInitButtonAfterConnect
			addActionButtonToEl el
		elsForInitButtonAfterConnect = []

	initBttonOnElement = (el) ->
		el.addClass(getOptions().buttonCss)
		phone = el.attr('data-phone')
		if phone
			button = list.getUserButtonForPlagin phone
			log 'generated button for ' + phone, button
			el.html button

	addActionButtonToEl = (el) ->
		if not oktellConnected
			elsForInitButtonAfterConnect.push el
		else
			initBttonOnElement el

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