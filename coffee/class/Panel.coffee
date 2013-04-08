class Panel
	constructor: (actionList, usersService) ->
		@actionList = actionList

		@panelNumber = actionList.panelNumber

		@usersService = usersService

		@panelNumberHasFocus = ko.observable false

		# show first action of first filtered user
		ko.computed =>
			hasFocus = @panelNumberHasFocus()
			number = @panelNumber()
			filteredUsers = usersService.usersForPanel()
			if number and hasFocus and filteredUsers.length
				filteredUsers[0]


		filterSetter = ko.computed =>
			usersService.filter @panelNumber()


		@popupVisible = ko.observable false

		input = ''
		phonePopup = ''
		phoneButtons = ''
		topchanged = false

		@afterRender = (el) =>
			@el = $(el)
			input = @el.find('input.b_phone_number_input')
			phoneButtons = input.parent().find('div.i_phone_popup_button')
			input.keyup (e) =>
				if e.keyCode is 13
					#					phonePopup.find('.b_actions_group_list li:first').click()
					#					@hidePopup()
					usersService.usersForPanel()?[0]?.doFirstAction()
					actionList.panelNumber ''
					input.blur()



		@showPopup = (a,b) =>

			if @popupVisible()
				return

			inpitWidth = input.closest(".h_phone_number_bg").width() - 8

			phonePopup.css 'width', inpitWidth
			phonePopup.find('.b_actions_group_list').css 'visibility', 'visible'

			phonePopup.fadeIn 200
			if not topchanged
				topchanged = true
				phonePopup.offset {
								  top: phonePopup.offset().top - 33
								  }

			@popupVisible true


		@hidePopup = =>
			@popupVisible false



		$(document).on "click", (e) =>
			element = $ e.target
			if element.parents(".j_phone_popup_cloned").size() is 0 and element.parents(".h_phone_number_input").size() is 0
				@hidePopup()
		popupInited = false