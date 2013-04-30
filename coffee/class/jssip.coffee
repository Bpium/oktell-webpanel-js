loader.types['jssip'] = ['localstorage', 'oktell', 'Popup', class extends BaseType
	constructor: (lStorage, oktell, popup) ->
		super

		@_isConnected = false
		@popup = popup

		#@log = @setLogGroup 'JsSip', 'background: #06E69C; color: black'

		@useVideo = false

		$('body').append '<video id="jssipVideoElRemote" autoplay="" hidden="true"></video>'
		$('body').append '<video id="jssipVideoElSelf" autoplay="" hidden="true"></video>'

		@videoElSelf = $('#jssipVideoElSelf')[0]
		@videoElRemote = $('#jssipVideoElRemote')[0]

#		@oktell = oktell
		@oktellCall = oktell.call
		oktell.call = =>
			@phoneCall.apply @, arguments


		#@lStorage = lStorage

		@paramNames = ['uri','ws_servers','display_name','password','authorization_user','register','register_expires','registrar_server','no_answer_timeout','trace_sip','stun_servers','turn_servers',
				  'use_preloaded_route','connection_recovery_min_interval','connection_recovery_max_interval','hack_via_tcp','hack_ip_in_contact']
		@boolParams = ['register']

		#@params = ko.observableArray []

		#@fillParams()

		@on 'all', (a,b...) => @log a,b

		@newSessionEvent = false

		@on 'newSession', (e) =>
			e = @newSessionEvent
			@trigger 'incomingCall', @langs.popups.call.undefinedNumber, @langs.popups.call.undefinedNumber, =>
				# answer
				e.data.session.answer()
			, =>
				#reject
				e.data.session.terminate()
			, =>
				#hide


		@ua = false

	isConnected: (val) ->
		if val? and Boolean(val) isnt @_isConnected
			@_isConnected = Boolean(val)
			popup.answerButtonVisible @_isConnected
		@_isConnected

	connect: ->

		@disconnect()

		#params = @saveParams()

		if not window.JsSIP or not JsSIP.UA
			return false

		@ua = new JsSIP.UA params

		@ua.on 'newSession', (e) =>
			@trigger 'newSession', e
		@ua.on 'registered', (e) =>
			@isConnected true
		@ua.on 'unregistered', (e) =>
			@isConnected false
		@ua.on 'disconnected', (e) =>
			@isConnected false

		@ua.start()




	disconnect: ->
		if @ua?.stop?
			@ua.unregister()
			@ua.stop()

	phoneCall: (number, callback) ->
		if not number then return

		if @ua?.isConnected?()
			@ua.call number,
				selfView: @videoElSelf
				remoteView: @videoElRemote
			,
				mediaTypes:
					audio: true
					video: @useVideo
				eventHandlers:
					connecting: (e) => @trigger 'callConnecting', number, e
					progress: (e) =>
						@trigger 'callProgress', number, e
					failed: (e) => @trigger 'callFailed', number, e
					started: (e) => @trigger 'callStarted', number, e
					ended: (e) => @trigger 'callEnded', number, e
		else
			@oktellCall number, callback



#	saveParams: ->
#		savedParams = {}
#		for p in @params()
#			savedParams[p.name] = p.val()
#		@lStorage.set 'jssipParams', savedParams
#		savedParams

#	fillParams: ->
#		savedParams = {}
#		currParams = {}
#		for p in @params()
#			currParams[p.name] = p
#		for pName in @paramNames
#			if not currParams[pName]?
#				@params.push
#					val: ko.observable if @boolParams.indexOf(pName) isnt -1 then ( if savedParams[pName] then true else false ) else savedParams[pName] or ''
#					name: pName
#					fullName: _.map( pName.split('_'), (w) -> w[0].toUpperCase() + w.substr(1) ).join(' ')
#			else if currParams[pName]?
#				currParams[pName].val savedParams[pName] or ''
#
#		@params




]
