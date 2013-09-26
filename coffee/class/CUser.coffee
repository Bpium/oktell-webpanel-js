class CUser
	logGroup: 'User'
	constructor: (data) ->
		@state = false
		@hasHover = false
		@buttonLastAction = ''
		@firstLiCssPrefix = 'm_button_action_'
		@noneActionCss = '' #@firstLiCssPrefix + 'none'

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
		if @numberHtml is @nameHtml
			@numberHtml = ''

		@isIvr = data.isIvr
		@ivrName = data.ivrName

		ns = @nameHtml.split(/\s+/)
		if ns.length > 1 and data.name.toString() isnt @number
			@nameHtml1 = ns[0]
			@nameHtml2 = ' ' + ns.splice(1).join('')
		else
			@nameHtml1 = @nameHtml
			@nameHtml2 = ''

		lastHtml = @elNumberHtml
		@elNumberHtml = if @numberHtml isnt @nameHtml then @numberHtml else ''
		if @elNumberHtml isnt lastHtml and @el?
			@el.find('.o_number').text @elNumberHtml
		@el?.find('.b_contact_title wrapword a').text @nameHtml

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
		name1: /\{\{name1\}\}/
		name2: /\{\{name2\}\}/
		number: /\{\{number\}\}/
		dtmf: /\{\{dtmf\}\}/
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
			#@log 'LOAD actions after state change '
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

	isFiltered: (filter, showOffline, lang) ->
		if ( not filter or typeof filter isnt 'string' ) and ( showOffline or ( not showOffline and @state isnt 0 ) )
			@setSelection()
			return true

		if ( showOffline or ( not showOffline and @state isnt 0 ) )
			if ( @number and @number.indexOf(filter) isnt -1 ) or ( ' ' + @name ).toLowerCase().indexOf(filter) isnt -1
				@setSelection filter
				return true
			if lang is 'en' and (fl = @toRu(filter)) and ( ' ' + @name ).toLowerCase().indexOf(fl) isnt -1
				@setSelection fl
				return true
			if lang is 'ru' and (fl = @toEn(filter)) and ( ' ' + @name ).toLowerCase().indexOf(fl) isnt -1
				@setSelection fl
				return true

			return false

		return false

	showLetter: (show)->
		@el?.find('.b_capital_letter span').text if show then @letter else ''

	getEl: ( createIndependent) ->
		if not @el or createIndependent
			str = @template.replace( @regexps.name1, @nameHtml1)
				.replace( @regexps.name2, @nameHtml2 )
				.replace( @regexps.number, @numberHtml )
				.replace( @regexps.dtmf, @langs.panel.dtmf )
				.replace( @regexps.avatarLink32x32, @avatarLink32x32)
				.replace( @regexps.css, @defaultAvatarCss )
			$el = $(str)
			$el.data 'user', @
			@initButtonEl $el.find '.oktell_button_action'
			@els = @els.add $el
			@setStateCss()
			if not @el
				@el = $el
				@elName = @el.find('.b_contact_name b')
				@elName2 = @el.find('.b_contact_name span')
				@elNumber = @el.find('.o_number')
				@elDtmf = @el.find('.o_dtmf')
		$el = $el or @el
		return $el

	setSelection: (str)->
		if @el?
			if not str
				if @elHasSelection
					@elName.text @nameHtml1
					@elName2.text @nameHtml2
					@elNumber.text @numberHtml
					@elHasSelection = false
			else
				rx = new RegExp('('+str+')', 'gi')
				@elName.html @nameHtml1.replace( rx, '<span class="selected_text">$1</span>')
				@elName2.html @nameHtml2.replace( rx, '<span class="selected_text">$1</span>')
				@elNumber.html @numberHtml.replace( rx, '<span class="selected_text">$1</span>')
				@elHasSelection = true

	initButtonEl: ($el) ->
		#@log 'init button el for ' + @getInfo()
		@buttonEls = @buttonEls.add $el
		$el.data 'user', @
		$el.children(':first').bind 'click', =>
			#@log 'log do action'
			@doAction @buttonLastAction
		if @buttonLastAction
			$el.removeClass(@noneActionCss).addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
		else
			$el.addClass @noneActionCss

	getButtonEl: () ->
		$el = $(@buttonTemplate)
		@initButtonEl $el
#		@separateButtonEls = @separateButtonEls.add $el
		return $el

	isHovered: (isHovered) ->
		if @hasHover is isHovered then return
		@hasHover = isHovered
		if @hasHover
			@loadActions(true)

	loadOktellActions: ->
		if @isIvr
			actions = ['endCall']
		else
			actions = @oktell.getPhoneActions @id or @number
		#@log 'actions for ' + @getInfo(), actions
		actions

	loadActions: ()->
		actions = @loadOktellActions()
		#@log 'load action for user id='+@id+' number='+@number+' actions='+actions
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
			@buttonEls.removeClass(@noneActionCss).addClass @firstLiCssPrefix + @buttonLastAction.toLowerCase()
#			if needShowSeparateButtons
#				@separateButtonEls.show()
		else
			@buttonLastAction = ''
			@buttonEls.addClass @noneActionCss
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
			when 'hold'
				@oktell.hold?()
			when 'resume'
				@oktell.resume?()
			when 'answer'
				@oktell.answer?()


	doLastFirstAction: ->
		if @buttonLastAction
			#@log 'second do action'
			@doAction @buttonLastAction
			true
		else false

	letterVisibility: (show)->
		if @el and @el.length
			if show
				@el.find('.b_capital_letter span').text @letter
			else
				@el.find('.b_capital_letter span').text ''

	replacerToRu: {"q":"й", "w":"ц", "e":"у", "r":"к", "t":"е", "y":"н", "u":"г", "i":"ш", "o":"щ", "p":"з", "[":"х", "]":"ъ", "a":"ф", "s":"ы", "d":"в", "f":"а", "g":"п", "h":"р", "j":"о", "k":"л", "l":"д", ";":"ж", "'":"э", "z":"я", "x":"ч", "c":"с", "v":"м", "b":"и", "n":"т", "m":"ь", ",":"б", ".":"ю", "/":"."}
	replacerToEn: {"й":"q", "ц":"w", "у":"e", "к":"r", "е":"t", "н":"y", "г":"u", "ш":"i", "щ":"o", "з":"p", "х":"[", "ъ":"]", "ф":"a", "ы":"s", "в":"d", "а":"f", "п":"g", "р":"h", "о":"j", "л":"k", "д":"l", "ж":";", "э":"'", "я":"z", "ч":"x", "с":"c", "м":"v", "и":"b", "т":"n", "ь":"m", "б":",", "ю":".", ".":"/"}

	toRu: (str)->
		str.replace /[A-z\/,.;\'\]\[]/g, (x)=>
			if x is x.toLowerCase() then @replacerToRu[x] else @replacerToRu[x.toLowerCase()].toUpperCase()

	toEn: (str)->
		str.replace /[А-яёЁ]/g, (x)=>
			if x is x.toLowerCase() then @replacerToEn[x] else @replacerToEn[x.toLowerCase()].toUpperCase()


