class Popup
	constructor: (popupEl, oktell)->
		@el = popupEl
		@absContainer = @el.find('.b_content')
		@abonentEl = @absContainer.find('.b_abonent').remove()

		@answerActive = false
		@answerButttonEl = @el.find '.j_answer'
		@puckupEl = @el.find '.j_pickup'


		@el.find('.j_abort_action').bind 'click', =>
			@hide()
			oktell.endCall();
		@el.find('.j_answer').bind 'click', =>
			@hide()
			oktell.answer();

		@el.find('.j_close_action').bind 'click', =>
			@hide()

		@el.find('i.o_close').bind 'click', =>
			@hide()

		oktell.on 'ringStart', (abonents) =>
			@setAbonents abonents
			@answerButtonVisible oktell.webphoneIsActive()
			@show()

		oktell.on 'ringStop', =>
			@hide()



	show: (abonents) ->
		@log 'Popup show! ', abonents
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200

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
