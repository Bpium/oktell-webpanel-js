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
		else
			@nameHtml = '<b>' + @nameHtml + '</b>'

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