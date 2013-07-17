class Notify
	constructor: (title, autoHide = 0, message, group, onClick)->
		if not ( typeof title is 'string' and title ) or window.webkitNotifications.checkPermission() isnt 0
			return

		if typeof message is 'function'
			onClick = message
			message = ''
			group = null
		else if typeof group is 'function'
			onClick = group
			group = null

		notify = window.webkitNotifications.createNotification 'favicon.ico', title, message or ''
		if group
			notify.tag = group
		notify.show()
		autoHide = parseInt(autoHide)
		if autoHide
			setTimeout =>
				notify.close()
			, autoHide * 1000
		notify.onclick = (e, args...) =>
			window.focus?()
			notify.close()
			if typeof onClick is 'function'
				onClick.apply window, []

		@close = =>
			notify?.close?()



