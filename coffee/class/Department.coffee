class Department
	constructor: ( id, name )->

		@isSorted = false

		@visible = true
		@users = []
		@id = if id and id isnt '00000000-0000-0000-0000-000000000000' then id else @withoutDepName
		@name = if @id is @withoutDepName or not name then @langs.panel.withoutDepartment else name

	getEl: ->
		@el or (@el = $(@template.replace /\{\{department}\}/g, escapeHtml(@name)))

	show: (withAnimation) ->
		if not @el or @visible then return
		if withAnimation
			@el.slideDown 200
		else
			@el.show()
		@visible = true
	hide: (withAnimation) ->
		if not @el or not @visible then return
		if withAnimation
			@el.slideUp 200
		else
			@el.hide()
		@visible = false

	getUsers: (filter) ->
		if not @isSorted
			@sortUsers()
		if filter is ''
			[].concat @users
		else


	sortUsers: ->

	addUser: ( user ) ->
		@users.push user









