class Popup
	logGroup: 'Popup'
	constructor: (popupEl, oktell, ringtone)->
		@el = popupEl
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

		oktell.on 'webrtcRingStart', (name, identity) =>
			@log 'webrtcRingStart, ' + identity
			@playRingtone true
			@answerButtonVisible true
			if not abonentsSet
				@setAbonents [{name:name, phone: identity.match(/<sip:([\s\S]+?)@/)?[1] or ''}]
			@show()

		oktell.on 'ringStart', (abonents) =>
			@log 'ringStart', abonents
			@setAbonents abonents
			abonentsSet = true
			@show()

		oktell.on 'ringStop', =>
			@playRingtone false
			@hide()
			abonentsSet = false
			@setAbonents []

		@answerButtonVisible false

	playRingtone: (play)->
		if @ringtone
			if play
				@ringtone.currentTime = 0
				@ringtone.play()
			else
				@ringtone.pause()

	show: (abonents) ->
		@log 'Popup show! ', abonents
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200

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
