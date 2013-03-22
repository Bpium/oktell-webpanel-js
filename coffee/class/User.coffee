class User
	constructor: ( oktell, actionList, data ) ->
		_.extend @, data

		if @number
			@number = @number.toString()

		if @name?
			@name = @name.toString()

		@actions = ko.observableArray []

		@hovered = ko.observable(false)

		@actionBarVisible = ko.observable false

		@showedNumber = if @number isnt @name then @number else ''


		@needLoadActions = ko.observable(true)

		@firstAction = ko.computed =>
			@actions()[0]

		@actionBarIsVisible = ko.computed =>
			@firstAction()?[0]? or @actionBarVisible()

		@firstActionIcon = ko.computed =>
			a = actionList.allItems[ @firstAction() ]
			if a
				return a.iconWhite or a.icon or ''
			''

		@firstActionClass = ko.computed =>
			a = @firstAction()
			if a then 'm_button_action_' + @firstAction().toLowerCase() else ''

		@state = ko.observable( if @isFantom then @state else ( @numberObj and @numberObj.state or 0 ) )

		@loadActions = =>
			@needLoadActions false
			@actions oktell.getPhoneActions( if @isFantom then @number else @id )

		@getActions = =>
			if @needLoadActions()
				@loadActions()
			@actions()

		@setActionsOnStateChange = ko.computed =>
			state = @state()
			if state is 0 or state is 7 or not @number
				@actions []
			else
				@loadActions()
			#log 'state change for ' + @name + ': ' + @state.peek(), @actions.peek()
			return

		@isOffline = ko.computed =>
			@state() is 0
		@isBusy = ko.computed =>
			@state() is 5

		@isFiltered = ( filter ) =>

			if not filter or typeof filter isnt 'string'
				return true

			if ( @number and @number.indexOf(filter) isnt -1 ) or ( ' ' + @name ).toLowerCase().indexOf(filter) isnt -1
				return true

			return false


		@generateActionList = ( obj, e ) =>
			#log 'clicked dropdown ', obj, e
			actionList.showActions @getActions(), @number, $(e.currentTarget).closest('ul')


		@doFirstAction = =>
			if @number and @firstAction()
				actionList.doAction @firstAction(), @number

		@loadActionsOnHover = ko.computed =>
			if @hovered()
				@loadActions()

		@loadActions()

		return
