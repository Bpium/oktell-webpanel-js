class CUser

	constructor: (data) ->

		@id = data.id?.toString().toLowerCase()
		@number = data.number?.toString() or ''
		@numberHtml = escapeHtml data.number
		@name = data.name
		@nameHtml = if data.name then escapeHtml(data.name) else @numberHtml
		@state = false
		@avatarLink32x32 = data.avatarLink32x32 or @defaultAvatar32
		@hasHover = false
		@buttonLastAction = ''
		@firstLiCssPrefix = 'm_button_action_'

		@els = $()
		@buttonEls = $()


		@regexps =
			name: /\{\{name\}\}/
			number: /\{\{number\}\}/
			avatarLink32x32: /\{\{avatarLink32x32\}\}/

		if data.numberObj?.state?
			@setState data.numberObj.state
		else if data.state?
			@setState data.state
		else
			@setState 1

	setState: (state) ->
		state = parseInt state
		if state is @state
			return
		@state = state
		if @buttonEls.length
			log 'LOAD actions after state change '
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
		el = $(@template.replace( @regexps.name, @nameHtml).replace( @regexps.number, @numberHtml).replace( @regexps.avatarLink32x32, @avatarLink32x32))
		@els = @els.add el
		el.data 'user', @
		buttonEl = el.find '.b_button_action'
		@buttonEls = @buttonEls.add buttonEl
		buttonEl.data 'user', @
		buttonEl.children(':first').bind 'click', =>
			@doAction @buttonLastAction
		if @buttonLastAction then buttonEl.addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
		el



	isHovered: (isHovered) ->
		if @hasHover is isHovered then return
		@hasHover = isHovered
		if @hasHover
			@loadActions()

	loadOktellActions: ->
		@oktell.getPhoneActions @id or @number

	loadActions: ->
		actions = @loadOktellActions()
		log 'load action for user id='+@id+' number='+@number+' actions='+actions
		window.cuser = @
		action = actions?[0] or ''
		if @buttonLastAction is action
			return

		if @buttonLastAction
			@buttonEls.removeClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()

		if action
			@buttonLastAction = action
			@buttonEls.addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
		else
			@buttonLastAction = ''



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

