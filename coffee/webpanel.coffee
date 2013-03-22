(($, ko)->
	if not $ or not ko
		throw new Error('Error init oktell panel, jQuery or Knockout.js is not defined')

	loadTemplate = (path) ->
		html = ''
		$.ajax
			url: path
			async: false
			success: (data)-> html = data
		html

#	include '/coffee/class/ActionList.js'
#	include '/coffee/class/Panel.js'
#	include '/coffee/class/User.js'
#	include '/coffee/class/UsersService.js'

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
	actionList = null
	panel = null
	usersService = null
	oktell = null
	oktellConnected = false
	afterOktellConnect = null

	getOptions = ->
		options or defaultOptions

	################################################################
	# utils
	################################################################


	################################################################
	# actionList html
	################################################################
	actionListHtml = loadTemplate '/templates/actionList.html'


	################################################################
	# ActionList
	################################################################
	ActionList.prototype.langs = langs.actions

	################################################################
	# User
	################################################################

	################################################################
	# UsersService
	################################################################


	################################################################
	# Panel
	################################################################
	Panel.prototype.langs = langs.panel

	################################################################
	# add user template
	###############################################################
	userTemplateHtml = loadTemplate '/templates/user.html'


	################################################################
	# panel html
	################################################################
	panelHtml = loadTemplate '/templates/panel.html'

	panelEl = $(panelHtml)

	window.p = panelEl


	popupHtml = loadTemplate '/templates/numpad.html'


	################################################################
	# panel Dom init
	################################################################
	panelWasInitialized = false
	initPanel = (opts)->
		panelWasInitialized = true

		options = $.extend defaultOptions, opts or {}

		$user = $(userTemplateHtml)
		$userActionButton = $(actionButtonHtml)
		oldBinding = $userActionButton.attr 'data-bind'
		$userActionButton.attr 'data-bind', oldBinding + ', visible: $data.actionBarIsVisible'
		$user.find('td.b_contact_title').append $userActionButton

		window.u = $user

		$('body').append '<script type="text/html" id="oktellWebPanelUserTemplate" >' + $user[0].outerHTML + '</script>'

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell

		panelPos = getOptions().position
		curOpt = {}

		actionList = new ActionList(oktell, actionListEl)
		ko.applyBindings actionList, actionListEl[0]

		usersService = new UsersService(oktell, actionList, afterOktellConnect, getOptions().debug)
		window.usersService = usersService

		panel = new Panel(actionList, usersService)

		$("body").append(panelEl)

		panelEl.find(".h_input_padding").after popupHtml

		ko.applyBindings panel, panelEl[0]

		panel.afterRender(panelEl);

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
			curOpt[panelPos]="0px"
			if parseInt(panelEl.css(panelPos)) < 0 and ( panelStatus is 'closed' or panelStatus is 'closing' )
				panelStatus = 'opening'
				panelBookmarkEl.stop(true,true)
				panelBookmarkEl.animate {left: '0px'}, 50, 'swing'
				panelEl.stop true, true
				panelEl.animate curOpt, 100, "swing", ->
					panelEl.addClass("g_hover")
					panelStatus = 'open'

		hidePanel = ->
			if panelEl.hasClass "g_hover" #and ( panelStatus is 'open' or panelStatus is '' )
				curOpt[panelPos]="-281px";
				panelStatus = 'closing'
				panelEl.stop(true, true);
				panelEl.animate curOpt, 300, "swing", ->
					curOpt[panelPos]="0px";
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


		$('html').on 'mousemove', (e) ->
			if not mouseOnPanel and panelHideTimer is false
				panelHideTimer = setTimeout ->
					hidePanel()
				, 300

			return true


		if navigator.userAgent.indexOf('iPad') isnt -1

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
					newCssPos = 0
					curOpt[panelPos] = newCssPos + "px"
					element.animate curOpt, 200, "swing", ->
						element.removeClass(closeClass).addClass openClass
						walkAway = 0

			element.live "touchstart", (e) ->
				xStartPos = e.originalEvent.touches[0].pageX
				elementWidth = element.width()
				critWidth = (elementWidth/100)*13
				cssPos = parseInt(element.css(panelPos))

			element.bind "touchmove", (e) ->
				#touchmove
				e.preventDefault()
				xPos = e.originalEvent.touches[0].pageX
				walkAway = xPos - xStartPos
				newCssPos = ( cssPos - walkAway )
				if newCssPos < -281
					newCssPos = -281
				else if newCssPos > 0
					newCssPos = 0
				#alert(walkAway);
				element[0].style.right = newCssPos + 'px'

			element.bind "touchend", (e) ->
				if walkAway >= critWidth and walkAway < 0
					newCssPos = "-281px";
					curOpt[panelPos] = newCssPos;
					element.animate curOpt, 200, "swing"

			if walkAway * -1 >= critWidth and walkAway > 0
				newCssPos = "0px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 200, "swing"


			if walkAway < critWidth and walkAway < 0
				newCssPos = "0px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 100, "swing", ->
					element.removeClass(closeClass).addClass(openClass)

			if walkAway *-1 < critWidth && walkAway > 0
				newCssPos = "-281px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 100, "swing", ->
					element.removeClass(openClass).addClass(closeClass)


		$('.h_phone_number_input', panelEl).on 'click', ".i_phone_popup_button", (e) ->
			inputBox = $(this).parent().parent()
			popupKeypad = panelEl.find(".b_phone_keypad")
			if popupKeypad.is(":visible")
				popupKeypad.slideUp(200)
			else
				popupKeypad.slideDown(200)

		$(document).on "click", (e) =>
			element = $(e.target);
			if element.parents(".j_phone_keypad", panelEl).size() is 0 and element.parents(".h_phone_number_input", panelEl).size() is 0
				$(".i_phone_number_bg_active", panelEl).removeClass("i_phone_number_bg_active", panelEl);

		$('.b_phone_keypad li a', panelEl).bind 'click', (e) ->
			e.preventDefault()
			input = panelEl.find "input.b_phone_number_input"
			input.focus()
			input.val( input.val() + $(this).attr("href") )
			input.change()

	elsForInitButtonAfterConnect = []
	elsWithButton = []

	afterOktellConnect = ->
		oktellConnected = true
		for el in elsForInitButtonAfterConnect
			addActionButtonToEl el
		elsForInitButtonAfterConnect = []

	initBttonOnElement = (el) ->
		el.addClass(getOptions().buttonCss)
		phone = el.attr('data-phone')
		if phone
			el.html(actionButtonHtml)
			user = usersService.getUser phone
			ko.applyBindings user, el.children()[0]
		elsWithButton.push el

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



)($, ko)