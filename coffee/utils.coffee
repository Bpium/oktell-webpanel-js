debounce = (func, wait, immediate) ->
	timeout = ''
	return ->
		context = this
		args = arguments
		later = ->
			timeout = null
			if not immediate
				result = func.apply(context, args)

		callNow = immediate and not timeout
		clearTimeout(timeout)
		timeout = setTimeout(later, wait)
		if callNow
			result = func.apply(context, args)
		result

escapeHtml = (string) ->
	(''+string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;')

log = ->
	try
		console.log.apply(console, arguments);
	catch e

cookie = (key, value, options) ->

	# key and at least value given, set cookie...
	if arguments.length > 1 and String(value) isnt "[object Object]"
		options = $.extend {}, options

		if not value?
			options.expires = -1

		if typeof options.expires is 'number'
			seconds = options.expires
			t = options.expires = new Date()
			t.setSeconds t.getSeconds() + seconds

		value = String value

		return document.cookie = [
			encodeURIComponent(key), '=',
			if options.raw then value else encodeURIComponent(value),
			if options.expires then '; expires=' + options.expires.toUTCString() else '', # use expires attribute, max-age is not supported by IE
			if options.path then '; path=' + options.path else '',
			if options.domain then '; domain=' + options.domain else '',
			if options.secure then '; secure' else ''
		].join('')


	# key and possibly options given, get cookie...
	options = value or {}
	result = ''
	if options.raw
		decode = (s) -> s
	else
		decode = decodeURIComponent

	if (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie))
		decode(result[1])
	else
		null

newGuid = ()->
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
		r = Math.random()*16|0
		v = if c is 'x' then r else (r&0x3|0x8)
		v.toString(16)