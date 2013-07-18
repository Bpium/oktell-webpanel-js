class PermissionsPopup
	constructor: (popupEl, oktellVoice)->
		@el = popupEl

		if oktellVoice

			oktellVoice.on 'mediaPermissionsRequest', =>
				@show()

			oktellVoice.on 'mediaPermissionsAccept', =>
				@hide()

			oktellVoice.on 'mediaPermissionsRefuse', =>
				oktell?.endCall();
				@hide()



	show: ->
		@log 'Permissions Popup show!'
		#@el.fadeIn 200
		@el.show()

	hide: ->
		@el.fadeOut 200
