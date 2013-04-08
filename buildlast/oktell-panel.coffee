do ($)->
	if not $
		throw new Error('Error init oktell panel, jQuery ( $ ) is not defined')

	#includecoffee coffee/utils.coffee
	debounce = (func, wait, immediate) ->
		timeout = ''
		return ->
			context = this
			args = arguments
			later = ->
				timeout = null
				if not immediate
					result = func.apply(context, args)
	
			callNow = immediate and not timeout
			clearTimeout(timeout)
			timeout = setTimeout(later, wait)
			if callNow
				result = func.apply(context, args)
			result
	
	escapeHtml = (string) ->
		(''+string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;')
	#includecoffee coffee/jScroll.coffee
	jScroll = ( $el )->
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
	
				if window.iScroll?
					myScroll = new window.iScroll wrapper.attr("id") ,
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
	
	
	#includecoffee coffee/class/CUser.coffee
	class CUser
	
		constructor: (data) ->
			#@log 'create user', data
			@id = data.id?.toString().toLowerCase()
			@isFantom = data.isFantom or false
			@number = data.number?.toString() or ''
			@numberHtml = escapeHtml @number
			@name = data.name
			@nameHtml = if data.name then escapeHtml(data.name) else @numberHtml
			@state = false
			@avatarLink32x32 = data.avatarLink32x32 or @defaultAvatar32 or ''
			@defaultAvatarCss = if @avatarLink32x32 then '' else 'm_default'
			@hasHover = false
			@buttonLastAction = ''
			@firstLiCssPrefix = 'm_button_action_'
	
			@els = $()
			@buttonEls = $()
	
	#		@separateButtonEls = $()
			@init(data)
	
	
		init: (data) ->
			#@log 'init user', data
			@id = data.id?.toString().toLowerCase()
			@isFantom = data.isFantom or false
			@number = data.number?.toString() or ''
			@numberHtml = escapeHtml @number
			@name = data.name
			@nameHtml = if data.name then escapeHtml(data.name) else @numberHtml
			@avatarLink32x32 = data.avatarLink32x32 or @defaultAvatar32 or ''
			@defaultAvatarCss = if @avatarLink32x32 then '' else 'm_default'
			@loadActions()
	
			if data.numberObj?.state?
				@setState data.numberObj.state
			else if data.state?
				@setState data.state
			else
				@setState 1
	
	
		regexps:
			name: /\{\{name\}\}/
			number: /\{\{number\}\}/
			avatarLink32x32: /\{\{avatarLink32x32\}\}/
			css: /\{\{css\}\}/
	
		setState: (state) ->
			state = parseInt state
			if state is @state
				return
			@state = state
			if @els.length
				if @state is 0
					@els.removeClass('m_busy').addClass('m_offline')
				else if @state is 5
					@els.removeClass('m_offline').addClass('m_busy')
				else
					@els.removeClass('m_offline').removeClass('m_busy')
			if @buttonEls.length
				#log 'LOAD actions after state change '
				@loadActions()
				setTimeout =>
					@loadActions()
				, 100
	
		getInfo: ->
			'"'+@number+'" ' + @state + ' ' + @name
	
		isFiltered: (filter) ->
			if not filter or typeof filter isnt 'string'
				return true
	
			if ( @number and @number.indexOf(filter) isnt -1 ) or ( ' ' + @name ).toLowerCase().indexOf(filter) isnt -1
				return true
	
			return false
	
		getEl: ->
			str = @template.replace( @regexps.name, @nameHtml)
				.replace( @regexps.number, @numberHtml)
				.replace( @regexps.avatarLink32x32, @avatarLink32x32)
				.replace( @regexps.css, @defaultAvatarCss )
			$el = $(str)
			@els = @els.add $el
			$el.data 'user', @
			@initButtonEl $el.find '.oktell_button_action'
			return $el
	
		initButtonEl: ($el) ->
			@buttonEls = @buttonEls.add $el
			$el.data 'user', @
			$el.children(':first').bind 'click', =>
				@doAction @buttonLastAction
			if @buttonLastAction then $el.addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
	
		getButtonEl: () ->
			$el = $(@buttonTemplate)
			@initButtonEl $el
	#		@separateButtonEls = @separateButtonEls.add $el
			return $el
	
		isHovered: (isHovered) ->
			if @hasHover is isHovered then return
			@hasHover = isHovered
			if @hasHover
				@loadActions()
	
		loadOktellActions: ->
			actions = @oktell.getPhoneActions @id or @number
			@log 'actions for ' + @getInfo(), actions
			actions
	
		loadActions: ()->
			actions = @loadOktellActions()
			#log 'load action for user id='+@id+' number='+@number+' actions='+actions
			#window.cuser = @
			action = actions?[0] or ''
			if @buttonLastAction is action
				return actions
	
			if @buttonLastAction
				@buttonEls.removeClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
	
			if action
	#			if not @buttonLastAction
	#				needShowSeparateButtons = true
				@buttonLastAction = action
				@buttonEls.addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
	#			if needShowSeparateButtons
	#				@separateButtonEls.show()
			else
				@buttonLastAction = ''
	#			@separateButtonEls.hide()
			actions
	
	
	
		doAction: (action) =>
	
			if not action
				return
	
			target = @number
	
			switch action
				when 'call'
					@oktell.call target
				when 'conference'
					@oktell.conference target
				when 'intercom'
					@oktell.intercom target
				when 'transfer'
					@oktell.transfer target
				when 'toggle'
					@oktell.toggle()
				when 'ghostListen'
					@oktell.ghostListen target
				when 'ghostHelp'
					@oktell.ghostHelp target
				when 'ghostConference'
					@oktell.ghostConference target
				when 'endCall'
					@oktell.endCall target
	
	
		doLastFirstAction: ->
			if @buttonLastAction
				@doAction @buttonLastAction
				true
			else false
	#includecoffee coffee/class/List.coffee

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
			@queue = {}
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
			@talkTimeEl = @abonentsListBlock.find '.b_marks_time'
			@holdBlockEl = @panelEl.find '.j_hold'
			@holdListEl = @holdBlockEl.find 'tbody'
			@queueBlockEl = @panelEl.find '.j_queue'
			@queueListEl = @queueBlockEl.find 'tbody'
			@filterInput = @panelEl.find 'input'
			@filterClearCross = @panelEl.find '.jInputClear_close'
			debouncedSetFilter = false
	
			@usersWithBeforeConnectButtons = []
	
			@jScroll @usersListBlockEl
			@usersScroller = @usersListBlockEl.find('.jscroll_scroller')
			@userScrollerToTop = =>
				@usersScroller.css({top:'0px'})
	
			@filterClearCross.bind 'click', =>
				@clearFilter()
	
			@filterInput.bind 'keyup', (e)=>
				if not @oktellConnected
					return true
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
	
			@panelEl.bind 'mouseenter', ->
				$(this).data('user')?.isHovered true
			@panelEl.bind 'mouseleave', ->
				$(this).data('user')?.isHovered false
	
			@panelEl.bind 'click', (e)=>
				target = $(e.target)
				if not target.is('.b_contact .drop_down') and target.closest('.b_contact .drop_down').size() is 0
					return true
				buttonEl = target.closest('.oktell_button_action')
				if buttonEl.size() is 0
					return true
				user = buttonEl.data('user')
				if user
					@showDropdown user, buttonEl, user.loadOktellActions(), true
	
			@dropdownEl.bind 'click', (e) =>
				target = $(e.target)
				if target.is('[data-action]')
					actionEl = target
				else if target.closest('[data-action]').size() isnt 0
					actionEl = target.closest('[data-action]')
				else
					return true
				action = actionEl.data 'action'
				if not action then return
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
				@filterInput.keyup()
	
			@setUserListHeight = =>
				@usersListBlockEl.css
					height: $(window).height() - @usersListBlockEl[0].offsetTop + 'px'
	
			@setUserListHeight()
	
			debouncedSetHeight = debounce =>
				@userScrollerToTop()
				@setUserListHeight()
			, 50
			$(window).bind 'resize', ->
				debouncedSetHeight()
	
			oktell.on 'disconnect', =>
				@oktellConnected = false
				@usersByNumber = {}
				@panelUsers = []
				@setPanelUsersHtml []
				@setAbonents []
				@setHold {hasHold:false}
				@filterInput.val('')
				@setFilter '', true
				@setQueue []
	
	
			oktell.on 'connect', =>
				@oktellConnected = true
				oInfo = oktell.getMyInfo()
				oInfo.userid = oInfo.userid.toString().toLowerCase()
				@myNumber = oInfo.number?.toString()
				CUser.prototype.defaultAvatar = oInfo.defaultAvatar
				CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32
				CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64
	
				oUsers = oktell.getUsers()
				for own oId, oUser of oUsers
					strNumber = oUser.number?.toString() or ''
					if @usersByNumber[strNumber]
						user = @usersByNumber[strNumber]
						oUser.isFantom = false
						user.init oUser
					else
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
	
				oktell.on 'talkTimer', (seconds, formattedTime) =>
					if seconds is false
						@talkTimeEl.text ''
					else
						@talkTimeEl.text formattedTime
	
	
				@setAbonents oktell.getAbonents()
				@setHold oktell.getHoldInfo()
	
				@setFilter '', true
	
				oktell.on 'queueChange', (queue) =>
					@setQueue queue
				oktell.getQueue (data) =>
					@setQueue data.queue if data.result
	
				for user in @usersWithBeforeConnectButtons
					user.loadActions()
	
				if typeof afterOktellConnect is 'function' then afterOktellConnect()
	
		getUserButtonForPlugin: (phone) ->
			user = @getUser phone
			if not @oktellConnected
				@usersWithBeforeConnectButtons.push user
			#log '!!! getUserButtonForPlugin for ' + user.getInfo()
			@userWithGeneratedButtons[phone] = user
			button = user.getButtonEl()
			button.find('.drop_down').bind 'click', =>
				actions = user.loadActions()
				@showDropdown user, button, actions
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
					@keypadEl.slideDown 200, @setUserListHeight
				else
					@keypadEl.slideUp 200, @setUserListHeight
	
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
			for own k,u of @panelUsersFiltered
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
	
			for own uNumber, user of userlist
				if not absByNumber[user.number]
					delete userlist[user.number]
	
		setAbonents: (abonents) ->
			@syncAbonentsAndUserlist abonents, @abonents
			@setAbonentsHtml()
	
		setQueue: (queue) ->
			@syncAbonentsAndUserlist queue, @queue
			for own key, user of @queue
				user.loadActions()
			@setQueueHtml()
	
		setHold: (holdInfo) ->
			abs = []
			if holdInfo.hasHold
				abs = [holdInfo.abonent]
			@syncAbonentsAndUserlist abs, @hold
			@setHoldHtml()
	
		setPanelUsersHtml: (usersArray) ->
			@_setUsersHtml usersArray, @usersListEl
			@userScrollerToTop()
	
		setAbonentsHtml: ->
			@_setActivityPanelUserHtml @abonents, @abonentsListEl, @abonentsListBlock
	
		setHoldHtml: ->
			@_setActivityPanelUserHtml @hold, @holdListEl, @holdBlockEl
	
		setQueueHtml: ->
			@_setActivityPanelUserHtml @queue, @queueListEl, @queueBlockEl
	
		_setActivityPanelUserHtml: (users, listEl, blockEl) ->
			usersArray = []
			usersArray.push(u) for own k,u of users
			@_setUsersHtml usersArray, listEl
			if usersArray.length and blockEl.is(':not(:visible)')
				blockEl.slideDown 200, @setUserListHeight
			else if usersArray.length is 0 and blockEl.is(':visible')
				blockEl.slideUp 200, @setUserListHeight
	
	
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
	
		setFilter: (filter, reloadAnyway) ->
			if @filter is filter and not reloadAnyway then return false
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
				@usersByNumber[strNumber].init(data) if @usersByNumber[strNumber].isFantom
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
				for own phone, user of @userWithGeneratedButtons
					actions = user.loadActions()
					#log 'reload actions for ' + user.getInfo() + ' ' + actions
			, 100
	
	defaultOptions =
		position: 'right'
		dynamic: true
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

	getOptions = ->
		options or defaultOptions

	log = ->
		if not getOptions().debug then return
		try
			console.log.apply(console, arguments);
		catch e


	templates = {'templates/actionButton.html':'<ul class="oktell_button_action"><li class="g_first"><i></i></li><li class="g_last drop_down"><i></i></li></ul>', 'templates/actionList.html':'<ul class="oktell_actions_group_list"><li class="{{css}}" data-action="{{action}}"><i></i><span>{{actionText}}</span></li></ul>', 'templates/user.html':'<tr class="b_contact"><td class="b_contact_avatar {{css}}"><img src="{{avatarLink32x32}}"><i></i><div class="o_busy"></div></td><td class="b_contact_title"><div class="wrapword"><a><b>{{name}}</b><span class="o_number">{{number}}</span></a></div>{{button}}</td></tr>', 'templates/panel.html':'<div class="oktell_panel"><div class="i_panel_bookmark"><div class="i_panel_bookmark_bg"></div></div><div class="h_panel_bg"><div class="h_padding"><div class="b_marks i_conference j_abonents"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{inTalk}}</span><span class="b_marks_time"></span></p><table><tbody></tbody></table></div></div><div class="b_marks i_flash j_hold"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{onHold}}</span></p><table class="j_table_favorite"><tbody></tbody></table></div></div><div class="b_marks i_flash j_queue"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{queue}}</span></p><table class="j_table_queue"><tbody></tbody></table></div></div><div class="b_inconversation j_phone_block"><table class="j_table_phone"><tbody></tbody></table></div><div class="b_marks i_phone"><div class="h_shadow_bottom"><div class="h_phone_number_input"><div class="i_phone_state_bg"></div><div class="h_input_padding"><div class="i_phone_popup_button j_keypad_expand"><i></i></div><div class="jInputClear_hover"><input class="b_phone_number_input" type="text" placeholder="{{inputPlaceholder}}"><span class="jInputClear_close">&times;</span></div></div><div class="b_phone_keypad j_phone_keypad"><div class="l_column_group"><div class="h_phone_keypad"><ul class="b_phone_panel"><li class="g_top_left g_first"><button data-num="1" class="g_button m_big">1</button></li><li><button data-num="2" class="g_button m_big">2</button></li><li class="g_top_right g_right"><button data-num="3" class="g_button m_big">3</button></li><li class="g_float_celar g_first"><button data-num="4" class="g_button m_big">4</button></li><li><button data-num="5" class="g_button m_big">5</button></li><li class="g_right"><button data-num="6" class="g_button m_big">6</button></li><li class="g_float_celar g_first"><button data-num="7" class="g_button m_big">7</button></li><li><button data-num="8" class="g_button m_big">8</button></li><li class="g_right"><button data-num="9" class="g_button m_big">9</button></li><li class="g_bottom_left g_float_celar g_first"><button data-num="*" class="g_button m_big">&lowast;</button></li><li class="g_bottom_center"><button data-num="0" class="g_button m_big">0</button></li><li class="g_bottom_right g_right"><button data-num="#" class="g_button m_big">#</button></li></ul></div></div></div></div></div></div><div class="h_main_list j_main_list"><table class="b_main_list"><tbody></tbody></table></div></div></div></div>', 'templates/callPopup.html':'<div class="oktell_panel_popup" style="display: none"><div class="l_popup_content"><div class="b_popup_box" style="display: block"><div class="h_padding"><i class="o_close"></i><h1>Входящий вызов</h1><div class="b_comming_call_user"><div class="h_padding"><table><tbody data-cont="call_popup"></tbody></table></div></div><a class="btn m_big close_action" href="#" style="float: right">Скрыть</a><a class="btn m_big m_button_green" href="#" style="margin-right: 20px; float: left; display: none"><i></i>Ответить</a><a class="btn m_big m_button_red j_abort_action" href="#"><i></i>Отклонить</a></div></div></div></div>', }

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

		panelPos = getOptions().position
		animOptShow = {}
		animOptShow[panelPos] = '0px'
		animOptHide = {}
		animOptHide[panelPos] = '-281px'

		$("body").append(panelEl)

		list = new List oktell, panelEl, actionListEl, afterOktellConnect, getOptions().debug
		if getOptions().debug
			window.wList = list

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
