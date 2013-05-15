class List
	logGroup: 'List'
	constructor: (oktell, panelEl, dropdownEl, afterOktellConnect, debugMode) ->

		@defaultConfig =
			departmentVisibility: {}
			showDeps: true
			showOffline: false

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
				#@log 'Oktell holdStateChange', holdInfo
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
		#@log '!!! getUserButtonForPlugin for ' + user.getInfo()
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
			@log u.getInfo()

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
				#@log 'reload actions for ' + user.getInfo() + ' ' + actions
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
		@buttonShowDeps.toggleClass 'g_active', @showDeps
		@_config

