class Popup
	logGroup: 'Popup'
	constructor: (popupEl, oktell)->
		@el = popupEl
		@absContainer = @el.find('.b_content')
		@abonentEl = @absContainer.find('.b_abonent').remove()

		@isBack101 = false


		@el.find('.j_abort_action').bind 'click', =>
			@hide()
			oktell.endCall()

		@el.find('.j_close_action').bind 'click', =>
			@hide()

		@el.find('i.o_close').bind 'click', =>
			@hide()

		oktell.on 'ringStart', (abonents) =>
			if not @isBack101
				@setAbonents abonents
			@show()

		oktell.on 'ringStop', =>
			@isBack101 = false
			@hide()

#		oktell.on 'connect', =>
#			oktell.onNativeEvent 'phoneevent_ringstarted', (data) =>
##				callercomment: ""
##				callerdescription: ""
##				callerdirection: "oktell_pbx"
##				callerid: ""
##				callerinfo: "Автодозвон. Обратный вызов.↵Абонент: 89274513158"
##				callerlineid: "00000000-0000-0000-0000-000000000000"
##				callerlinenum: "00000"
##				callername: ""
##				canfax: false
##				canvideo: false
##				chainid: "c6ed99c1-c53a-4224-b4e5-cd58682c8b87"
##				connectionindex: 4
##				isconference: false
##				isextline: false
##				istask: false
##				qid: "e2382a55-53c1-45bc-be80-13910f31082e"
##				userid: "d8af50ea-74a6-4a57-b0d5-451962f6c042"
##				userlogin: "airato"
#				if data?.callerdirection is 'oktell_pbx' and data?.callerlineid is '00000000-0000-0000-0000-000000000000' and data?.callerlinenum is '00000' and data?.callerinfo
#					@isBack101 = data.callerinfo
#					@setAbonents [{name:@isBack101, phone: ''}]


	show: ->
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200
		@isBack101 = false

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