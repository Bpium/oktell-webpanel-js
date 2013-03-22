log = ->
	try
		console.log.apply(console, arguments);
	catch e

#	callFunc = (callback) ->
#		if typeof callback is 'function'
#			callback.apply(this, Array.prototype.slice.call( arguments, 1 ) )

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