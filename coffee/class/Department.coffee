class Department
	constructor: ( id, name )->
		@lastFilteredUsers = []
		@isSorted = false

		@visible = true
		@users = []
		@id = if id and id isnt '00000000-0000-0000-0000-000000000000' then id else @withoutDepName
		@name = if @id is @withoutDepName or not name then @langs.panel.withoutDepartment else name

	getEl: ->
		@el or (@el = $(@template.replace /\{\{department}\}/g, escapeHtml(@name)))
	getContainer: ->
		@el.find('tbody')

	getInfo: ->
		@name + ' ' + @id

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

	getUsers: (filter, showOffline) ->
		if not @isSorted
			@sortUsers()

		users = []
		exactMatch = false
		if filter is ''
			if showOffline
				users = [].concat @users
			else
				for u in @users
					if u.state isnt 0
						users.push u
		else
			for u in @users
				if u.isFiltered filter, showOffline
					users.push u
					if u.number is filter and not exactMatch
						exactMatch = u
		@lastFilteredUsers = users
		[users, exactMatch]



	sortUsers: ->
		@users.sort @sortFn

	sortFn: (a,b)->
		if a.nameLower > b.nameLower
			1
		else if a.nameLower < b.nameLower
			-1
		else
			if a.number > b.number
				1
			else if	a.number < b.number
				-1
			else
				0


	addUser: ( user ) ->
		if user.number
			@users.push user







