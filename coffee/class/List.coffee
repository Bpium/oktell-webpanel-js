class List

	constructor: (oktell, panelEl, dropdownEl, afterOktellConnect, debugMode) ->
		@allActions =
			call: { icon: '/img/icons/action/call.png', iconWhite: '/img/icons/action/white/call.png', text: @langs.call }
			conference : { icon: '/img/icons/action/confinvite.png', iconWhite: '/img/icons/action/white/confinvite.png', text: @langs.conference }
			transfer : { icon: '/img/icons/action/transfer.png', text: @langs.transfer }
			toggle : { icon: '/img/icons/action/toggle.png', text: @langs.toggle }
			intercom : { icon: '/img/icons/action/intercom.png', text: @langs.intercom }
			endCall : { icon: '/img/icons/action/endcall.png', iconWhite: '/img/icons/action/white/endcall.png', text: @langs.endCall }
			ghostListen : { icon: '/img/icons/action/ghost_monitor.png', text: @langs.ghostListen }
			ghostHelp : { icon: '/img/icons/action/ghost_help.png', text: @langs.ghostHelp }

		@actionCssPrefix = 'i_'
		@lastDropdownUser = false

		@userWithGeneratedButtons = {}

		@debugMode = debugMode

		@dropdownPaddingBottomLeft = 3
		@dropdownOpenedOnPanel = false

		@regexps =
			actionText: /\{\{actionText\}\}/
			action: /\{\{action\}\}/
			css: /\{\{css\}\}/

		oktellConnected = false
		@usersByNumber = {}
		@me = false
		@panelUsers = []
		@panelUsersFiltered = []
		@abonents = {}
		@hold = {}
		@oktell = oktell
		CUser.prototype.oktell = oktell
		@filter = false
		@panelEl = panelEl
		@dropdownEl = dropdownEl
		@dropdownElLiTemplate = @dropdownEl.html()
		@dropdownEl.empty()
		@keypadEl = @panelEl.find '.j_phone_keypad'
		@keypadIsVisible = false
		@usersListBlockEl = @panelEl.find '.j_main_list'
		@usersListEl = @usersListBlockEl.find 'tbody'
		@abonentsListBlock = @panelEl.find '.j_abonents'
		@abonentsListEl = @abonentsListBlock.find 'tbody'
		@holdBlockEl = @panelEl.find '.j_hold'
		@holdListEl = @holdBlockEl.find 'tbody'
		@queueBlockEl = @panelEl.find '.j_queue'
		@queueListEl = @queueBlockEl.find 'tbody'
		@filterInput = @panelEl.find 'input'
		@filterClearCross = @panelEl.find '.jInputClear_close'
		debouncedSetFilter = false

		@addScroll()

		@filterClearCross.bind 'click', =>
			@clearFilter()

		@filterInput.bind 'keyup', (e)=>
			if not debouncedSetFilter
				debouncedSetFilter = debounce =>
					@setFilter @filterInput.val()
				, 100

			if @filterInput.val()
				@filterClearCross.show()
			else
				@filterClearCross.hide()

			if e.keyCode is 13
				@filterInput.blur()
				setTimeout =>
					user = @panelUsersFiltered[0]
					user.doLastFirstAction()
					@clearFilter()
				, 50
			else
				debouncedSetFilter()
			return true

		@panelEl.on 'mouseenter', '.b_contact', ->
			$(this).data('user')?.isHovered true
		@panelEl.on 'mouseleave', '.b_contact', ->
			$(this).data('user')?.isHovered false

		@panelEl.on 'click', '.b_contact .drop_down', (e)=>
			dropdown = $(e.currentTarget)
			user = dropdown.closest('.b_button_action').data('user')
			if user
				@showDropdown user, dropdown.closest('.b_button_action'), user.loadOktellActions(), true

		@dropdownEl.on 'click', '[data-action]', (e) =>
			actionEl = $(e.currentTarget)
			action = actionEl.data 'action'
			user = @dropdownEl.data('user')
			if action and user
				user.doAction action
			@dropdownEl.hide()

		dropdownHideTimer = ''
		@dropdownEl.hover =>
			clearTimeout dropdownHideTimer
		, =>
			dropdownHideTimer = setTimeout =>
				@dropdownEl.fadeOut 150, =>
					@dropdownOpenedOnPanel = false

			, 500

		@panelEl.find('.j_keypad_expand').bind 'click', =>
			@toggleKeypadVisibility()
			@filterInput.focus()

		@keypadEl.find('li').bind 'click', (e) =>
			@filterInput.focus()
			@filterInput.val( @filterInput.val() + $(e.currentTarget).find('button').data('num') )
			@filterInput.keydown()

		oktell.on 'disconnect', =>
			oktellConnected = false

		oktell.on 'connect', =>
			oktellConnected = true
			oInfo = oktell.getMyInfo()
			oInfo.userid = oInfo.userid.toString().toLowerCase()
			@myNumber = oInfo.number?.toString()
			CUser.prototype.defaultAvatar = oInfo.defaultAvatar
			CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32
			CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64

			oUsers = oktell.getUsers()
			for oId, oUser of oUsers
				user = new CUser oUser
				if user.number
					@usersByNumber[user.number] = user
				if user.id isnt oInfo.userid
					@panelUsers.push user
				else
					@me = user

			@sortPanelUsers @panelUsers

			oktell.on 'stateChange', ( newState, oldState ) =>
				@reloadActions()

			oktell.onNativeEvent 'pbxnumberstatechanged', (data) =>
				for n in data.numbers
					numStr = n.num.toString()
					@usersByNumber[numStr]?.setState n.numstateid

			oktell.on 'abonentsChange', ( abonents ) =>
				@setAbonents abonents

			oktell.on 'holdStateChange', ( holdInfo ) =>
				#log 'Oktell holdStateChange', holdInfo
				@setHold holdInfo

			@setAbonents oktell.getAbonents()
			@setHold oktell.getHoldInfo()

			@setFilter ''

			setInterval =>
				if oktellConnected
					oktell.getQueue (data)=>
						if data.result
							@setQueue data.queue
			, if debugMode then 999999999 else 5000

			if typeof afterOktellConnect is 'function' then afterOktellConnect()

	getUserButtonForPlagin: (phone) ->
		user = @getUser phone
		@userWithGeneratedButtons[phone] = user
		button = user.getButtonEl()
		button.find('.drop_down').bind 'click', =>
			@showDropdown user, button, user.loadOktellActions()
		return button

	clearFilter: ->
		@filterInput.val ''
		@setFilter ''
		@filterInput.keyup()

	toggleKeypadVisibility: ->
		@setKeypadVisibility not @keypadIsVisible

	setKeypadVisibility: (visible) ->
		if visible? and Boolean(@keypadIsVisible) isnt Boolean(visible)
			@keypadIsVisible = Boolean(visible)
			@keypadEl.stop true, true
			if @keypadIsVisible
				@keypadEl.slideDown 200
			else
				@keypadEl.slideUp 200

	addEventListenersForButton: (user, button) ->
		button.bind 'click', =>
			user
			if user
				@showDropdown user, $(this)

	showDropdown: ( user, buttonEl, actions, onPanel ) ->
		t = @dropdownElLiTemplate
		@dropdownEl.empty()

		if actions?.length
			aEls = []
			for a in actions
				if typeof a is 'string' and @allActions[a]?.text
					aEls.push t.replace( @regexps.actionText, @allActions[a].text).replace( @regexps.action, a).replace( @regexps.css, @actionCssPrefix + a.toLowerCase() )

			if aEls.length

				@dropdownEl.append aEls

				@dropdownEl.children('li:first').addClass 'g_first'
				@dropdownEl.children('li:last').addClass 'g_last'

				@dropdownEl.data 'user', user

				@dropdownEl.css
					'top': if @dropdownEl.height() + buttonEl.offset().top > $(window).height() then $(window).height() - @dropdownEl.height() - @dropdownPaddingBottomLeft else buttonEl.offset().top,
					'left': Math.max @dropdownPaddingBottomLeft, buttonEl.offset().left - @dropdownEl.width() + buttonEl.width()
					'visibility': 'visible'
				@dropdownEl.fadeIn(100)
				@dropdownOpenedOnPanel = true if onPanel
			else
				@dropdownEl.hide()
		else
			@dropdownEl.hide()

	logUsers: ->
		for k,u of @panelUsersFiltered
			log u.getInfo()

	syncAbonentsAndUserlist: (abonents, userlist) ->
		absByNumber = {}
		$.each abonents, (i, ab) =>
			number = ab.phone.toString() or ''
			if not number then return
			absByNumber[number] = ab
			if not userlist[ab.phone.toString()]
				u = @getUser
					name: ab.name
					number: ab.phone
					id: ab.userid
					state: 5
				userlist[u.number] = u

		for uNumber, user of userlist
			if not absByNumber[user.number]
				delete userlist[user.number]

	setAbonents: (abonents) ->
		@syncAbonentsAndUserlist abonents, @abonents
		@setAbonentsHtml()

	setQueue: (queue) ->
		@syncAbonentsAndUserlist queue, @queue
		@setQueueHtml()

	setHold: (holdInfo) ->
		abs = []
		if holdInfo.hasHold
			abs = [holdInfo]
		@syncAbonentsAndUserlist abs, @hold
		@setHoldHtml()

	setPanelUsersHtml: (usersArray) ->
		@_setUsersHtml usersArray, @usersListEl

	setAbonentsHtml: ->
		@_setActivityPanelUserHtml @abonents, @abonentsListEl, @abonentsListBlock

	setHoldHtml: ->
		@_setActivityPanelUserHtml @hold, @holdListEl, @holdBlockEl

	setQueueHtml: ->
		@_setActivityPanelUserHtml @queue, @queueListEl, @queueBlockEl

	_setActivityPanelUserHtml: (users, listEl, blockEl) ->
		usersArray = []
		usersArray.push(u) for k,u of users
		@_setUsersHtml usersArray, listEl
		if usersArray.length and blockEl.is(':not(:visible)')
			blockEl.slideDown 200
		else if usersArray.length is 0 and blockEl.is(':visible')
			blockEl.slideUp 200


	_setUsersHtml: (usersArray, $el) ->
		html = []
		for u in usersArray
			#log 'render ' + u.getInfo()
			html.push u.getEl()
		$el.html html

	sortPanelUsers: ( usersArray ) ->
		usersArray.sort (a,b) ->
			if a.number and not b.number
				-1
			else if not a.number and b.number
				1
			else
				if a.state and not b.state
					-1
				else if not a.state and b.state
					1
				else
					if a.name > b.name
						1
					else if a.name < b.name
						-1

	setFilter: (filter) ->
		if @filter is filter then return false
		oldFilter = @filter
		@filter = filter
#		if @filterInput.val() isnt @filter
#			@filterInput.val @filter
		if filter is ''
			@panelUsersFiltered = [].concat @panelUsers
			@afterSetFilter(@panelUsersFiltered)
			return @panelUsersFiltered
		filteredUsers = []
		exactMatch = false

		if oldFilter.indexOf(@filter) is 0
			forFilter = @panelUsersFiltered
		else
			forFilter = @panelUsers

		for u in @panelUsers
			if u.isFiltered filter
				filteredUsers.push u
				if u.number is filter and not exactMatch
					exactMatch = u
		@panelUsersFiltered = if not exactMatch then [@getUser({name:filter, number: filter}, true)].concat(filteredUsers) else filteredUsers
		@afterSetFilter(@panelUsersFiltered)
		@panelUsersFiltered

	afterSetFilter: (filteredUsersArray) ->
		@setPanelUsersHtml filteredUsersArray

	getUser: (data, dontRemember) ->
		if typeof data is 'string' or typeof data is 'number'
			strNumber = data.toString()
		else
			strNumber = data.number.toString()

		if @usersByNumber[strNumber]
			return @usersByNumber[strNumber]

		fantom = new CUser
			number: strNumber
			name: data.name
			isFantom: true
			state: ( if data?.state? then data.state else 5 )

		if not dontRemember
			@usersByNumber[strNumber] = fantom
		fantom

	reloadActions: ->
		setTimeout =>
			for phone, user in @userWithGeneratedButtons
				user.loadActions()
		, 100

	addScroll: ->
		$el = @usersListBlockEl
		wrapper = ''
		scroller = ''
		scrollbar_cont = ''
		scrollbar_inner = ''
		scroller_left_while_scrolling = ''
		move_by_bar = ''
		pageY_end = ''
		pageY_start = ''
		pos = ''
		pos_start = ''
		scrolling = ''
		params = {}

		scrollWheelPos = (e, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
			#koef = get_koef(wrapper, scroller)
			#deltaY = deltaScale = ''
			e = e.originalEvent
			wheelDeltaY = if e.detail then e.detail*(-14) else e.wheelDelta / 3
			pos_start = get_position scroller
			pageY_end = get_pageY e

			if pos_start >=0 and wheelDeltaY > 0 or (pos_start+wheelDeltaY) > 0
				wheelDeltaY = 0
				pos_start = 0

			if (pos_start <= ( wrapper.height() - scroller.height() ) ) and wheelDeltaY < 0 or (pos_start+wheelDeltaY) < wrapper.height() - scroller.height()
				pos_start = wrapper.height() - scroller.height()
				wheelDeltaY = 0

			pos = pos_start + wheelDeltaY;
			return pos

		scrollClick = ( e, wrapper, scroller, scrollbar_cont, scrollbar_inner ) =>
			if e.type is START_EVENT
				if params.noMoveMouse
					return
				pageY_start = get_pageY e
				pos_start = get_position scroller
				scrolling = true
				#//document.title =  pos_start;


				$('body').css
					'-moz-user-select': 'none'
					'-ms-user-select': 'none'
					'-khtml-user-select': 'none'
					'-webkit-user-select': 'none'
					'-webkit-touch-callout': 'none'
					'user-select': 'none'

			else if e.type is MOVE_EVENT
				if not scrolling
					return

				if isTouch
					scroll_show scrollbar_inner

				koef_bar = get_koef wrapper, scroller
				pageY_end = get_pageY e
				if move_by_bar
					pos = pos_start*koef_bar - (pageY_end - pageY_start)
					pos = pos/koef_bar
				else
					pos = pos_start + (pageY_end - pageY_start)


				#// near borders
				if pos >= 0
					pos_start = get_position scroller
					pageY_start = pageY_end
					pos = 0

				max_pos = wrapper.height() - scroller.height()
				if pos <= max_pos
					pos_start = get_position scroller
					pageY_start = pageY_end
					pos = max_pos

				scrollTo pos, wrapper, scroller, scrollbar_cont, scrollbar_inner
				params.noMoveMouse = true

			else if e.type is END_EVENT
				if not scrolling
					return
				scrolling = false
				move_by_bar = false

				if isTouch
					scroll_hide scrollbar_inner

				$('body').css
					'-moz-user-select': ''
					'-ms-user-select': ''
					'-khtml-user-select': ''
					'-webkit-user-select': ''
					'-webkit-touch-callout': ''
					'user-select': ''

				if scroller_left_while_scrolling
					scroll_hide scrollbar_inner
			else
				return

#		SetHeightFromTo = (objFrom, objTo) =>
#			if typeof objFrom is "object"
#				height = objFrom.height()
#			else if typeof objFrom is "number"
#				height = objFrom
#			objTo.css 'height', height + 'px'

		scrollTo = (posTop, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
			scroll_show scrollbar_inner
			set_position scroller, posTop
			set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner

		get_pageY = (e) =>
			if isTouch then e.originalEvent.targetTouches[0].clientY else e.clientY

		set_position = ( object, pos ) =>
			object.css
				'position': 'relative',
				'top': pos

		get_position = ( object ) =>
			position = object.css 'top'
			if position is 'auto'
				position = 0

			parseInt position

		get_koef = ( wrapper, scroller ) =>
			w_height = wrapper.height()
			s_height = scroller.height()
			koef = w_height/s_height
			koef

		scroll_show = (scrollbar_inner) =>
			scrollbar_inner.stop true, true
			scrollbar_inner.fadeIn 100

		scroll_hide = (scrollbar_inner) =>
			scrollbar_inner.stop true, true
			scrollbar_inner.fadeOut "slow"

		set_bar_bounds = ( wrapper, scroller, scrollbar_cont, scrollbar_inner ) =>
			c_height = scrollbar_cont.height()
			koef = get_koef wrapper, scroller
			inner_height = c_height*koef;
			#/* hidden scroll if box size is bigger than content size */
			if koef >= 1
				visibility = 'hidden'
			else
				visibility = 'visible'

			scrollbar_inner.css
				'height': inner_height,
				'visibility': visibility

			scroller_position = get_position scroller
			wrapper_height = wrapper.height()
			scroller_height = scroller.height()

			if scroller_position <= 0 and scroller_position <= ( wrapper_height - scroller_height )
				pos = wrapper_height - scroller_height
				pos = Math.min pos, 0
				set_position scroller, pos

			pos_koef = scroller_position / wrapper_height
			pos = wrapper_height*pos_koef
			set_position scrollbar_inner, pos*koef*-1
			params?.onScroll?( { wrapper: wrapper, scroller: scroller, position: scroller_position, length: scroller_height } )

		scrolling = false
		move_by_bar = false

		# Device sniffing
		vendor = if (/webkit/i).test(navigator.appVersion)
			'webkit'
		else if (/firefox/i).test(navigator.userAgent)
			'Moz'
		else if 'opera' in window
			'O'
		else
			''
		#isIthing = (/iphone|ipad/gi).test(navigator.appVersion)
		isTouch = typeof window['ontouchstart'] isnt 'undefined'
		#has3d = window['WebKitCSSMatrix']? and (new window['WebKitCSSMatrix']() )['m11']?
		# Event sniffing
		START_EVENT = if isTouch then 'touchstart' else 'mousedown'
		MOVE_EVENT = if isTouch then 'touchmove' else 'mousemove'
		END_EVENT = if isTouch then 'touchend' else 'mouseup'
		WHEEL_EV = if vendor == 'Moz' then 'DOMMouseScroll' else 'mousewheel'


		if not isTouch and $('.jscroll_wrapper', $el).size()
			return

		init = =>
			# Create wrapper */
			$el.wrapInner '<div class="jscroll_wrapper" />'
			wrapper = $(".jscroll_wrapper", $el)
			wrapper.attr "id", "jscroll_id" + Math.round(Math.random()*10000000)

			# Create scroller */
			scroller = wrapper.wrapInner '<div class="jscroll_scroller" />'
			scroller = $(".jscroll_scroller", wrapper)

			# Create scrollbar cont */
			scrollbar_cont = $('<div class="jscroll_scrollbar_cont"></div>').insertAfter scroller
			scrollbar_cont.css
				'position': 'absolute'
				'right': '0px'
				'width': '13px'
				'top': '3px'
				'bottom': '6px'

			# Create scrollbar inner */
			scrollbar_inner = $('<div class="jscroll_scrollbar_inner"></div>').appendTo scrollbar_cont
			scrollbar_inner.css
				'position': 'relative'
				'width': '100%'
				'display': 'none'
				'opacity': '0.4'
				'cursor': 'pointer'

			scrollbar_bar = $('<div class="jscroll_scrollbar_bar"></div>').appendTo scrollbar_inner
			scrollbar_bar.css
				'position': 'relative'
				'background': 'black'
				'width': '5px'
				'margin': '0 auto'
				'border-radius': '3px'
				'height': '100%'
				'-webkit-border-radius': '3px'


			# set wrapper style*/
			wrapper.css
				"position": "relative"
				"height": "100%"
				"overflow": "hidden"

			# set scroller style*/
			scroller.css
				"min-height": "100%"
				"overflow": "hidden"

			if isTouch

				# Create scroller inner*/
				scroller.after '<div class="jscroll_scroller_inner" />'
				scroller_inner = $(".jscroll_scroller_inner", wrapper)
				scroller_inner.appendTo '<div></div>'

				myScroll = new iScroll wrapper.attr("id") ,
					hScrollbar: false
					scrollbarClass: 'jscroll_scroller_inner'
					checkDOMChanges: true
					bounceLock: true
					onScrollMove: =>
						params.onScroll()
						true
					onScrollEnd: =>
						params.onScroll()
						true

				return true

			else
				set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner

		init()

		if isTouch
			return

		# EVENTS */

		# resize container or change data
		jscroll_timer = new Array
		wrapper.bind 'resize', (e) =>
			timer_id = wrapper.attr('id')
			if typeof jscroll_timer[ timer_id ] isnt 'undefined'
				clearTimeout( jscroll_timer[ timer_id ] )

			jscroll_timer[ timer_id ] = setTimeout =>
				set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner
				delete jscroll_timer[ timer_id ]
			, 100
			return

		if not isTouch
			wrapper.hover =>
				scroller_left_while_scrolling = false
				set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner
				scroll_show scrollbar_inner
				return
			, =>
				scroller_left_while_scrolling = true
				if scrolling
					return
				scroll_hide scrollbar_inner
				return

		scrollbar_inner.bind START_EVENT, (e) =>
			move_by_bar = true
			params.noMoveMouse = false
			return true

		wrapper.bind START_EVENT, (e) =>
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		$(document).bind MOVE_EVENT, (e) =>
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		$(document).bind END_EVENT, (e) =>
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		wrapper.on WHEEL_EV, (e) =>
			wheelPos = scrollWheelPos e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			scrollTo wheelPos, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return false

