# Oktell-panel.js 0.1.2 http://js.oktell.ru/webpanel

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
	
	log = ->
		try
			console.log.apply(console, arguments);
		catch e
	
	cookie = (key, value, options) ->
	
		# key and at least value given, set cookie...
		if arguments.length > 1 and String(value) isnt "[object Object]"
			options = $.extend {}, options
	
			if not value?
				options.expires = -1
	
			if typeof options.expires is 'number'
				seconds = options.expires
				t = options.expires = new Date()
				t.setSeconds t.getSeconds() + seconds
	
			value = String value
	
			return document.cookie = [
				encodeURIComponent(key), '=',
				if options.raw then value else encodeURIComponent(value),
				if options.expires then '; expires=' + options.expires.toUTCString() else '', # use expires attribute, max-age is not supported by IE
				if options.path then '; path=' + options.path else '',
				if options.domain then '; domain=' + options.domain else '',
				if options.secure then '; secure' else ''
			].join('')
	
	
		# key and possibly options given, get cookie...
		options = value or {}
		result = ''
		if options.raw
			decode = (s) -> s
		else
			decode = decodeURIComponent
	
		if (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie))
			decode(result[1])
		else
			null
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
	
	
	#includecoffee coffee/class/Department.coffee
	class Department
		logGroup: 'Department'
		constructor: ( id, name )->
			@usersVisibilityCss = 'invisibleDep'
			@lastFilteredUsers = []
			@isSorted = false
			@visible = true
			@users = []
			@id = if id and id isnt '00000000-0000-0000-0000-000000000000' then id else @withoutDepName
			@name = if @id is @withoutDepName or not name then @langs.panel.withoutDepartment else name
			@isOpen = if @config().departmentVisibility[@id]? then @config().departmentVisibility[@id] else true
	
		getEl: (usersVisible)->
			@log 'get el, usersVisible - ' + usersVisible + ' , for department ' + @getInfo()
			if not @el
				@el = $(@template.replace /\{\{department}\}/g, escapeHtml(@name))
				@el.find('.b_department_header').bind 'click', =>
					@showUsers()
			if usersVisible
				@_oldIsOpen = @isOpen
				@showUsers true, true
			else
				@showUsers if @_oldIsOpen? then @_oldIsOpen else @isOpen
			@el
		getContainer: ->
			@el.find('tbody')
	
		showUsers: (val, notSave)->
			if typeof val is 'undefined'
				val = ! @isOpen
			if not @hideEl
				@hideEl = @el.find 'table'
			@log 'department users visibility set ' + val + ' , without save - ' + notSave + '. For ' + @getInfo()
	
			@hideEl.stop true, true
			if not notSave
				@isOpen = val
				c = @config()
				c.departmentVisibility[@id] = @isOpen
				@config c
			if val
				#@hideEl.slideDown 200
				@el.toggleClass @usersVisibilityCss, false
				@hideEl.show()
			else
				#@hideEl.slideUp 200
				@el.toggleClass @usersVisibilityCss, true
				@hideEl.hide()
	
	
	
		getInfo: ->
			@name + ' ' + @id
	
		clearUsers: ->
			@users = []
	
		show: (withAnimation) ->
			if not @el or @visible then return
			if withAnimation
				@el.slideDown 200
			else
				@el.show()
			@visible = true
		hide: (withAnimation) ->
			if not @el or not @visible then return
			if withAnimation
				@el.slideUp 200
			else
				@el.hide()
			@visible = false
	
		getUsers: (filter, showOffline) ->
			if not @isSorted
				@sortUsers()
	
			users = []
			exactMatch = false
			if filter is ''
				if showOffline
					users = [].concat @users
				else
					for u in @users
						if u.state isnt 0
							users.push u
			else
				for u in @users
					if u.isFiltered filter, showOffline
						users.push u
						if u.number is filter and not exactMatch
							exactMatch = u
			@lastFilteredUsers = users
			[users, exactMatch]
	
	
	
		sortUsers: ->
			@users.sort @sortFn
	
		sortFn: (a,b)->
			if a.nameLower > b.nameLower
				1
			else if a.nameLower < b.nameLower
				-1
			else
				if a.number > b.number
					1
				else if	a.number < b.number
					-1
				else
					0
	
	
		addUser: ( user ) ->
			if user.number
				@users.push user
	
	
	
	
	
	
	
	
	#includecoffee coffee/class/CUser.coffee
	class CUser
		logGroup: 'User'
		constructor: (data) ->
			#@log 'create user', data
			#@id = data.id?.toString().toLowerCase()
			#@isFantom = data.isFantom or false
			#@number = data.number?.toString() or ''
			#@numberFormatted = data.numberFormatted?.toString() or @number
			#@numberHtml = escapeHtml @numberFormatted
			#@name = data.name
			#@nameHtml = if data.name then escapeHtml(data.name) else @numberHtml
			@state = false
			#@avatarLink32x32 = data.avatarLink32x32 or @defaultAvatar32 or ''
			#@defaultAvatarCss = if @avatarLink32x32 then '' else 'm_default'
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
			@invisible = true unless @number
			@numberFormatted = data.numberFormatted?.toString() or @number
			@numberHtml = escapeHtml @numberFormatted
			@name = data.name?.toString() or ''
			@nameLower = @name.toLowerCase()
			@letter = @name[0]?.toUpperCase() or @number?[0].toString().toLowerCase()
			@nameHtml = if data.name and data.name.toString() isnt @number then escapeHtml(data.name) else @numberHtml
			ns = @nameHtml.split(/\s+/)
			if ns.length > 1
				@nameHtml = '<b>' + ns[0] + '</b> ' + ns.splice(1)
	
			lastHtml = @elNumberHtml
			@elNumberHtml = if @numberHtml isnt @nameHtml then @numberHtml else ''
			if @elNumberHtml isnt lastHtml and @el?
				@el.find('.o_number').text @elNumberHtml
			@el?.find('.b_contact_title b').text @nameHtml
	
			@avatarLink32x32 = data.avatarLink32x32 or @defaultAvatar32 or ''
			@defaultAvatarCss = if @avatarLink32x32 then '' else 'm_default'
			@departmentId = if data?.numberObj?.departmentid and data?.numberObj.departmentid isnt '00000000-0000-0000-0000-000000000000' then data?.numberObj.departmentid else @withoutDepName
			@department = if @departmentId is 'www_without' then @langs.panel.withoutDepartment else data?.numberObj?.department
			#@log 'depId ' + (data?.numberObj?.departmentid) + ' ' + data?.numberObj?.department + ' : ' + @departmentId + ' ' + @department
	
			if data.numberObj?.state?
				@setState data.numberObj.state
			else if data.state?
				@setState data.state
			else
				@setState 1
	
			@loadActions()
	
		regexps:
			name: /\{\{name\}\}/
			number: /\{\{number\}\}/
			avatarLink32x32: /\{\{avatarLink32x32\}\}/
			css: /\{\{css\}\}/
			letter: /\{\{letter\}\}/
	
		setState: (state) ->
			state = parseInt state
			if state is @state
				return
			@state = state
			@setStateCss()
			if @buttonEls.length
				#log 'LOAD actions after state change '
				@loadActions()
				setTimeout =>
					@loadActions()
				, 100
	
		setStateCss: ->
			if @els.length
				if @state is 0
					@els.removeClass('m_busy').addClass('m_offline')
				else if @state is 5
					@els.removeClass('m_offline').addClass('m_busy')
				else
					@els.removeClass('m_offline').removeClass('m_busy')
	
		getInfo: ->
			'"'+@number+'" ' + @state + ' ' + @name
	
		isFiltered: (filter, showOffline) ->
			if ( not filter or typeof filter isnt 'string' ) and ( showOffline or ( not showOffline and @state isnt 0 ) )
				return true
	
			if ( showOffline or ( not showOffline and @state isnt 0 ) ) and ( ( @number and @number.indexOf(filter) isnt -1 ) or ( ' ' + @name ).toLowerCase().indexOf(filter) isnt -1 )
				return true
	
			return false
	
		showLetter: (show)->
			@el?.find('.b_capital_letter span').text if show then @letter else ''
	
		getEl: ( createIndependent) ->
			if not @el or createIndependent
				str = @template.replace( @regexps.name, @nameHtml)
					.replace( @regexps.number, if @numberHtml isnt @nameHtml then @numberHtml else '' )
					.replace( @regexps.avatarLink32x32, @avatarLink32x32)
					.replace( @regexps.css, @defaultAvatarCss )
				$el = $(str)
				$el.data 'user', @
				@initButtonEl $el.find '.oktell_button_action'
				@els = @els.add $el
				@setStateCss()
				if not @el
					@el = $el
			$el = $el or @el
			return $el
	
		initButtonEl: ($el) ->
			#@log 'init button el for ' + @getInfo()
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
			#@log 'actions for ' + @getInfo(), actions
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
	
			@beforeAction?(action)
	
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
	
		letterVisibility: (show)->
			if @el and @el.length
				if show
					@el.find('.b_capital_letter span').text @letter
				else
					@el.find('.b_capital_letter span').text ''
	#includecoffee coffee/class/List.coffee
	class List
		logGroup: 'List'
		constructor: (oktell, panelEl, dropdownEl, afterOktellConnect, debugMode) ->
	
			@defaultConfig =
				departmentVisibility: {}
				showDeps: true
				showOffline: false
	
			@allActions =
				call: { icon: '/img/icons/action/call.png', iconWhite: '/img/icons/action/white/call.png', text: @langs.actions.call }
				conference : { icon: '/img/icons/action/confinvite.png', iconWhite: '/img/icons/action/white/confinvite.png', text: @langs.actions.conference }
				transfer : { icon: '/img/icons/action/transfer.png', text: @langs.actions.transfer }
				toggle : { icon: '/img/icons/action/toggle.png', text: @langs.actions.toggle }
				intercom : { icon: '/img/icons/action/intercom.png', text: @langs.actions.intercom }
				endCall : { icon: '/img/icons/action/endcall.png', iconWhite: '/img/icons/action/white/endcall.png', text: @langs.actions.endCall }
				ghostListen : { icon: '/img/icons/action/ghost_monitor.png', text: @langs.actions.ghostListen }
				ghostHelp : { icon: '/img/icons/action/ghost_help.png', text: @langs.actions.ghostHelp }
	
			@actionCssPrefix = 'i_'
			@lastDropdownUser = false
			self = @
			CUser.prototype.beforeAction = (action)->
				self.beforeUserAction this, action
	
			@departments = []
			@departmentsById = {}
	
			@simpleListEl = $(@usersTableTemplate)
	
			@filterFantomUserNumber = false
	
			@userWithGeneratedButtons = {}
	
			@debugMode = debugMode
	
			@dropdownPaddingBottomLeft = 3
			@dropdownOpenedOnPanel = false
	
			@regexps =
				actionText: /\{\{actionText\}\}/
				action: /\{\{action\}\}/
				css: /\{\{css\}\}/
				dep: /\{\{department}\}/g
	
			oktellConnected = false
			@usersByNumber = {}
			@me = false
			@oktell = oktell
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
			@usersListEl = @simpleListEl.find 'tbody'
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
	
			@buttonShowOffline = @panelEl.find '.b_list_filter .i_online'
			@buttonShowDeps = @panelEl.find '.b_list_filter .i_group'
	
			@buttonShowOffline.bind 'click', =>
				@config
					showOffline: not @showOffline
				@setFilter @filter, true
	
			@buttonShowDeps.bind 'click', =>
				@config
					showDeps: not @showDeps
				@setFilter @filter, true
	
	
	
			@usersWithBeforeConnectButtons = []
	
	
	
			@config()
	
			Department.prototype.config = (args...)=>
				@config.apply @, args
	
			@allUserDep = new Department 'all_user_dep', 'allUsers'
			@allUserDep.template = @usersTableTemplate
	
			@exactMatchUserDep = new Department 'exact_match_user_dep', 'exactUser'
			@exactMatchUserDep.template = @usersTableTemplate
	
	
			@userScrollerToTop = =>
				if not @_jScrolled
					@jScroll @usersListBlockEl
					@usersScroller = @usersListBlockEl.find('.jscroll_scroller')
				@usersScroller.css({top:'0px'})
	
			@filterClearCross.bind 'click', =>
				@clearFilter()
	
			@filterInput.bind 'keyup', (e)=>
				if not @oktellConnected
					return true
				if not debouncedSetFilter
					debouncedSetFilter = debounce =>
						@setFilter @filterInput.val().toString().toLowerCase()
					, 100
	
				if @filterInput.val()
					@filterClearCross.show()
				else
					@filterClearCross.hide()
	
				if e.keyCode is 13
					@filterInput.blur()
					setTimeout =>
						@usersListBlockEl.find('tr:first').data('user')?.doLastFirstAction()
						@clearFilter()
					, 50
				else
					debouncedSetFilter()
				return true
	
	#		@panelEl.bind 'mouseenter', (e)=>
	#			#$(this).data('user')?.isHovered true
	#			#@log 'Mouse enter to ' + e.target
	#		@panelEl.bind 'mouseleave', ->
	#			$(this).data('user')?.isHovered false
	
			@panelEl.bind 'click', (e)=>
				target = $(e.target)
				if target.is('.oktell_button_action .g_first')
					actionButton = target.parent()
				else if target.is('.oktell_button_action .g_first i')
					actionButton = target.parent().parent()
				else if target.is('.b_contact .drop_down')
					buttonEl = target.parent()
				else if target.is('.b_contact .drop_down i')
					buttonEl = target.parent().parent()
				if (not actionButton? and not buttonEl?) or ( actionButton and actionButton.size() is 0 ) or ( buttonEl and buttonEl.size() is 0 )
					return true
	
				if actionButton? and actionButton.size()
					user = actionButton.data('user')
					user?.doLastFirstAction()
					return true
	
				if buttonEl? and buttonEl.size()
					user = buttonEl.data('user')
					if user
						@showDropdown user, buttonEl, user.loadOktellActions(), true
					return true
	
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
				for phone,user of @userWithGeneratedButtons
					user.loadActions()
	
	
			oktell.on 'connect', =>
				@oktellConnected = true
				oInfo = oktell.getMyInfo()
				oInfo.userid = oInfo.userid.toString().toLowerCase()
				@myNumber = oInfo.number?.toString()
				CUser.prototype.defaultAvatar = oInfo.defaultAvatar
				CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32
				CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64
	
				@departments = []
				@departmentsById = {}
				createdDeps = {}
	
				otherDep = new Department()
	
	
				oUsers = oktell.getUsers()
				for own oId, oUser of oUsers
					strNumber = oUser.number?.toString() or ''
					if not strNumber
						continue
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
						if user.departmentId and user.departmentId isnt '00000000-0000-0000-0000-000000000000'
							if createdDeps[user.departmentId]
								dep = createdDeps[user.departmentId]
							else
								dep = createdDeps[user.departmentId] = new Department( user.departmentId, user.department )
								@departments.push dep
								@departmentsById[user.departmentId] = dep
							dep.addUser user
						else
							otherDep.addUser user
						@allUserDep.addUser user
					else
						@me = user
	
				@departments.sort (a,b)=>
					if a.name > b.name
						1
					else if b.name > a.name
						-1
					else 0
	
				@departments.push otherDep
	
				#@sortPanelUsers @panelUsers
	
				oktell.on 'stateChange', ( newState, oldState ) =>
					@reloadActions()
	
				oktell.onNativeEvent 'pbxnumberstatechanged', (data) =>
					for n in data.numbers
						numStr = n.num.toString()
						user = @usersByNumber[numStr]
						if user
							@log ''
							@log 'start user state change from ' + user.state + ' to ' + n.numstateid + ' for ' + user.getInfo()
							if @showDeps
								dep = @departmentsById[user.departmentId]
							else
								dep = @allUserDep
							@log 'current visibility settings are ShowDeps='+@showDeps+' and ShowOffline=' + @showOffline
							wasFiltered = user.isFiltered @filter, @showOffline
							@log 'user was filtered earlier = ' + wasFiltered
							user.setState n.numstateid
							userNowIsFiltered = user.isFiltered @filter, @showOffline
							@log 'after user.setState, now user filtered = ' + userNowIsFiltered
							if not userNowIsFiltered
								@log 'now user isnt filtered'
								if dep.getContainer().children().length is 1
									@log 'container contains only users el, so refilter all list'
									@setFilter @filter, true
								else
									@log 'remove his html element'
									user.el?.remove?()
							else if not wasFiltered
								@log 'user now filtered and was not filtered before state change'
								dep.getUsers @filter, @showOffline
								@log 'refilter all user of department ' + dep.getInfo()
								index = dep.lastFilteredUsers.indexOf user
								@log 'index of user in refiltered users list is ' + index
								if index isnt -1
									if not dep.getContainer().is(':visible')
										@log 'dep container is hidden, so, refilter all users list'
										@setFilter @filter, true
									else
										if index is 0
											@log 'add user html to start of department container'
											dep.getContainer().prepend user.getEl()
										else
											@log 'add user html after prev user html element'
											dep.lastFilteredUsers[index-1]?.el?.after user.getEl()
	
										if dep.lastFilteredUsers[index-1]?.letter is user.letter
											@log 'hide user letter because it is like prev user letter ' + user.letter
											user.letterVisibility false
										else if dep.lastFilteredUsers[index+1]?.letter is user.letter
											@log 'hide prev user letter because it is like user letter ' + user.letter
											dep.lastFilteredUsers[index+1].letterVisibility false
	
							@log 'end user state change'
							@log ''
	
	
	
	
	
	
	
				oktell.on 'abonentsChange', ( abonents ) =>
					@setAbonents abonents
					@reloadActions()
	
				oktell.on 'holdStateChange', ( holdInfo ) =>
					#log 'Oktell holdStateChange', holdInfo
					@setHold holdInfo
					@reloadActions()
	
				oktell.on 'talkTimer', (seconds, formattedTime) =>
					if seconds is false
						@talkTimeEl.text ''
					else
						@talkTimeEl.text formattedTime
	
	
				@setAbonents oktell.getAbonents()
				@setHold oktell.getHoldInfo()
	
	#			depsEls = $()
	#			for d in @departments
	#				depsEls = depsEls.add d.getEl()
	#
	#			@usersListBlockEl.html depsEls
	
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
					@keypadEl.slideDown
						duration: 200
						easing: 'linear'
						done: @setUserListHeight
				else
					@keypadEl.slideUp
						duration: 200
						easing: 'linear'
						done: @setUserListHeight
	
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
				if not ab then return
				number = ab.phone.toString() or ''
				if not number then return
				absByNumber[number] = ab
				if not userlist[ab.phone.toString()]
					u = @getUser
						name: ab.name
						number: ab.phone
						id: ab.userid
						state: 1
					userlist[u.number] = u
	
			for own uNumber, user of userlist
				if not absByNumber[user.number]
					delete userlist[user.number]
	
		setAbonents: (abonents) ->
			@syncAbonentsAndUserlist abonents, @abonents
			@setAbonentsHtml()
	
		setQueue: (queue) ->
			if @oktell.getState() is 'ring'
				for ab, key in queue
					if @abonents[ab.phone]
						delete queue[key]
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
			@_setUsersHtml usersArray, listEl, true
			if usersArray.length and blockEl.is(':not(:visible)')
				blockEl.slideDown 200, @setUserListHeight
			else if usersArray.length is 0 and blockEl.is(':visible')
				blockEl.slideUp 200, @setUserListHeight
	
	
		_setUsersHtml: (usersArray, $el, useIndependentCopies ) ->
			html = []
			lastDepId = null
			prevLetter = ''
			for u in usersArray
				#log 'render ' + u.getInfo()
				html.push u.getEl useIndependentCopies
				#html = html.add u.getEl useIndependentCopies
				u.showLetter if prevLetter isnt u.letter then true else false
				prevLetter = u.letter
			$el.children().detach()
			$el.html html
	
	#	sortPanelUsers: ( usersArray ) ->
	#		usersArray.sort (a,b) =>
	#			if a.departmentId is @withoutDepName and b.departmentId isnt @withoutDepName
	#				1
	#			else if b.departmentId is @withoutDepName and a.departmentId isnt @withoutDepName
	#				-1
	#			else
	#				if a.department > b.department
	#					1
	#				else if b.department > a.department
	#					-1
	#				else
	#					if a.number and not b.number
	#						-1
	#					else if not a.number and b.number
	#						1
	#					else
	#						if a.state and not b.state
	#							-1
	#						else if not a.state and b.state
	#							1
	#						else
	#							if a.name > b.name
	#								1
	#							else if a.name < b.name
	#								-1
	
		setFilter: (filter, reloadAnyway) ->
			if @filter is filter and not reloadAnyway then return false
			oldFilter = @filter
			@filter = filter
			exactMatch = false
			@timer()
			@panelUsersFiltered = []
	
			allDeps = []
			renderDep = (dep) =>
				el = dep.getEl filter isnt ''
				depExactMatch = false
				[ users, depExactMatch ] = dep.getUsers filter, @showOffline
				@panelUsersFiltered = @panelUsersFiltered.concat users
				if users.length isnt 0
					if not exactMatch then exactMatch = depExactMatch
					@_setUsersHtml users, dep.getContainer()
					if depExactMatch and exactMatch is depExactMatch
						allDeps.unshift el
					else
						allDeps.push el
			if @showDeps
				for dep in @departments
					renderDep dep
	#			if allDeps.length > 0
	#				allDeps[allDeps.length-1].
			else
				renderDep @allUserDep
	
	#		allDeps.find('tr').bind 'mouseenter', (e)=>
	#			@log 'Mouse enter tr ', e.currentTarget
	#			$(e.currentTarget).data('user')?.isHovered true
	#		allDeps.find('tr').bind 'mouseleave', (e)=>
	#			@log 'Mouse leave tr ', e.currentTarget
	#			$(e.currentTarget).data('user')?.isHovered true
	
			if not exactMatch and filter.match /[0-9\(\)\+\-]/
				@filterFantomUser = @getUser({name:filter, number: filter}, true)
				@exactMatchUserDep.clearUsers()
				@exactMatchUserDep.addUser @filterFantomUser
				el = @exactMatchUserDep.getEl()
				@_setUsersHtml [@filterFantomUser], @exactMatchUserDep.getContainer()
				@filterFantomUser.showLetter false
				allDeps.unshift el
			else
				@filterFantomUser = false
	
			@usersListBlockEl.children().detach()
			@usersListBlockEl.html allDeps
			if allDeps.length > 0
				allDeps[allDeps.length-1].find('tr:last').addClass 'g_last'
	
			@userScrollerToTop()
	
			@timer true
	
	
	#		else
	#
	#			@usersListBlockEl.html @simpleListEl
	#
	#			if filter is ''
	#				@panelUsersFiltered = [].concat @panelUsers
	#				@afterSetFilter(@panelUsersFiltered)
	#				return @panelUsersFiltered
	#			filteredUsers = []
	#			exactMatch = false
	#
	#			for u in @panelUsers
	#				if u.isFiltered filter
	#					filteredUsers.push u
	#					if u.number is filter and not exactMatch
	#						exactMatch = u
	#			if not exactMatch and filter.match /[0-9\(\)\+\-]/
	#				@filterFantomUser = @getUser({name:filter, number: filter}, true)
	#				@panelUsersFiltered = [@filterFantomUser].concat(filteredUsers)
	#			else
	#				@panelUsersFiltered = filteredUsers
	#			@afterSetFilter(@panelUsersFiltered)
	#
	#			@timer true
	#
	#			@panelUsersFiltered
	
		afterSetFilter: (filteredUsersArray) ->
			@setPanelUsersHtml filteredUsersArray
	
		getUser: (data, dontRemember) ->
			if typeof data is 'string' or typeof data is 'number'
				strNumber = data.toString()
				data = {number:strNumber}
			else
				strNumber = data.number.toString()
	
			numberFormatted = data.phoneFormatted or oktell.formatPhone?(strNumber) or strNumber
			data.numberFormatted = numberFormatted unless data.numberFormatted
	
			if not dontRemember and @filterFantomUser?.number is strNumber
				@usersByNumber[strNumber] = @filterFantomUser
				data.isFantom = true
				@filterFantomUser = false
	
			if @usersByNumber[strNumber]
				@usersByNumber[strNumber].init(data) if @usersByNumber[strNumber].isFantom
				return @usersByNumber[strNumber]
	
			fantom = new CUser
				number: strNumber
				numberFormatted: numberFormatted
				name: data.name
				isFantom: true
				state: ( if data?.state? then data.state else 1 )
	
			if not dontRemember
				@usersByNumber[strNumber] = fantom
			fantom
	
		reloadActions: ->
			setTimeout =>
				for own phone, user of @userWithGeneratedButtons
					actions = user.loadActions()
					#log 'reload actions for ' + user.getInfo() + ' ' + actions
				user.loadActions() for phone, user of @abonents
				user.loadActions() for phone, user of @queue
				user.loadActions() for phone, user of @panelUsersFiltered
			, 100
	
		timer: (stop) ->
			if stop and @_time
				@log 'List timer stop: ' + ( Date.now() - @_time )
			if not stop
				@_time = Date.now()
				log 'List timer start'
	
		beforeUserAction: (user, action)->
			if @filterFantomUser and user is @filterFantomUser
				@clearFilter()
	
		config: (data)->
			if not @_config
				if localStorage?.oktellPanel and JSON?.parse
					try
						@_config = JSON.parse(localStorage.oktellPanel)
					catch e
					@_config = {} if not @_config? or typeof @_config isnt 'object'
				else
					@_config = {}
				for own k,v of @defaultConfig
					if not @_config[k]?
						@_config[k] = v
	
			if data?
				for own k,v of data
					@_config[k] = v
				if localStorage and JSON?.stringify
					localStorage.setItem 'oktellPanel', JSON.stringify @_config
	
			@showDeps = @_config.showDeps
			@showOffline = @_config.showOffline
			@buttonShowOffline.toggleClass 'g_active', not @showOffline
			@buttonShowOffline.attr 'title', if @showOffline then @langs.panel.showOnlineOnly else @langs.panel.showOnlineOnlyCLicked
			@buttonShowDeps.toggleClass 'g_active', @showDeps
			@buttonShowDeps.attr 'title', if @showDeps then @langs.panel.showDepartmentsClicked else @langs.panel.showDepartments
			@_config
	
	
	#includecoffee coffee/class/Popup.coffee
	class Popup
		logGroup: 'Popup'
		constructor: (popupEl, oktell)->
			@el = popupEl
			@absContainer = @el.find('.b_content')
			@abonentEl = @absContainer.find('.b_abonent').remove()
	
			@isBack101 = false
	
	
			@el.find('.j_abort_action').bind 'click', =>
				@hide()
				oktell.endCall()
	
			@el.find('.j_close_action').bind 'click', =>
				@hide()
	
			@el.find('i.o_close').bind 'click', =>
				@hide()
	
			oktell.on 'ringStart', (abonents) =>
				if not @isBack101
					@setAbonents abonents
				@show()
	
			oktell.on 'ringStop', =>
				@isBack101 = false
				@hide()
	
	#		oktell.on 'connect', =>
	#			oktell.onNativeEvent 'phoneevent_ringstarted', (data) =>
	##				callercomment: ""
	##				callerdescription: ""
	##				callerdirection: "oktell_pbx"
	##				callerid: ""
	##				callerinfo: "Автодозвон. Обратный вызов.↵Абонент: 89274513158"
	##				callerlineid: "00000000-0000-0000-0000-000000000000"
	##				callerlinenum: "00000"
	##				callername: ""
	##				canfax: false
	##				canvideo: false
	##				chainid: "c6ed99c1-c53a-4224-b4e5-cd58682c8b87"
	##				connectionindex: 4
	##				isconference: false
	##				isextline: false
	##				istask: false
	##				qid: "e2382a55-53c1-45bc-be80-13910f31082e"
	##				userid: "d8af50ea-74a6-4a57-b0d5-451962f6c042"
	##				userlogin: "airato"
	#				if data?.callerdirection is 'oktell_pbx' and data?.callerlineid is '00000000-0000-0000-0000-000000000000' and data?.callerlinenum is '00000' and data?.callerinfo
	#					@isBack101 = data.callerinfo
	#					@setAbonents [{name:@isBack101, phone: ''}]
	
	
		show: ->
			@el.fadeIn 200
	
		hide: ->
			@el.fadeOut 200
			@isBack101 = false
	
		setAbonents: (abonents) ->
			@absContainer.empty()
			$.each abonents, (i,abonent) =>
				phone = abonent.phone.toString()
				name = abonent.name.toString() or phone
				phone = '' unless name isnt phone
				el = @abonentEl.clone()
				el.find('span:first').text(name)
				el.find('span:last').text(phone)
				@absContainer.append el
	#includecoffee coffee/class/Error.coffee

	class Error
		logGroup: 'Error'
		errorTypes:
			1: 'usingOktellClient'
			2: 'loginPass'
			3: 'unavailable'
		constructor: (errorEl, oktell)->
			@el = errorEl
	
			oktell.on 'connecting', =>
				@hide()
	
			oktell.on 'disconnect', (reason)=>
				@log 'disconnect with reason ' + reason.code + ' ' + reason.message
				if reason.code is 12
					@show 3, oktell.getMyInfo().login
	
			oktell.on 'connectError', (error)=>
				@log 'connect error ' + error.errorCode + ' ' + error.errorMessage
				switch error.errorCode
					when 12 then @show 1, oktell.getMyInfo().login
					when 13 then @show 2, oktell.getMyInfo().login
	
		show: (errorType, username) ->
			if not @errorTypes[errorType] then return false
			@log 'show ' + errorType
			type = @errorTypes[errorType]
			@el.find('p:eq(0)').text @langs[type].header.replace('%username%', username )
			@el.find('p:eq(1)').text @langs[type].message?.replace('%username%', username ) or ''
			@el.find('p:eq(3)').text @langs[type].message2?.replace('%username%', username ) or ''
			@el.fadeIn 200
	
		hide: ->
			@el.fadeOut 200
	
	
	defaultOptions =
		position: 'right'
		dynamic: false
		#animateTimout: 200
		oktell: window.oktell
		#buttonCss: 'oktellActionButton'
		debug: false
		lang: 'ru'
		noavatar: true

	langs = {
		ru:
			panel: { inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер', withoutDepartment: 'без отдела', showDepartments: 'Группировать по отделам', showDepartmentsClicked: 'Показать общим списком', showOnlineOnly: 'Показать только online', showOnlineOnlyCLicked: 'Показать всех' },
			actions: { call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь' }
			callPopup: { title: 'Входящий вызов', hide: 'Скрыть', answer: 'Ответить', reject: 'Отклонить', undefinedNumber: 'Номер не определен', goPickup: 'Поднимите трубку' }
			error:
				usingOktellClient: { header: 'Пользователь «%username%» использует стандартный Oktell-клиент.', message: 'Одновременная работа двух типов клиентских приложений невозможна.', message2: 'Закройте стандартный Oktell-клиент и повторите попытку.' }
				loginPass: { header: 'Пароль для пользователя «%username%» не подходит.', message: 'Проверьте правильность имени пользователя и пароля.' }
				unavailable: { header: 'Сервер телефонии Oktell не доступен.', message: 'Убедитесь что сервер телефонии работает и проверьте настройки соединения.'}
				#tryAgain: 'Повторить попытку'
		en:
			panel: { inTalk: 'In conversation', onHold: 'On hold', queue: 'Wait queue', inputPlaceholder: 'Enter name or number', withoutDepartment: 'wihtout department', showDepartments: 'Show departments', showDepartmentsClicked: 'Hide departments', showOnlineOnly: 'Show online only', showOnlineOnlyCLicked: 'Show all' },
			actions: { call: 'Dial', conference: 'Conference', transfer: 'Transfer', toggle: 'Switch', intercom: 'Intercom', endCall: 'End', ghostListen: 'Audition', ghostHelp: 'Help' }
			callPopup: { title: 'Incoming call', hide: 'Hide', answer: 'Answer', reject: 'Decline', undefinedNumber: 'Phone number is not defined', goPickup: 'Pick up the phone' }
			error:
				usingOktellClient: { header: 'User «%username%» uses standard Oktell client applications.', message: 'Simultaneous work of two types of client applications is not possible..', message2: 'Close standard Oktell client application and try again.' }
				loginPass: { header: 'Wrong password for user «%username%».', message: 'Make sure that the username and password are correct.' }
				unavailable: { header: 'Oktell server is not available.', message: 'Make sure that Oktell server is running and check your connections.'}
				#tryAgain: 'Try again'
		cz:
			panel: { inTalk: 'V rozhovoru', onHold: 'Na hold', queue: 'Fronta čekaní', inputPlaceholder: 'zadejte jméno nebo číslo', withoutDepartment: '!!!!!!!', showDepartments: 'Show departments', showDepartmentsClicked: 'Hide departments', showOnlineOnly: 'Show online only', showOnlineOnlyCLicked: 'Show all' },
			actions: { call: 'Zavolat', conference: 'Konference', transfer: 'Převést', toggle: 'Přepnout', intercom: 'Intercom', endCall: 'Ukončit', ghostListen: 'Odposlech', ghostHelp: 'Nápověda' }
			callPopup: { title: 'Příchozí hovor', hide: 'Schovat', answer: 'Odpovědět', reject: 'Odmítnout', undefinedNumber: '', goPickup: 'Zvedněte sluchátko' }
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
	error = null

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

	templates = {'templates/actionButton.html':'<ul class="oktell_button_action"><li class="g_first"><i></i></li><li class="g_last drop_down"><i></i></li></ul>', 'templates/actionList.html':'<ul class="oktell_actions_group_list"><li class="{{css}}" data-action="{{action}}"><i></i><span>{{actionText}}</span></li></ul>', 'templates/user.html':'<tr class="b_contact"><td class="b_contact_avatar {{css}}"><img src="{{avatarLink32x32}}"><i></i><div class="o_busy"></div></td><td class="b_capital_letter"><span></span></td><td class="b_contact_title"><div class="wrapword"><a><b>{{name}}</b><span class="o_number">{{number}}</span></a></div>{{button}}</td></tr>', 'templates/department.html':'<tr class="b_contact"><td class="b_contact_department" colspan="3">{{department}}</td></tr>', 'templates/dep.html':'<div class="b_department"><div class="b_department_header"><span>{{department}}</span></div><table class="b_main_list"><tbody></tbody></table></div>', 'templates/usersTable.html':'<table class="b_main_list m_without_department"><tbody></tbody></table>', 'templates/panel.html':'<div class="oktell_panel"><div class="i_panel_bookmark"><div class="i_panel_bookmark_bg"></div></div><div class="h_panel_bg"><div class="b_header"><ul class="b_list_filter"><li class="i_group"></li><li class="i_online"></li></ul></div><div class="h_padding"><div class="b_marks i_conference j_abonents"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{inTalk}}</span><span class="b_marks_time"></span></p><table><tbody></tbody></table></div></div><div class="b_marks i_flash j_hold"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{onHold}}</span></p><table class="j_table_favorite"><tbody></tbody></table></div></div><div class="b_marks i_flash j_queue"><div class="b_marks_noise"><p class="b_marks_header"><span class="b_marks_label">{{queue}}</span></p><table class="j_table_queue"><tbody></tbody></table></div></div><div class="b_inconversation j_phone_block"><table class="j_table_phone"><tbody></tbody></table></div><div class="b_marks i_phone"><div class="h_shadow_bottom"><div class="h_phone_number_input"><div class="i_phone_state_bg"></div><div class="h_input_padding"><div class="i_phone_popup_button j_keypad_expand"><i></i></div><div class="jInputClear_hover"><input class="b_phone_number_input" type="text" placeholder="{{inputPlaceholder}}"><span class="jInputClear_close">&times;</span></div></div><div class="b_phone_keypad j_phone_keypad"><div class="l_column_group"><div class="h_phone_keypad"><ul class="b_phone_panel"><li class="g_top_left g_first"><button data-num="1" class="g_button m_big">1</button></li><li><button data-num="2" class="g_button m_big">2</button></li><li class="g_top_right g_right"><button data-num="3" class="g_button m_big">3</button></li><li class="g_float_celar g_first"><button data-num="4" class="g_button m_big">4</button></li><li><button data-num="5" class="g_button m_big">5</button></li><li class="g_right"><button data-num="6" class="g_button m_big">6</button></li><li class="g_float_celar g_first"><button data-num="7" class="g_button m_big">7</button></li><li><button data-num="8" class="g_button m_big">8</button></li><li class="g_right"><button data-num="9" class="g_button m_big">9</button></li><li class="g_bottom_left g_float_celar g_first"><button data-num="*" class="g_button m_big">&lowast;</button></li><li class="g_bottom_center"><button data-num="0" class="g_button m_big">0</button></li><li class="g_bottom_right g_right"><button data-num="#" class="g_button m_big">#</button></li></ul></div></div></div></div></div></div><div class="h_main_list j_main_list"></div></div></div></div>', 'templates/callPopup.html':'<div class="oktell_panel_popup" style="display: none"><div class="m_popup_staff"><div class="m_popup_data"><header><div class="h_header_bg"><i class="o_close"></i><h2>{{title}}</h2></div></header><div class="b_content"><div class="b_abonent"><span data-bind="text: name"></span>&nbsp;<span class="g_light" data-bind="textPhone: number"></span></div></div><div class="footer"><div class="b_take_phone"><i></i>&nbsp;<span>{{goPickup}}</span></div><button class="oktell_panel_btn m_big j_close_action">{{hide}}</button><button class="oktell_panel_btn m_big m_button_red j_abort_action"><i></i>{{reject}}</button></div></div></div></div>', 'templates/error.html':'<div class="b_error m_form" style="display: none"><div class="h_padding"><h4>Ошибка</h4><p class="b_error_alert"></p><p class="g_light"></p><p class="g_light"></p></div></div>', }

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
	errorHtml = loadTemplate '/templates/error.html'

	List.prototype.jScroll = jScroll
	List.prototype.usersTableTemplate = usersTableHtml

	CUser.prototype.buttonTemplate = actionButtonHtml
	CUser.prototype.log = log
	List.prototype.log = log
	Popup.prototype.log = log
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

		popupHtml = popupHtml.replace('{{title}}', langs.callPopup.title)
			.replace('{{goPickup}}', langs.callPopup.goPickup)
			.replace('{{hide}}', langs.callPopup.hide)
			.replace('{{reject}}', langs.callPopup.reject)

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
			popupEl = $(popupHtml)
			$('body').append(popupEl)
			popup = new Popup popupEl, oktell

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
