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

		@usersShowRules()

		@departments = []

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



		@usersWithBeforeConnectButtons = []



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
			user.loadActions() for phone,user of @userWithGeneratedButtons


		oktell.on 'connect', =>
			@oktellConnected = true
			oInfo = oktell.getMyInfo()
			oInfo.userid = oInfo.userid.toString().toLowerCase()
			@myNumber = oInfo.number?.toString()
			CUser.prototype.defaultAvatar = oInfo.defaultAvatar
			CUser.prototype.defaultAvatar32 = oInfo.defaultAvatar32x32
			CUser.prototype.defaultAvatar64 = oInfo.defaultAvatar64x64

			@departments = []
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
						dep.addUser user
					else
						otherDep.addUser user
				else
					@me = user

			@departments.sort (a,b)=>
				if a.name > b.name
					1
				else if b.name > a.name
					-1
				else 0

			@departments.push otherDep

			@sortPanelUsers @panelUsers

			oktell.on 'stateChange', ( newState, oldState ) =>
				@reloadActions()

			oktell.onNativeEvent 'pbxnumberstatechanged', (data) =>
				for n in data.numbers
					numStr = n.num.toString()
					@usersByNumber[numStr]?.setState n.numstateid

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

	usersShowRules: ( showOffline, showDeps ) ->
		showOfflineKey = 'oktell-panel-show-offline-users'
		showDepsKey = 'oktell-panel-show-departments'

		@showOffline = if showOffline? then showOffline else ( if cookie(showOfflineKey)? then cookie(showOfflineKey) else true )
		@showDeps = if showDeps? then showDeps else ( if cookie(showDepsKey)? then cookie(showDepsKey) else true )

		cookie showOfflineKey, @showOffline, {path:'/', expires: 1209600 }
		cookie showDepsKey, @showDeps, {path:'/', expires: 1209600 }

		return [@showOffline, @showDeps]

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
		@_setUsersHtml usersArray, @usersListEl, @showOffline, @showDeps
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


	_setUsersHtml: (usersArray, $el, showOffline ) ->
		html = []
		lastDepId = null
		for u in usersArray
			#log 'render ' + u.getInfo()
			uEl = null
			if showOffline or ( not showOffline and u.state isnt 0 )
				uEl = u.getEl()
				html.push uEl
		$el.html html

	sortPanelUsers: ( usersArray ) ->
		usersArray.sort (a,b) =>
			if a.departmentId is @withoutDepName and b.departmentId isnt @withoutDepName
				1
			else if b.departmentId is @withoutDepName and a.departmentId isnt @withoutDepName
				-1
			else
				if a.department > b.department
					1
				else if b.department > a.department
					-1
				else
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
		exactMatch = false
		@timer()

		if @showDeps
			allDeps = $()
			for dep in @departments
				el = dep.getEl()
				depExactMatch = false
				[ users, depExactMatch ] = dep.getUsers filter
				if users.length isnt 0
					if not exactMatch then exactMatch = depExactMatch
					@_setUsersHtml users, el.find('tbody'), @showOffline
					allDeps = allDeps.add el


			@usersListBlockEl.html allDeps

			if not exactMatch and filter.match /[0-9\(\)\+\-]/
				@filterFantomUser = @getUser({name:filter, number: filter}, true)
				@usersListEl.prepend

			@userScrollerToTop()

			@timer true


		else

			@usersListBlockEl.html @simpleListEl

			if filter is ''
				@panelUsersFiltered = [].concat @panelUsers
				@afterSetFilter(@panelUsersFiltered)
				return @panelUsersFiltered
			filteredUsers = []
			exactMatch = false

			for u in @panelUsers
				if u.isFiltered filter
					filteredUsers.push u
					if u.number is filter and not exactMatch
						exactMatch = u
			if not exactMatch and filter.match /[0-9\(\)\+\-]/
				@filterFantomUser = @getUser({name:filter, number: filter}, true)
				@panelUsersFiltered = [@filterFantomUser].concat(filteredUsers)
			else
				@panelUsersFiltered = filteredUsers
			@afterSetFilter(@panelUsersFiltered)

			@timer true

			@panelUsersFiltered

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
			log 'List timer stop: ' + ( Date.now() - @_time )
		if not stop
			@_time = Date.now()
			log 'List timer start'
