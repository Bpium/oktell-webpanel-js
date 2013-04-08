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