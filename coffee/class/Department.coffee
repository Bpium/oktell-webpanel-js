class Department
	logGroup: 'Department'
	constructor: ( id, name )->
		@usersVisibilityCss = 'invisibleDep'
		@lastFilteredUsers = []
		@isSorted = false
		@visible = true
		@users = []
		@id = if id and id isnt '00000000-0000-0000-0000-000000000000' then id else @withoutDepName
		@name = if @id is @withoutDepName or not name then @langs.panel.withoutDepartment else name
		@isOpen = if @config().departmentVisibility[@id]? then @config().departmentVisibility[@id] else true

	getEl: (usersVisible)->
		@log 'get el, usersVisible - ' + usersVisible + ' , for department ' + @getInfo()
		if not @el
			@el = $(@template.replace /\{\{department}\}/g, escapeHtml(@name))
			@el.find('.b_department_header').bind 'click', =>
				@showUsers()
		if usersVisible
			@_oldIsOpen = @isOpen
			@showUsers true, true
		else
			@showUsers if @_oldIsOpen? then @_oldIsOpen else @isOpen
		@el
	getContainer: ->
		@el.find('tbody')

	showUsers: (val, notSave)->
		if typeof val is 'undefined'
			val = ! @isOpen
		if not @hideEl
			@hideEl = @el.find 'table'
		@log 'department users visibility set ' + val + ' , without save - ' + notSave + '. For ' + @getInfo()

		@hideEl.stop true, true
		if not notSave
			@isOpen = val
			c = @config()
			c.departmentVisibility[@id] = @isOpen
			@config c
		if val
			#@hideEl.slideDown 200
			@el.toggleClass @usersVisibilityCss, false
			@hideEl.show()
		else
			#@hideEl.slideUp 200
			@el.toggleClass @usersVisibilityCss, true
			@hideEl.hide()



	getInfo: ->
		@name + ' ' + @id

	clearUsers: ->
		@users = []

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







