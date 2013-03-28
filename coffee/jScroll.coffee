jScroll = ( $el )->
	wrapper = ''
	scroller = ''
	scrollbar_cont = ''
	scrollbar_inner = ''
	scroller_left_while_scrolling = ''
	move_by_bar = ''
	pageY_end = ''
	pageY_start = ''
	pos = ''
	pos_start = ''
	scrolling = ''
	params = {}

	scrollWheelPos = (e, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
		#koef = get_koef(wrapper, scroller)
		#deltaY = deltaScale = ''
		e = e.originalEvent
		wheelDeltaY = if e.detail then e.detail*(-14) else e.wheelDelta / 3
		pos_start = get_position scroller
		pageY_end = get_pageY e

		if pos_start >=0 and wheelDeltaY > 0 or (pos_start+wheelDeltaY) > 0
			wheelDeltaY = 0
			pos_start = 0

		if (pos_start <= ( wrapper.height() - scroller.height() ) ) and wheelDeltaY < 0 or (pos_start+wheelDeltaY) < wrapper.height() - scroller.height()
			pos_start = wrapper.height() - scroller.height()
			wheelDeltaY = 0

		pos = pos_start + wheelDeltaY;
		return pos

	scrollClick = ( e, wrapper, scroller, scrollbar_cont, scrollbar_inner ) =>
		if e.type is START_EVENT
			if params.noMoveMouse
				return
			pageY_start = get_pageY e
			pos_start = get_position scroller
			scrolling = true
			#//document.title =  pos_start;


			$('body').css
				'-moz-user-select': 'none'
				'-ms-user-select': 'none'
				'-khtml-user-select': 'none'
				'-webkit-user-select': 'none'
				'-webkit-touch-callout': 'none'
				'user-select': 'none'

		else if e.type is MOVE_EVENT
			if not scrolling
				return

			if isTouch
				scroll_show scrollbar_inner

			koef_bar = get_koef wrapper, scroller
			pageY_end = get_pageY e
			if move_by_bar
				pos = pos_start*koef_bar - (pageY_end - pageY_start)
				pos = pos/koef_bar
			else
				pos = pos_start + (pageY_end - pageY_start)


			#// near borders
			if pos >= 0
				pos_start = get_position scroller
				pageY_start = pageY_end
				pos = 0

			max_pos = wrapper.height() - scroller.height()
			if pos <= max_pos
				pos_start = get_position scroller
				pageY_start = pageY_end
				pos = max_pos

			scrollTo pos, wrapper, scroller, scrollbar_cont, scrollbar_inner
			params.noMoveMouse = true

		else if e.type is END_EVENT
			if not scrolling
				return
			scrolling = false
			move_by_bar = false

			if isTouch
				scroll_hide scrollbar_inner

			$('body').css
				'-moz-user-select': ''
				'-ms-user-select': ''
				'-khtml-user-select': ''
				'-webkit-user-select': ''
				'-webkit-touch-callout': ''
				'user-select': ''

			if scroller_left_while_scrolling
				scroll_hide scrollbar_inner
		else
			return

	#		SetHeightFromTo = (objFrom, objTo) =>
	#			if typeof objFrom is "object"
	#				height = objFrom.height()
	#			else if typeof objFrom is "number"
	#				height = objFrom
	#			objTo.css 'height', height + 'px'

	scrollTo = (posTop, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
		scroll_show scrollbar_inner
		set_position scroller, posTop
		set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner

	get_pageY = (e) =>
		if isTouch then e.originalEvent.targetTouches[0].clientY else e.clientY

	set_position = ( object, pos ) =>
		object.css
			'position': 'relative',
			'top': pos

	get_position = ( object ) =>
		position = object.css 'top'
		if position is 'auto'
			position = 0

		parseInt position

	get_koef = ( wrapper, scroller ) =>
		w_height = wrapper.height()
		s_height = scroller.height()
		koef = w_height/s_height
		koef

	scroll_show = (scrollbar_inner) =>
		scrollbar_inner.stop true, true
		scrollbar_inner.fadeIn 100

	scroll_hide = (scrollbar_inner) =>
		scrollbar_inner.stop true, true
		scrollbar_inner.fadeOut "slow"

	set_bar_bounds = ( wrapper, scroller, scrollbar_cont, scrollbar_inner ) =>
		c_height = scrollbar_cont.height()
		koef = get_koef wrapper, scroller
		inner_height = c_height*koef;
		#/* hidden scroll if box size is bigger than content size */
		if koef >= 1
			visibility = 'hidden'
		else
			visibility = 'visible'

		scrollbar_inner.css
			'height': inner_height,
			'visibility': visibility

		scroller_position = get_position scroller
		wrapper_height = wrapper.height()
		scroller_height = scroller.height()

		if scroller_position <= 0 and scroller_position <= ( wrapper_height - scroller_height )
			pos = wrapper_height - scroller_height
			pos = Math.min pos, 0
			set_position scroller, pos

		pos_koef = scroller_position / wrapper_height
		pos = wrapper_height*pos_koef
		set_position scrollbar_inner, pos*koef*-1
		params?.onScroll?( { wrapper: wrapper, scroller: scroller, position: scroller_position, length: scroller_height } )

	scrolling = false
	move_by_bar = false

	# Device sniffing
	vendor = if (/webkit/i).test(navigator.appVersion)
		'webkit'
	else if (/firefox/i).test(navigator.userAgent)
		'Moz'
	else if 'opera' in window
		'O'
	else
		''
	#isIthing = (/iphone|ipad/gi).test(navigator.appVersion)
	isTouch = typeof window['ontouchstart'] isnt 'undefined'
	#has3d = window['WebKitCSSMatrix']? and (new window['WebKitCSSMatrix']() )['m11']?
	# Event sniffing
	START_EVENT = if isTouch then 'touchstart' else 'mousedown'
	MOVE_EVENT = if isTouch then 'touchmove' else 'mousemove'
	END_EVENT = if isTouch then 'touchend' else 'mouseup'
	WHEEL_EV = if vendor == 'Moz' then 'DOMMouseScroll' else 'mousewheel'


	if not isTouch and $('.jscroll_wrapper', $el).size()
		return

	init = =>
		# Create wrapper */
		$el.wrapInner '<div class="jscroll_wrapper" />'
		wrapper = $(".jscroll_wrapper", $el)
		wrapper.attr "id", "jscroll_id" + Math.round(Math.random()*10000000)

		# Create scroller */
		scroller = wrapper.wrapInner '<div class="jscroll_scroller" />'
		scroller = $(".jscroll_scroller", wrapper)

		# Create scrollbar cont */
		scrollbar_cont = $('<div class="jscroll_scrollbar_cont"></div>').insertAfter scroller
		scrollbar_cont.css
			'position': 'absolute'
			'right': '0px'
			'width': '13px'
			'top': '3px'
			'bottom': '6px'

		# Create scrollbar inner */
		scrollbar_inner = $('<div class="jscroll_scrollbar_inner"></div>').appendTo scrollbar_cont
		scrollbar_inner.css
			'position': 'relative'
			'width': '100%'
			'display': 'none'
			'opacity': '0.4'
			'cursor': 'pointer'

		scrollbar_bar = $('<div class="jscroll_scrollbar_bar"></div>').appendTo scrollbar_inner
		scrollbar_bar.css
			'position': 'relative'
			'background': 'black'
			'width': '5px'
			'margin': '0 auto'
			'border-radius': '3px'
			'height': '100%'
			'-webkit-border-radius': '3px'


		# set wrapper style*/
		wrapper.css
			"position": "relative"
			"height": "100%"
			"overflow": "hidden"

		# set scroller style*/
		scroller.css
			"min-height": "100%"
			"overflow": "hidden"

		if isTouch

			# Create scroller inner*/
			scroller.after '<div class="jscroll_scroller_inner" />'
			scroller_inner = $(".jscroll_scroller_inner", wrapper)
			scroller_inner.appendTo '<div></div>'

			myScroll = new iScroll wrapper.attr("id") ,
				hScrollbar: false
				scrollbarClass: 'jscroll_scroller_inner'
				checkDOMChanges: true
				bounceLock: true
				onScrollMove: =>
					params.onScroll()
					true
				onScrollEnd: =>
					params.onScroll()
					true

			return true

		else
			set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner

	init()

	if isTouch
		return

	# EVENTS */

	# resize container or change data
	jscroll_timer = new Array
	wrapper.bind 'resize', (e) =>
		timer_id = wrapper.attr('id')
		if typeof jscroll_timer[ timer_id ] isnt 'undefined'
			clearTimeout( jscroll_timer[ timer_id ] )

		jscroll_timer[ timer_id ] = setTimeout =>
			set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner
			delete jscroll_timer[ timer_id ]
		, 100
		return

	if not isTouch
		wrapper.hover =>
			scroller_left_while_scrolling = false
			set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner
			scroll_show scrollbar_inner
			return
		, =>
			scroller_left_while_scrolling = true
			if scrolling
				return
			scroll_hide scrollbar_inner
			return

	scrollbar_inner.bind START_EVENT, (e) =>
		move_by_bar = true
		params.noMoveMouse = false
		return true

	wrapper.bind START_EVENT, (e) =>
		scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
		return true

	$(document).bind MOVE_EVENT, (e) =>
		scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
		return true

	$(document).bind END_EVENT, (e) =>
		scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
		return true

	wrapper.on WHEEL_EV, (e) =>
		wheelPos = scrollWheelPos e, wrapper, scroller, scrollbar_cont, scrollbar_inner
		scrollTo wheelPos, wrapper, scroller, scrollbar_cont, scrollbar_inner
		return false

