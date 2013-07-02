class Error
	logGroup: 'Error'
	errorTypes:
		1: 'usingOktellClient'
		2: 'loginPass'
		3: 'unavailable'
	constructor: (errorEl, oktell)->
		@el = errorEl

		oktell.on 'connecting', =>
			@hide()

		oktell.on 'disconnect', (reason)=>
			@log 'disconnect with reason ' + reason.code + ' ' + reason.message
			if reason.code is 12
				@show 3, oktell.getMyInfo().login

		oktell.on 'connectError', (error)=>
			@log 'connect error ' + error.errorCode + ' ' + error.errorMessage
			switch error.errorCode
				when 12 then @show 1, oktell.getMyInfo().login
				when 13 then @show 2, oktell.getMyInfo().login
				when 1204 then @show 1, oktell.getMyInfo().login
				when 1202 then @show 2, oktell.getMyInfo().login

	show: (errorType, username) ->
		if not @errorTypes[errorType] then return false
		@log 'show ' + errorType
		type = @errorTypes[errorType]
		@el.find('p:eq(0)').text @langs[type].header.replace('%username%', username )
		@el.find('p:eq(1)').text @langs[type].message?.replace('%username%', username ) or ''
		@el.find('p:eq(3)').text @langs[type].message2?.replace('%username%', username ) or ''
		@el.fadeIn 200

	hide: ->
		@el.fadeOut 200

