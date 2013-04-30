class PermissionsPopup
	constructor: (popupEl, oktell)->
		@el = popupEl
		oktell.on 'mediaPermissionsRequest', (abonents) =>
			@show()

		oktell.on 'mediaPermissionsAccept', =>
			@hide()

		oktell.on 'mediaPermissionsRefuse', =>
			oktell.endCall();
			@hide()



	show: ->
		@log 'Permissions Popup show!'
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200
