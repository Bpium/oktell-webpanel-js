class Popup
	logGroup: 'Popup'
	constructor: (popupEl, oktell, ringtone)->
		@el = popupEl
		@_lastPopupShowTime = 0
		@ringtone = ringtone
		@absContainer = @el.find('.b_content')
		@abonentEl = @absContainer.find('.b_abonent').remove()

		@answerActive = false
		@answerButttonEl = @el.find '.j_answer'
		@puckupEl = @el.find '.j_pickup'


		@el.find('.j_abort_action').bind 'click', =>
			@hide()
			@playRingtone false
			oktell.endCall();
		@el.find('.j_answer').bind 'click', =>
			@hide()
			@playRingtone false
			oktell.answer();

		@el.find('.j_close_action').bind 'click', =>
			@hide()

		@el.find('i.o_close').bind 'click', =>
			@hide()


		abonentsSet = false

		oktell.on 'connect', =>
			@users = oktell.getUsers()

		oktell.on 'webrtcRingStart', (name, identity) =>
			@log 'webrtcRingStart, ' + identity
			@playRingtone true
			@answerButtonVisible true
			if not abonentsSet
				@setAbonents [{name:name, phone: identity?.match?(/<sip:([\s\S]+?)@/)?[1] or ''}]
			@show()


		oktell.on 'ringStart backRingStart', (abonents) =>
			@log 'ringStart', abonents
			@setAbonents abonents
			setTimeout =>
				if abonents?[0]?.phone and oktell.getPhoneActions(abonents[0].phone)?.indexOf?('answer') != -1
					@answerButtonVisible true
			, 10
			abonentsSet = true
			@show()

		oktell.on 'ringStop', =>
			@hide()
		oktell.on "stateChange", (newState, oldState)=>
			if ( newState is "call" and oldState is "backring" ) or newState is "ready" or newState is "talk"
				@hide()

		@answerButtonVisible false

	playRingtone: (play)->
		try
			if @ringtone
				if play
					@ringtone.currentTime = 0
					@ringtone.play()
				else
					@ringtone.pause()
		catch e
			@log "playRingtone #{play} throw error", e

	show: (abonents) ->
		if Date.now() - @_lastPopupShowTime < 1000
			return
		@_lastPopupShowTime = Date.now()
		@log 'Popup show! ', abonents
		@el.fadeIn 200

	hide: ->
		@log "Popup hide!"
		@playRingtone false
		@el.fadeOut 200, =>
			@setAbonents []
			abonentsSet = false	

	setAbonents: (abonents) ->
		@absContainer.empty()
		$.each abonents, (i,abonent) =>
			if not abonent
				@log 'setAbonent: bad abonent'
				return
			phoneFormatted = abonent.phoneFormatted?.toString?()
			phone = abonent.phone?.toString?()
			name = abonent.name?.toString?()

			if name is phone
				foundInUsers = false
				for u of @users
					user = @users[u]
					if user.number is phone
						name = user.name
						foundInUsers = true
						break
				@log "Found #{phone} in users = #{foundInUsers}"
				if not foundInUsers
					name = phoneFormatted or phone
					phone = ''
			else
				name = abonent.name.toString()

			el = @abonentEl.clone()
			el.find('span:first').text(name)
			el.find('span:last').text(phone)
			@absContainer.append el

	answerButtonVisible: (val) ->
		if val
			@answerActive = true
			@answerButttonEl.show()
			@puckupEl.hide()
		else
			@answerActive = false
			@answerButttonEl.hide()
			@puckupEl.show()
		@answerActive

	setCallbacks: (onAnswer, onTerminate) ->
		@onAnswer = onAnswer
		@onTerminate = onTerminate
