class Popup
	constructor: (popupEl, oktell)->
		@el = popupEl
		@absContainer = @el.find('.b_content')
		@abonentEl = @absContainer.find('.b_abonent').remove()


		@el.find('.j_abort_action').bind 'click', =>
			@hide()
			oktell.endCall()

		@el.find('.j_close_action').bind 'click', =>
			@hide()

		@el.find('i.o_close').bind 'click', =>
			@hide()

		oktell.on 'ringStart', (abonents) =>
			@setAbonents abonents
			@show()

		oktell.on 'ringStop', =>
			@hide()

	show: ->
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