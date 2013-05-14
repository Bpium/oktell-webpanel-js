#OktellVoice = do ->

debugMode = false
logStr = ''
log = (args...)->
	if not debugMode then return
	d = new Date()
	dd =  d.getFullYear() + '-' + (if d.getMonth()<10 then '0' else '') + d.getMonth() + '-' + (if d.getDate()<10 then '0' else '') + d.getDate();
	t = (if d.getHours()<10 then '0' else '') + d.getHours() + ':' + (if d.getMinutes()<10 then '0' else '')+d.getMinutes() + ':' +  (if d.getSeconds()<10 then '0' else '')+d.getSeconds() + ':' +	(d.getMilliseconds() + 1000).toString().substr(1)
	logStr += dd + ' ' + t + ' | '
	fnName = 'log'
	if args[0].toString().toLowerCase() is 'error'
		fnName = 'error'
	for val, i in args
		if typeof val == 'object'
			try
				logStr += JSON.stringify(val)
			catch e
				logStr += val.toString()
		else
			logStr += val
		logStr += ' | '
	logStr += "\n\n"
	args.unshift 'Oktell-Voice.js ' + t + ' |'
	try
		console[fnName].apply( console, args || [])
	catch e
logErr = (args...)->
	log.apply this, ['error'].concat(args)

eventSplitter = /\s+/
events =
	on: (eventNames, callback, context) ->
		if not eventNames or typeof callback isnt 'function' then return false
		eventNames = eventNames.split eventSplitter
		callbacks = @__eventCallbacks or (@__eventCallbacks = {})
		for event in eventNames
			eventCallbacks = callbacks[event] or (callbacks[event] = [])
			eventCallbacks.push { fn: callback, context: context }
		true
	off: (eventNames, callback) ->
		if not eventNames?
			@__eventCallbacks = {}
		else
			callbacks = @__eventCallbacks or (@__eventCallbacks = {})
			eventNames = eventNames.split eventSplitter
			if not callback?
				for event in eventNames
					delete callbacks[event]
			else
				for event in eventNames
					eventCallbacks = callbacks[event] or (callbacks[event] = [])
					for eventCallback, i in eventCallbacks
						if eventCallback.fn is callback
							eventCallbacks[i] = false
		true
	trigger: (eventNames, args...)->
		#log 'triggger ' + eventNames
		if not eventNames
			return false
		eventNames = eventNames.split eventSplitter
		callbacks = @__eventCallbacks or (@__eventCallbacks = {})
		for event in eventNames
			eventCallbacks = callbacks[event] or (callbacks[event] = [])
			for eventInfo in eventCallbacks
				if eventInfo.fn?
					eventInfo.fn.apply eventInfo.context or window, args
			args.unshift event
			for eventInfo in (callbacks['all'] or [])
				if eventInfo.fn?
					eventInfo.fn.apply eventInfo.context or window, args
extend = (target, args...) ->
	for i in [args.length-1..0]
		if typeof args[i] is 'object'
			for own key, val of args[i]
				target[key] = val
	target



class Account
	id: ''
	connected: false
	constructor: (sipObject, login, pass, server)->
		@sip = sipObject
		@login = login
		@pass = pass or ''
		@server = server?.split(':')[0]
		@port = server?.split(':')[1] or '5060'
		if @sip and @login and @server and @port
			@constructed = true
		@name = 'Common account'
		@on 'all', (event, args...) =>
			log 'EVENT ' + event + ' on ' + @getName(), args
	getName: ->
		@name + ' #' + @.id
	connect: ->
		if not @constructed
			logErr 'error while consctruct ' + @getName()
			false
		else
			log @getName() + ' connect', arguments
			true
	call: (number) ->
		if not number
			return false
		log @getName() + ' call', arguments
		true
	answer: ->
		log @getName() + ' answer', arguments
	transfer: (to)->
		if not to then return false
		log @getName() + ' transfer', arguments
		true
	hangup: ->
		log @getName() + ' hangup', arguments
	dtmf: ->
		log @getName() + ' dtmf', arguments
	hold: ->
		log @getName() + ' hold', arguments
	reject: ->
		log @getName() + ' reject', arguments
	disconnect: ->
		log @getName() + ' disconnect', arguments
extend Account.prototype, events

class SIPml5Account extends Account
	constructor: ->
		super
		@name = 'SIPml5 account'
	createFantomAbonent:  (newSession)->
		caller = if typeof newSession == 'string' or typeof newSession == 'number' then newSession else newSession.getRemoteFriendlyName()
		abonents = [{phone: caller.toString(), name: caller.toString()}]
		return abonents
	sipStack: false
	goLogin: ->
		@registerSession = @sipStack.newSession 'register',
			events_listener:
				events: '*',
				listener: (e)=>
					log 'registerSession event = ' + e.type
					if e.session is @registerSession
						if e.type is 'connected'
							@connected = true
							@trigger 'connect'
							#oktell.trigger 'phoneRegistered'
						else if e.type is 'terminated'
							@connected = false
							@trigger 'disconnect'
							#oktell.trigger 'phoneUnregistered'

		@registerSession.register()
	createAudioElement: ->
		@el = document.createElement 'audio'
		@elId = 'oktellVoice_sipml5_' + Date.now()
		@el.setAttribute 'id', @elId
	connect: ->
		if not super then return false
		@createAudioElement() unless @el
		@sip.debugMode = debugMode
		@sip.init (e)=>
			@sipStack = new @sip.Stack
				realm: @server #mandatory: domain name
				impi: @login # mandatory: authorization name (IMS Private Identity)
				impu: 'sip:' + @login + '@' + @server # mandatory: valid SIP Uri (IMS Public Identity)
				password: @pass # optional
				display_name: @login # optional
				ice_servers: [{"url":"stun:stun.l.google.com:19302"}]
				websocket_proxy_url: 'ws://'+@server+':'+@port # optional
				outbound_proxy_url: 'udp://'+@server+':'+@port # optional
				enable_rtcweb_breaker: false # optional
				events_listener:
					events: '*'
					listener: (e)=>
						log 'sipStack event = ' + e.type
						switch e.type
							when 'started'
								@goLogin()
							when 'i_new_call'
								abonents = @createFantomAbonent e.newSession
								#oktell.trigger 'phoneRingStart', abonents
								#oktell.trigger 'abonentsChange', abonents
								@currentSession = e.newSession
								session = @currentSession
								session.setConfiguration
									events_listener:
										events: '*',
										listener: (e) =>
											log 'INCOMING session event!!! ' + e.type
											if e.type is 'connected'
												abonents = @createFantomAbonent session
												#oktell.trigger 'phoneTalkStart'
												session.eventTalkStart = true
												@trigger 'talkStart', session.getRemoteFriendlyName()
											else if e.type is 'terminated'
												#oktell.trigger 'phoneSessionStop'
												if session.eventRingStart and not session.eventRingStop
													session.eventRingStop = true
													@trigger 'ringStop', session.getRemoteFriendlyName()
												if session.eventTalkStart
													session.eventTalkStop = true
													@trigger 'talkStop', session.getRemoteFriendlyName()
												@currentSession = false
												@trigger 'sessionClose'
								session.eventRingStart = true
								@trigger 'ringStart', session.getRemoteFriendlyName()
							when 'm_permission_requested'
								@trigger 'mediaPermissionsRequest'
							when 'm_permission_accepted'
								@trigger 'mediaPermissionsAccept'
							when 'm_permission_refused'
								@trigger 'mediaPermissionsRefuse'

				sip_headers: [ # optional
					{ name: 'User-Agent', value: 'Oktell WebRTC' }
					{ name: 'Organization', value: 'Oktell' }
				]
			@sipStack.start()
		, (e)=>
			logErr('Failed to initialize the engine: ' + e.message)

	call: (number) ->
		if not super then return false
		number = number.toString()
		session = @sipStack.newSession 'call-audio',
			audio_remote: @el
			events_listener:
				events: '*'
				listener: (e)=>
					if @currentSession is e.session
						log '!! callSession event = ' + e.type
						if e.type is 'terminated'
							#oktell.trigger 'phoneSessionStop'
							if session.eventTalkStart
								session.eventTalkStop = true
								@trigger 'talkStop', session.getRemoteFriendlyName()
							@currentSession = false
							@trigger 'sessionClose'
						else if e.type is 'connected'
							abonents = @createFantomAbonent e.session
							#oktell.trigger 'phoneTalkStart'
							if session.eventCallStart and not session.eventCallStop
								session.eventCallStop = true
								@trigger 'callStop', session.getRemoteFriendlyName()
							session.eventTalkStart = true
							@trigger 'talkStart', session.getRemoteFriendlyName()

		@currentSession = session
		abonents = @createFantomAbonent number
		#oktell.trigger 'phoneCallStart', abonents
		#oktell.startCallWebRTC number
		session.eventCallStart = true
		@trigger 'callStart', number
		@currentSession.call number

	answer: ->
		super
		@currentSession?.accept?()

	hangup: ->
		super
		@currentSession?.hangup?()

	reject: ->
		super
		@currentSession?.reject?()
	hold: ->
		super
		@currentSession?.hold?()

	resume: ->
		super
		@currentSession?.resume?()

	dtmf: (digit) ->
		super
		@currentSession?.dtmf?(digit)

	transfer: (to) ->
		if not super then return false
		@currentSession?.transfer?(to.toString())

	disconnect: ->
		@sipStack.stop()
		setTimeout ->
			location.reload()
		, 500


class JsSIPAccount extends Account
	constructor: ->
		super

OktellVoice =
	isOktellVoice: true
extend OktellVoice, events

manager =
	accounts: []
	defaultAcc: null
	defaultOptions:
		typeName: 'sipml5' # 'jssip'
		debugMode: false

	getSipObject: (typeName) ->
		switch typeName
			when 'sipml5' then window.SIPmlCreate()
			#when 'jssip' then window.
	getClassByTypeName: (name)->
		switch name
			when 'sipml5' then SIPml5Account
	exportKeys: ['call', 'answer', 'hangup', 'transfer', 'hold', 'resume', 'dtmf', 'reject', 'disconnect']
	createExportAccount: (account) ->
		if not account? then return false
		a = {}
		for key in @exportKeys when account[key]?
			do ->
				val = account[key]
				a[key] = ->
					val.apply account, arguments
		extend a, events
		account.on 'all', (args...)=>
			a.trigger.apply a, args
		return a
	createAccount: (opts) ->
		opts = extend {}, opts or {}, @defaultOptions
		sipObject = opts.type or @getSipObject opts.typeName
		accClass = @getClassByTypeName opts.typeName
		if not sipObject or not accClass then return false
		debugMode = Boolean opts.debugMode
		acc = new accClass sipObject, opts.login, opts.password, opts.server
		@defaultAcc ?= acc
		acc.id = @accounts.length + 1
		@accounts.push acc
		acc.connect()
		return acc

for key in manager.exportKeys
	OktellVoice[key] = -> false

OktellVoice.connect = ->
	acc = manager.createAccount.apply manager, arguments
	exportAcc = manager.createExportAccount acc
	if acc is manager.defaultAcc
		extend OktellVoice, exportAcc
		exportAcc.on 'all', (args...)=>
			OktellVoice.trigger.apply OktellVoice, args
		OktellVoice.on 'all', (eventname, args...)=>
			console.log 'OktellVoice!!!!!!!!!!!!!!!!!!!! EVENT ' + eventname, args
	exportAcc

OktellVoice.disconnect = =>

OktellVoice.version = '0.1.0'

#return OktellVoice