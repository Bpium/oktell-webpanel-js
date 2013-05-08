class Error
	errorTypes:
		1: 'desktopClient'
		2: 'errorLoginPass'
		3: 'errorConnection'
	constructor: (errorEl, oktell)->
		@el = errorEl

	show: (errorType) ->
		if not @errorTypes[errorType] then return false
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200

