class UsersService

	log: ->
		console.log.apply console, arguments

	# find user or create fantom
	getUser: (data, dontRemember) ->
		if typeof data is 'string' or typeof data is 'number'
			strNumber = data.toString()
		else
			strNumber = data.number.toString()

		if @allUsersByNumber[strNumber]
			return @allUsersByNumber[strNumber]

		fantom = new User @oktell, @actionList,
			number: strNumber
			name: data.name
			isFantom: true
			state: ( if data?.state? then data.state else 5 )
			avatarLink32x32: @defaultAvatar32

		if not dontRemember
			@allUsersByNumber[strNumber] = fantom
			@fantomsByNumber[strNumber] = fantom
		fantom



	constructor: (oktell, actionList, afterOktellConnect, debugMode) ->
		oktellConnected = false

		@actionList = actionList
		@oktell = oktell

		@me = false
		@users = ko.observableArray([])
		@fantomsByNumber = {}
		@allUsersByNumber = {}
		@usersForPanel = ko.observableArray([])
		@panelUserCount = ko.observable(999)
		@queueAbonents = ko.observableArray([])
		@userByNumber = {}
		@abonents = ko.observableArray []
		@abonentsCount = ko.computed => @abonents().length
		@holdedAbonents = ko.observableArray []
		@holdedAbonentsCount = ko.computed => @holdedAbonents().length
		@filter = ko.observable('')




		@myNumber = ''

		usersSorted = ko.computed =>
			_.sortBy @users(), (u) =>
				if u.state()
					'_________' + u.name
				else if not ( u and u.number )
					'zzzzzzzz'
				else
					u.name

		ko.computed =>
			filter = @filter().toLocaleLowerCase()
			abonents = @abonents()
			holdedAbonents = @holdedAbonents()
			panelUserCount = @panelUserCount()
			users = usersSorted()
			finded = []

			if filter

				totalMatch = @allUsersByNumber[filter]
				if totalMatch and filter isnt @myNumber
					finded.push totalMatch

				#					if finded.length is 0
				#						ab = _.find( abonents, (a) => a?.number? and a.number is filter )
				#						if ab
				#							finded.push ab
				#
				#					if finded.length is 0
				#						h = _.find( holdedAbonents, (h) => h?.number? and h.number is filter )
				#						if h
				#							finded.push h

				if finded.length is 0
					cu = _.find( @allUsersByNumber, (u) => u?.number? and u.number is filter )
					if cu
						finded.push cu

				if finded.length is 0 and filter isnt @myNumber
					finded.push @getUser filter, true

				finded = finded.concat _.first( _.filter( users, (u) => u and u isnt totalMatch and u.isFiltered(filter) ), panelUserCount )

			else
				finded = _.first( users, panelUserCount )

			@usersForPanel finded

		setAbonents = (abonents) =>
			_.each abonents, (ab) =>
				if not _.find( @abonents(), (u) => u?.number? and u.number is ab.phone.toString() )
					user = @getUser(ab.phone)
					if user.isFantom
						user.state 5
					@abonents.push user
			@abonents.remove (u) =>
				user = _.find abonents, (ab) => u?.number? and u.number is ab.phone.toString()
				if user
					if user.isFantom
						user.state 1
					false
				else true

		setHold = (holdInfo) =>
			oldUser = @holdedAbonents()?[0]
			if not holdInfo.hasHold
				@holdedAbonents []
			else if holdInfo.isConference
				if @holdedAbonents()[0].conferenceId isnt holdInfo.conferenceId
					newUser = @getUser( _.extend( holdInfo, { name: holdInfo.conferenceName or 'Конференция' } ) , true )
					if newUser isnt oldUser and oldUser.isFantom
						oldUser.state 1
					@holdedAbonents [  ]
			else
				if @holdedAbonents()[0]?.number? and @holdedAbonents()[0].number.toString() isnt holdInfo.phone.toString()
					@holdedAbonents [ @getUser(holdInfo.phone) ]

		@sa = setAbonents

		oktell.on 'disconnect', =>
			oktellConnected = false

		oktell.on 'connect', =>

			oktellConnected = true

			users = []

			oktell.on 'stateChange', ( newState, oldState ) =>
				#log 'Oktell stateChange', newState, oldState
				_.each @users, (u) =>
					u.needLoadActions true
					if u.hovered()
						u.loadActions()


			oktell.onNativeEvent 'pbxnumberstatechanged', (data) =>
				#log 'pbxnumberstatechanged', data
				nums = []
				_.each data.numbers, (n) =>
					if @allUsersByNumber[n.num.toString()]
						#@log 'change number state' , n.num.toString(), parseInt( n.numstateid ), @allUsersByNumber[n.num.toString()]
						@allUsersByNumber[n.num.toString()].state( parseInt( n.numstateid ) )

			oktell.on 'abonentsChange', ( abonents ) =>
				#log 'Oktell abonentsChange', abonents
				setAbonents abonents

			oktell.on 'holdStateChange', ( holdInfo ) =>
				#log 'Oktell holdStateChange', holdInfo
				setHold holdInfo

			oktellInfo = oktell.getMyInfo()

			@defaultAvatar = oktellInfo.defaultAvatar
			@defaultAvatar32 = oktellInfo.defaultAvatar32x32
			@defaultAvatar64 = oktellInfo.defaultAvatar64x64

			myId = oktellInfo.userid

			@myNumber = oktellInfo.number?.toString()

			_.each oktell.getUsers(), (u) =>
				user = new User( @oktell, @actionList, u )

				if u.number
					strNumber = u.number.toString()

				if not user.avatarLink32x32
					user.avatarLink32x32 = @defaultAvatar32
				if strNumber
					@userByNumber[strNumber] = user

				if u.id.toLowerCase() isnt myId.toLowerCase()
					users.push user
				else
					@me = user

				if strNumber
					@allUsersByNumber[strNumber] = user

			setAbonents oktell.getAbonents()
			setHold oktell.getHoldInfo()

			@users users

			if typeof afterOktellConnect is 'function' then afterOktellConnect()