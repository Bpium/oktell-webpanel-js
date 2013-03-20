(($, ko)->
	if not $ or not ko
		throw new Error('Error init oktell panel, jQuery or Knockout.js is not defined')

	ko.bindingHandlers.hoverSelect = {
		init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
			el = $(element)
			el.hover =>
				el.addClass 'g_hover'
			, =>
				el.removeClass 'g_hover'
			return
	}

	ko.bindingHandlers.inputClear = {
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->

		data = valueAccessor()

		if ko.isObservable data
			observ = data
			afterClear = ->
		else
			observ = if ko.isObservable data.value then data.value else false
			afterClear = if typeof data.afterClear is 'function' then data.afterClear else ->

		input = $(element)
		if input.size()
			check = ->
				val = if ko.isObservable observ then observ() else input.val()
				if val
					input.parent().find('.jInputClear_close').show()
					#					if attr.ngInputClearOnshow
					#						scope.$eval(attr.ngInputClearOnshow)
				else
					input.parent().find('.jInputClear_close').hide()
				#					if attr.ngInputClearOnhide
				#						scope.$eval(attr.ngInputClearOnhide)
				return

			window.i = input
			input.bind 'focusin', ->
				if not input.parent().hasClass 'jInputClear_hover'
					input.wrap('<div class="jInputClear_hover" />').parent().append('<span class="jInputClear_close">&times;</span>')

					input.parent().find('.jInputClear_close').click (e) ->
						$(e.currentTarget).hide()
						if ko.isObservable observ
							observ ''
						else
							input.val ''
						afterClear()
						input.focus()

					input.focus()
					log 'focus'
					setTimeout =>
								   input.focus()
							   , 2000
					check()
				return true

			if ko.isObservable observ
				valChecker = ko.computed =>
					observ()
					check()
			else
				input.keyup ->
					check()



		return
	}

	ko.bindingHandlers.jScroll = {
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->

		$el = $(element)
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


		params = valueAccessor()

		if params and params.native
			$el.addClass 'j_native_scroll_block'

		nativeScrollInit = ( wrapper, scroller, scrollbar_cont, scrollbar_inner ) =>
			if not wrapper.parent().is(".j_native_scroll_block:visible")
				return

			if not $(".j_native_scroll").size()
				body = $("body");
				# Create scroll */
				body.append '<div class="j_native_scroll"></div>'
				nativeWrapper = $(".j_native_scroll", body)

				#/* Create scroll inner */
				nativeWrapper.append '<div class="j_native_scroll_inner">&nbsp;</div>'
				nativeInner = $(".j_native_scroll", nativeWrapper)

				#/* set scroll style*/
				nativeWrapper.css {
								  "width": '18px',
								  "height": "100%",
								  "position": "fixed",
								  "right": "0",
								  "overflow-y": "auto",
								  "overflow-x": "hidden",
								  "z-index": "10000"
								  }

				#/* set scroll inner style*/
				nativeInner.css {
								"height": "auto"
								}

			ns =  $(".j_native_scroll")

			$("html").unbind WHEEL_EV + '.jscroll'
			$("html").bind WHEEL_EV + '.jscroll', (e) =>

	#				if $(e.target).is('.j_not_scroll_by_jscroll')
	#					return

				pos = scrollWheelPos e, wrapper, scroller, scrollbar_cont, scrollbar_inner
				ns.scrollTop pos*-1


			SetHeightFromTo scroller.height() + $(window).height() - wrapper.height(), $(".j_native_scroll_inner")

			wrapper.unbind 'recalculateNative'
			wrapper.bind 'recalculateNative', =>
				SetHeightFromTo scroller.height() + $(window).height() - wrapper.height(), $(".j_native_scroll_inner")

			$(".j_native_scroll").unbind 'scroll.jscroll'
			$(".j_native_scroll").bind 'scroll.jscroll', =>

				scrollTo  -1 * ns.scrollTop(), wrapper, scroller, scrollbar_cont, scrollbar_inner

		scrollWheelPos = (e, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
			koef = get_koef(wrapper, scroller)
			deltaY = deltaScale = ''
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


				$('body').css {
							  '-moz-user-select': 'none',
							  '-ms-user-select': 'none',
							  '-khtml-user-select': 'none',
							  '-webkit-user-select': 'none',
							  '-webkit-touch-callout': 'none',
							  'user-select': 'none'
							  }

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

				#/* Native Scroll */
				if wrapper.parent().hasClass("j_native_scroll_block")
					$(".j_native_scroll").scrollTop(pos*-1)


			else if e.type is END_EVENT
				if not scrolling
					return
				scrolling = false
				move_by_bar = false

				if isTouch
					scroll_hide scrollbar_inner

				$('body').css {
							  '-moz-user-select': '',
							  '-ms-user-select': '',
							  '-khtml-user-select': '',
							  '-webkit-user-select': '',
							  '-webkit-touch-callout': '',
							  'user-select': ''
							  }

				if scroller_left_while_scrolling
					scroll_hide scrollbar_inner
			else
				return

		SetHeightFromTo = (objFrom, objTo) =>
			if typeof objFrom is "object"
				height = objFrom.height()
			else if typeof objFrom is "number"
				height = objFrom
			objTo.css 'height', height + 'px'

		scrollTo = (posTop, wrapper, scroller, scrollbar_cont, scrollbar_inner) =>
			scroll_show scrollbar_inner
			set_position scroller, posTop
			set_bar_bounds wrapper, scroller, scrollbar_cont, scrollbar_inner

		get_pageY = (e) =>
			if isTouch then e.originalEvent.targetTouches[0].clientY else e.clientY

		set_position = ( object, pos ) =>
			object.css {
					   'position': 'relative',
					   'top': pos
					   }

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

			scrollbar_inner.css {
								'height': inner_height,
								'visibility': visibility
								}

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
			params.onScroll { wrapper: wrapper, scroller: scroller, position: scroller_position, length: scroller_height }

		scrolling = false
		move_by_bar = false
		debounce = (func, wait, immediate) =>
			return =>
				context = this
				args = arguments
				later = =>
					timeout = null;
					if not immediate
						func.apply(context, args)

				callNow = immediate && !timeout
				clearTimeout(timeout);
				timeout = setTimeout(later, wait)
				if callNow
					func.apply(context, args)

		params = $.extend {
						  onScroll: ( opt ) =>
						  noMoveMouse: true
						  }, params

		scroll_array = new Array
		# Device sniffing
		vendor = if (/webkit/i).test(navigator.appVersion)
			'webkit'
		else if (/firefox/i).test(navigator.userAgent)
			'Moz'
		else if 'opera' in window
			'O'
		else
			''
		isIthing = (/iphone|ipad/gi).test(navigator.appVersion)
		isTouch = typeof window['ontouchstart'] isnt 'undefined'
		has3d = window['WebKitCSSMatrix']? and (new window['WebKitCSSMatrix']() )['m11']?
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
			scrollbar_cont.css {
							   'position': 'absolute'
							   'right': '0px'
							   'width': '13px'
							   'top': '3px'
							   'bottom': '6px'
							   }

			# Create scrollbar inner */
			scrollbar_inner = $('<div class="jscroll_scrollbar_inner"></div>').appendTo scrollbar_cont
			scrollbar_inner.css {
								'position': 'relative'
								'width': '100%'
								'display': 'none'
								'opacity': '0.4'
								'cursor': 'pointer'
								}
			scrollbar_bar = $('<div class="jscroll_scrollbar_bar"></div>').appendTo scrollbar_inner
			scrollbar_bar.css {
							  'position': 'relative',
							  'background': 'black',
							  'width': '5px',
							  'margin': '0 auto',
							  'border-radius': '3px',
							  'height': '100%',
							  '-webkit-border-radius': '3px'
							  }


			# set wrapper style*/
			wrapper.css {
						"position": "relative",
						"height": "100%",
						"overflow": "hidden"
						}

			# set scroller style*/
			scroller.css {
						 "min-height": "100%",
						 "overflow": "hidden"
						 }

			if isTouch

				# Create scroller inner*/
				scroller.after '<div class="jscroll_scroller_inner" />'
				scroller_inner = $(".jscroll_scroller_inner", wrapper)
				scroller_inner.appendTo '<div></div>'

				myScroll = new iScroll wrapper.attr("id") , {
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
				}
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


			updateLayout = debounce (e) =>
				nativeScrollInit wrapper, scroller, scrollbar_cont, scrollbar_inner
				return
			, 500

			wrapper.unbind 'DOMNodeInserted', updateLayout
			wrapper.unbind 'DOMNodeRemoved', updateLayout
			wrapper.bind 'DOMNodeInserted', updateLayout
			wrapper.bind 'DOMNodeRemoved', updateLayout

		scrollbar_inner.bind START_EVENT, (e) =>
			move_by_bar = true
			params.noMoveMouse = false
			return true

		wrapper.bind START_EVENT, (e) =>
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		$(document).bind MOVE_EVENT, (e) =>
	#			if $(e.target).is('.j_not_scroll_by_jscroll')
	#				return
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		$(document).bind END_EVENT, (e) =>
			scrollClick e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			return true

		wrapper.on WHEEL_EV, (e) =>
	#			if $(e.target).is('.j_not_scroll_by_jscroll')
	#				return

			wheelPos = scrollWheelPos e, wrapper, scroller, scrollbar_cont, scrollbar_inner
			scrollTo wheelPos, wrapper, scroller, scrollbar_cont, scrollbar_inner
			if not wrapper.parent().hasClass("j_native_scroll_block")
				return false
			return





	}

	actionButtonHtml = '<ul class="b_button_action" data-bind="css: $data.firstActionClass">' +
		'<li class="g_first" data-bind="click: $data.doFirstAction">' +
			'<img data-bind="attr: { src: firstActionIcon }">' +
		'</li>' +
		'<li class="g_last drop_down" data-bind="click: $data.generateActionList">' +
			'<img src="/img/icons/action/drop_down.png">' +
		'</li>' +
	'</ul>'

	defaultOptions =
		position: 'right'
		dynamic: true
		animateTimout: 200
		oktell: window.oktell
		buttonCss: 'oktellActionButton'
		debug: false


	langs = {
		panel: { inTalk: 'В разговоре', onHold: 'На удержании', queue: 'Очередь ожидания', inputPlaceholder: 'введите имя или номер' },
		actions: { call: 'Позвонить', conference: 'Конференция', transfer: 'Перевести', toggle: 'Переключиться', intercom: 'Интерком', endCall: 'Завершить', ghostListen: 'Прослушка', ghostHelp: 'Помощь' }
	}


	options = null
	actionListEl = null
	actionList = null
	panel = null
	usersService = null
	oktell = null
	oktellConnected = false

	getOptions = ->
		options or defaultOptions

	################################################################
	# utils
	################################################################
	log = ->
		if not getOptions().debug
			return
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


	################################################################
	# actionList html
	################################################################
	actionListHtml = '<ul style="display: none; z-index: 999; padding: 0; font-size: 13px; font-family: Tahoma;" class="b_actions_group_list" data-bind="foreach: { data: items, as: \'a\' }">'+
		'<li data-bind="click: $parent.doActionByClick, css: { \'g_first\': a.firstClass, \'g_last\': a.lastClass }, hoverSelect: true">'+
			'<img data-bind="attr: { src: a.icon }" />'+
			'<span data-bind="text: a.text"></span>'+
		'</li>'+
	'</ul>'


	################################################################
	# ActionList
	################################################################
	class ActionList
		constructor: ( oktell ) ->

			@allItems =
				call: { icon: '/img/icons/action/call.png', iconWhite: '/img/icons/action/white/call.png', text: 'Позвонить' }
				conference : { icon: '/img/icons/action/confinvite.png', iconWhite: '/img/icons/action/white/confinvite.png', text: 'Конференция' }
				transfer : { icon: '/img/icons/action/transfer.png', text: 'Перевести' }
				toggle : { icon: '/img/icons/action/toggle.png', text: 'Переключиться' }
				intercom : { icon: '/img/icons/action/intercom.png', text: 'Интерком' }
				endCall : { icon: '/img/icons/action/endcall.png', iconWhite: '/img/icons/action/white/endcall.png', text: 'Завершить' }
				ghostListen : { icon: '/img/icons/action/ghost_monitor.png', text: 'Прослушка' }
				ghostHelp : { icon: '/img/icons/action/ghost_help.png', text: 'Помощь' }

			@allItems =
				call: { icon: '/img/icons/action/call.png', iconWhite: '/img/icons/action/white/call.png', text: @langs.call }
				conference : { icon: '/img/icons/action/confinvite.png', iconWhite: '/img/icons/action/white/confinvite.png', text: @langs.conference }
				transfer : { icon: '/img/icons/action/transfer.png', text: @langs.transfer }
				toggle : { icon: '/img/icons/action/toggle.png', text: @langs.toggle }
				intercom : { icon: '/img/icons/action/intercom.png', text: @langs.intercom }
				endCall : { icon: '/img/icons/action/endcall.png', iconWhite: '/img/icons/action/white/endcall.png', text: @langs.endCall }
				ghostListen : { icon: '/img/icons/action/ghost_monitor.png', text: @langs.ghostListen }
				ghostHelp : { icon: '/img/icons/action/ghost_help.png', text: @langs.ghostHelp }


			_.each @allItems, (v,k) =>
				v.id = k
				v.firstClass = ko.observable false
				v.lastClass = ko.observable false


			@actions = ko.observableArray []
			@target = ko.observable()


			@panelNumber = ko.observable('')

			#@isVisible = ko.observable false

			@menu = actionListEl


			timeout_id = ''

			@menu.hover =>
				clearTimeout(timeout_id);
			, =>
				timeout_id = setTimeout =>
					x = 1
					@menu.fadeOut(150)
				, 500

			@showActions = ( actions, number, ul ) =>
				#log 'actionList.showActions', actions, number, ul
				@actions actions or []
				@target number or ''
				@showList ul

			@doActionByClick = (item) =>
				@doAction item
			@doAction = (item, target) =>

				action = item.id or item
				target = target or @target()

				if not action or not target
					return

				switch action
					when 'call'
						oktell.call target
					when 'conference'
						oktell.conference target
					when 'intercom'
						oktell.intercom target
					when 'transfer'
						oktell.transfer target
					when 'toggle'
						oktell.toggle()
					when 'ghostListen'
						oktell.ghostListen target
					when 'ghostHelp'
						oktell.ghostHelp target
					when 'ghostConference'
						oktell.ghostConference target
					when 'endCall'
						oktell.endCall target

			@showList = ( ul ) =>

				width_menu = @menu.width()
				@menu.css {
						  'top': ul.offset().top,
						  'left': ul.offset().left - width_menu + ul.width()
						  'visibility': 'visible'
						  }

				@menu.fadeIn(100)

			@getItems = (actions = []) =>
				items = []
				_.each actions, (a) =>
					i = @allItems[a]
					if i
						if items.length is 0
							i.firstClass true
						i.lastClass false
						items.push i
				if items.length > 1
					_.last(items).lastClass true
				log items
				return items

			@panelItems = ko.computed =>
				number = @panelNumber()
				if not number or not oktell.getMyInfo().oktellBuild
					return []
				actions = oktell.getPhoneActions number
				@getItems actions


			@items = ko.computed =>
				acts = @actions() or []
				@getItems acts

			@panelItemsCount = ko.computed =>
				@panelItems().length

			oktell.on 'oktellConnected', =>
				@panelNumber.notifySubscribers()
				oktell.on 'stateChange', =>
					@panelNumber.notifySubscribers()

			@doPanelAction = (item) =>
				@doAction item.id, @panelNumber()

			@afterClear = =>



			return

	ActionList.prototype.langs = langs.actions

	################################################################
	# User
	################################################################
	class User
		constructor: ( data ) ->
			_.extend @, data

			if @number
				@number = @number.toString()

			if @name?
				@name = @name.toString()

			@actions = ko.observableArray []

			@hovered = ko.observable(false)

			@actionBarVisible = ko.observable false

			@showedNumber = if @number isnt @name then @number else ''


			@needLoadActions = ko.observable(true)

			@firstAction = ko.computed =>
				@actions()[0]

			@actionBarIsVisible = ko.computed =>
				@firstAction()?[0]? or @actionBarVisible()

			@firstActionIcon = ko.computed =>
				a = actionList.allItems[ @firstAction() ]
				if a
					return a.iconWhite or a.icon or ''
				''

			@firstActionClass = ko.computed =>
				a = @firstAction()
				if a then 'm_button_action_' + @firstAction().toLowerCase() else ''

			@state = ko.observable( if @isFantom then @state else ( @numberObj and @numberObj.state or 0 ) )

			@loadActions = =>
				@needLoadActions false
				@actions oktell.getPhoneActions( if @isFantom then @number else @id )

			@getActions = =>
				if @needLoadActions()
					@loadActions()
				@actions()

			@setActionsOnStateChange = ko.computed =>
				state = @state()
				if state is 0 or state is 7 or not @number
					@actions []
				else
					@loadActions()
				#log 'state change for ' + @name + ': ' + @state.peek(), @actions.peek()
				return

			@isOffline = ko.computed =>
				@state() is 0
			@isBusy = ko.computed =>
				@state() is 5

			@isFiltered = ( filter ) =>

				if not filter or typeof filter isnt 'string'
					return true

				if ( @number and @number.indexOf(filter) isnt -1 ) or ( ' ' + @name ).toLowerCase().indexOf(filter) isnt -1
					return true

				return false


			@generateActionList = ( obj, e ) =>
				log 'clicked dropdown ', obj, e
				actionList.showActions @getActions(), @number, $(e.currentTarget).closest('ul')


			@doFirstAction = =>
				if @number and @firstAction()
					actionList.doAction @firstAction(), @number

			@loadActionsOnHover = ko.computed =>
				if @hovered()
					@loadActions()

			return


	################################################################
	# UsersService
	################################################################
	class UsersService
		# find user or create fantom
		getUser: (data, dontRemember) ->
			if typeof data is 'string' or typeof data is 'number'
				strNumber = data.toString()
			else
				strNumber = data.number.toString()

			if @allUsersByNumber[strNumber]
				return @allUsersByNumber[strNumber]

			fantom = new User
				number: strNumber
				name: data.name
				isFantom: true
				state: ( if data?.state? then data.state else 5 )
				avatarLink32x32: @defaultAvatar32

			if not dontRemember
				@allUsersByNumber[strNumber] = fantom
				@fantomsByNumber[strNumber] = fantom
			fantom



		constructor: ->
			oktellConnected = false

			@me = false
			@users = ko.observableArray([])
			@fantomsByNumber = {}
			@allUsersByNumber = {}
			@usersForPanel = ko.observableArray([])
			@panelUserCount = ko.observable(999)
			@queueAbonents = ko.observableArray([])
			@userByNumber = {}
			@abonents = ko.observableArray []
			@abonentsCount = ko.computed => @abonents().length
			@holdedAbonents = ko.observableArray []
			@holdedAbonentsCount = ko.computed => @holdedAbonents().length
			@filter = ko.observable('')




			@myNumber = ''

			usersSorted = ko.computed =>
				_.sortBy @users(), (u) =>
					if u.state()
						'_________' + u.name
					else if not ( u and u.number )
						'zzzzzzzz'
					else
						u.name

			ko.computed =>
				filter = @filter().toLocaleLowerCase()
				abonents = @abonents()
				holdedAbonents = @holdedAbonents()
				panelUserCount = @panelUserCount()
				users = usersSorted()
				finded = []

				if filter

					totalMatch = @allUsersByNumber[filter]
					if totalMatch and filter isnt @myNumber
						finded.push totalMatch

#					if finded.length is 0
#						ab = _.find( abonents, (a) => a?.number? and a.number is filter )
#						if ab
#							finded.push ab
#
#					if finded.length is 0
#						h = _.find( holdedAbonents, (h) => h?.number? and h.number is filter )
#						if h
#							finded.push h

					if finded.length is 0
						cu = _.find( @allUsersByNumber, (u) => u?.number? and u.number is filter )
						if cu
							finded.push cu

					if finded.length is 0 and filter isnt @myNumber
						finded.push @getUser filter, true

					finded = finded.concat _.first( _.filter( users, (u) => u and u isnt totalMatch and u.isFiltered(filter) ), panelUserCount )

				else
					finded = _.first( users, panelUserCount )

				@usersForPanel finded

			setAbonents = (abonents) =>
				_.each abonents, (ab) =>
					if not _.find( @abonents(), (u) => u?.number? and u.number is ab.phone.toString() )
						user = @getUser(ab.phone)
						if user.isFantom
							user.state 5
						@abonents.push user
				@abonents.remove (u) =>
					user = _.find abonents, (ab) => u?.number? and u.number is ab.phone.toString()
					if user
						if user.isFantom
							user.state 1
						false
					else true

			setHold = (holdInfo) =>
				oldUser = @holdedAbonents()?[0]
				if not holdInfo.hasHold
					@holdedAbonents []
				else if holdInfo.isConference
					if @holdedAbonents()[0].conferenceId isnt holdInfo.conferenceId
						newUser = @getUser( _.extend( holdInfo, { name: holdInfo.conferenceName or 'Конференция' } ) , true )
						if newUser isnt oldUser and oldUser.isFantom
							oldUser.state 1
						@holdedAbonents [  ]
				else
					if @holdedAbonents()[0]?.number? and @holdedAbonents()[0].number.toString() isnt holdInfo.phone.toString()
						@holdedAbonents [ @getUser(holdInfo.phone) ]

			@sa = setAbonents

			setInterval =>
				if oktellConnected
					oktell.getQueue (data)=>
						if data.result
							@queueAbonents data.queue
			, if getOptions().debug then 999999999 else 5000

			oktell.on 'disconnect', =>
				oktellConnected = false

			oktell.on 'connect', =>

				oktellConnected = true

				users = []

				oktell.on 'stateChange', ( newState, oldState ) =>
					log 'Oktell stateChange', newState, oldState
					_.each @users, (u) =>
						u.needLoadActions true
						if u.hovered()
							u.loadActions()


				oktell.onNativeEvent 'pbxnumberstatechanged', (data) =>
					log 'pbxnumberstatechanged', data
					nums = []
					_.each data.numbers, (n) =>
						if @userByNumber[n.num.toString()]
							@userByNumber[n.num.toString()].state( parseInt( n.numstateid ) )

				oktell.on 'abonentsChange', ( abonents ) =>
					log 'Oktell abonentsChange', abonents
					setAbonents abonents

				oktell.on 'holdStateChange', ( holdInfo ) =>
					log 'Oktell holdStateChange', holdInfo
					setHold holdInfo

				oktellInfo = oktell.getMyInfo()

				@defaultAvatar = oktellInfo.defaultAvatar
				@defaultAvatar32 = oktellInfo.defaultAvatar32x32
				@defaultAvatar64 = oktellInfo.defaultAvatar64x64

				myId = oktellInfo.userid

				@myNumber = oktellInfo.number?.toString()

				_.each oktell.getUsers(), (u) =>
					user = new User(u)

					strNumber = u.number?.toString()

					if not user.avatarLink32x32
						user.avatarLink32x32 = @defaultAvatar32
					if u.number
						@userByNumber[strNumber] = user

					if u.id.toLowerCase() isnt myId.toLowerCase()
						users.push user
					else
						@me = user

					@allUsersByNumber[strNumber] = user

				setAbonents oktell.getAbonents()
				setHold oktell.getHoldInfo()

				@users users

				afterOktellConnect()


	################################################################
	# panel
	################################################################
	class Panel
		constructor: ->
			@actionList = actionList

			@panelNumber = actionList.panelNumber

			@usersService = usersService

			@panelNumberHasFocus = ko.observable false

			# show first action of first filtered user
			ko.computed =>
				hasFocus = @panelNumberHasFocus()
				number = @panelNumber()
				filteredUsers = usersService.usersForPanel()
				if number and hasFocus and filteredUsers.length
					filteredUsers[0]


			filterSetter = ko.computed =>
				usersService.filter @panelNumber()


			@popupVisible = ko.observable false

			input = ''
			phonePopup = ''
			phoneButtons = ''
			topchanged = false

			@afterRender = (el) =>
				@el = $(el)
				input = @el.find('input.b_phone_number_input') #$('#j_panel_number');
				#			phonePopup = input.closest(".h_phone_number_bg").parent().find('div.b_phone_popup')
				phoneButtons = input.parent().find('div.i_phone_popup_button')

				#			phonePopup.on 'click', '.b_phone_panel li a', (e) =>
				#				e.preventDefault()
				#				log actionList.panelNumber()
				#				actionList.panelNumber actionList.panelNumber() + $(e.currentTarget).text()

				#			$(".l_panel.g_hover").live "mouseleave", =>
				#				@hidePopup()

				input.keyup (e) =>
					if e.keyCode is 13
	#					phonePopup.find('.b_actions_group_list li:first').click()
	#					@hidePopup()
						usersService.usersForPanel()?[0]?.doFirstAction()
						actionList.panelNumber ''
						input.blur()



			@showPopup = (a,b) =>

				if @popupVisible()
					return

				inpitWidth = input.closest(".h_phone_number_bg").width() - 8

				phonePopup.css 'width', inpitWidth
				phonePopup.find('.b_actions_group_list').css 'visibility', 'visible'

				phonePopup.fadeIn 200
				if not topchanged
					topchanged = true
					phonePopup.offset {
									  top: phonePopup.offset().top - 33
									  }

				@popupVisible true


			@hidePopup = =>
				@popupVisible false



			$(document).on "click", (e) =>
				element = $ e.target
				if element.parents(".j_phone_popup_cloned").size() is 0 and element.parents(".h_phone_number_input").size() is 0
					@hidePopup()
			popupInited = false

	Panel.prototype.langs = langs.panel

	################################################################
	# add user template
	###############################################################
	userTemplateHtml = '<tr class="b_contact" data-bind="hoverSelect: true, actionBar: $data, css: { \'m_offline\': $data.isOffline, \'m_busy\': $data.isBusy }">' +
		'<td class="b_contact_avatar">' +
			'<img data-bind="attr: { src: $data.avatarLink32x32 }">' +
			'<div class="o_busy"></div>' +
		'</td>' +
		'<td class="b_contact_title">' +
			'<div class="wrapword">' +
				'<a><b data-bind="text: $data.name"></b><span class="o_number" data-bind="text: $data.showedNumber"></span></a>' +
			'</div>' +
			'<ul class="b_button_action" data-bind="visible: $data.actionBarIsVisible, css: $data.firstActionClass">' +
				'<li class="g_first" data-bind="click: $data.doFirstAction">' +
					'<img data-bind="attr: { src: firstActionIcon }">' +
				'</li>' +
				'<li class="g_last drop_down" data-bind="click: $data.generateActionList">' +
					'<img src="/img/icons/action/drop_down.png">' +
				'</li>' +
			'</ul>' +
		'</td>' +
	'</tr>'


	################################################################
	# panel html
	################################################################
	panelHtml = '<div class="l_panel j_panel">'+
		'<div class="i_panel_bookmark">'+
			'<div class="i_panel_bookmark_bg"></div>'+
		'</div>'+
		'<div class="h_panel_bg">'+
			'<div class="h_padding" style="height: 100%">'+
				'<div class="b_marks i_conference" data-bind="visible: usersService.abonentsCount">'+
					'<div class="b_marks_noise">'+
						'<p class="b_marks_header">'+
							'<span class="b_marks_label" data-bind="text: langs.inTalk"></span>'+
							'<span class="b_marks_time" style="display: none;">2:35</span>'+
						'</p>'+
						'<table>'+
							'<tbody data-bind="template: { name: \'oktellWebPanelUserTemplate\', foreach: usersService.abonents }"></tbody>'+
						'</table>'+
					'</div>'+
				'</div>'+
				'<div class="b_marks i_flash" data-bind="visible: usersService.holdedAbonentsCount">'+
					'<div class="b_marks_noise">'+
						'<p class="b_marks_header">'+
							'<span class="b_marks_label" data-bind="text: langs.onHold"></span>'+
							'<span class="b_marks_time">15:45</span>'+
						'</p>'+
						'<table class="j_table_favorite">'+
							'<tbody data-bind="template: { name: \'oktellWebPanelUserTemplate\', foreach: usersService.holdedAbonents }"></tbody>'+
						'</table>'+
					'</div>'+
				'</div>'+
				'<div class="b_marks i_flash" data-bind="visible: usersService.queueAbonents().length">'+
					'<div class="b_marks_noise">'+
						'<p class="b_marks_header">'+
							'<span class="b_marks_label" data-bind="text: langs.queue"></span>'+
						'</p>'+
						'<table class="j_table_queue">'+
							'<tbody data-bind="template: { name: \'oktellWebPanelUserTemplate\', foreach: usersService.queueAbonents }"></tbody>'+
						'</table>'+
					'</div>'+
				'</div>'+
				'<div class="b_inconversation j_phone_block">'+
					'<table class="j_table_phone" style="width: 100%">'+
						'<tbody></tbody>'+
					'</table>'+
				'</div>'+
				'<div class="b_marks i_phone">'+
					'<div class="h_shadow_bottom">'+
						'<div class="h_phone_number_input">'+
							'<div class="i_phone_state_bg"></div>'+
							'<div class="h_input_padding">'+
								'<div class="i_phone_popup_button">'+
									'<i></i>'+
								'</div>'+
								'<input class="b_phone_number_input" type="text" data-bind="attr: { placeholder: langs.inputPlaceholder }, hasfocus: panelNumberHasFocus, value: actionList.panelNumber, inputClear: actionList.panelNumber, valueUpdate: \'afterkeydown\'">'+
							'</div>'+
						'</div>'+
					'</div>'+
				'</div>'+
				'<div style="height: 100%; overflow: hidden;" data-bind="jScroll: true">' +
					'<table class="b_main_list">'+
						'<tbody data-bind="template: { name: \'oktellWebPanelUserTemplate\', foreach: usersService.usersForPanel }">' +
						'</tbody>'+
					'</table>' +
				'</div>'+
			'</div>'+
		'</div>'+
	'</div>';

	panelEl = $(panelHtml)

	window.p = panelEl


	popupHtml = '<div class="b_phone_keypad j_phone_keypad" style="display: none;">'+
		'<div class="l_column_group">'+
			'<div class="h_phone_keypad">'+
				'<ul class="b_phone_panel">'+
					'<li class="g_top_left g_first"><a  href="1" class="g_button m_big">1</a></li>'+
					'<li><a  href="2" class="g_button m_big">2</a></li>'+
					'<li class="g_top_right g_right"><a  href="3" class="g_button m_big">3</a></li>'+
					'<li class="g_float_celar g_first"><a  href="4" class="g_button m_big">4</a></li>'+
					'<li><a  href="5" class="g_button m_big">5</a></li>'+
					'<li class="g_right"><a  href="6" class="g_button m_big">6</a></li>'+
					'<li class="g_float_celar g_first"><a  href="7" class="g_button m_big">7</a></li>'+
					'<li><a  href="8" class="g_button m_big">8</a></li>'+
					'<li class="g_right"><a  href="9" class="g_button m_big">9</a></li>'+
					'<li class="g_bottom_left g_float_celar g_first"><a href="*" class="g_button m_big" >&lowast;</a></li>'+
					'<li class="g_bottom_center"><a  href="0" class="g_button m_big">0</a></li>'+
					'<li class="g_bottom_right g_right"><a  href="#" class="g_button m_big">#</a></li>'+
				'</ul>'+
			'</div>'+
		'</div>'+
	'</div>'


	################################################################
	# panel Dom init
	################################################################
	panelWasInitialized = false
	initPanel = (opts)->
		panelWasInitialized = true

		options = $.extend defaultOptions, opts or {}

		$('body').append '<script type="text/html" id="oktellWebPanelUserTemplate" >' + userTemplateHtml + '</script>'

		actionListEl = $(actionListHtml)
		$('body').append actionListEl

		oktell = getOptions().oktell

		panelPos = getOptions().position
		curOpt = {}

		actionList = new ActionList(oktell)
		ko.applyBindings actionList, actionListEl[0]

		usersService = new UsersService
		window.usersService = usersService

		panel = new Panel

		$("body").append(panelEl)

		panelEl.find(".h_input_padding").after popupHtml

		ko.applyBindings panel, panelEl[0]

		panel.afterRender(panelEl);

		if panelPos is "right"
			panelEl.addClass("right");
		else if panelPos is "left"
			panelEl.addClass("left");

		if getOptions().dynamic
			panelEl.addClass("dynamic");

		panelBookmarkEl = panelEl.find('.i_panel_bookmark')

		$("body").unbind 'DOMNodeInserted', onDOMchange
		$("body").unbind 'DOMNodeRemoved', onDOMchange
		$("body").bind 'DOMNodeInserted', onDOMchange
		$("body").bind 'DOMNodeRemoved', onDOMchange

		# Panel Bookmark hover
		mouseOnPanel = false
		panelHideTimer = false
		panelStatus = 'closed'

		killPanelHideTimer = ->
			clearTimeout panelHideTimer
			panelHideTimer = false


		panelEl.on "mouseenter", ->
			mouseOnPanel = true
			killPanelHideTimer()
			curOpt[panelPos]="0px"
			if parseInt(panelEl.css(panelPos)) < 0 and ( panelStatus is 'closed' or panelStatus is 'closing' )
				panelStatus = 'opening'
				panelBookmarkEl.stop(true,true)
				panelBookmarkEl.animate {left: '0px'}, 50, 'swing'
				panelEl.stop true, true
				panelEl.animate curOpt, 100, "swing", ->
					console.log("swing")
					panelEl.addClass("g_hover")
					panelStatus = 'open'

		hidePanel = ->
			if panelEl.hasClass "g_hover" #and ( panelStatus is 'open' or panelStatus is '' )
				curOpt[panelPos]="-281px";
				panelStatus = 'closing'
				panelEl.stop(true, true);
				panelEl.animate curOpt, 300, "swing", ->
					curOpt[panelPos]="0px";
					panelEl.css({panelPos: 0});
					panelEl.removeClass("g_hover");
					panelStatus = 'closed'
				setTimeout ->
				   panelBookmarkEl.animate {left: '-40px'}, 50, 'swing'
				, 150


		panelEl.on "mouseleave", ->
			mouseOnPanel = false
			true

		$('html').on 'mouseleave', (e) ->
			killPanelHideTimer()


		$('html').on 'mousemove', (e) ->
			if not mouseOnPanel and panelHideTimer is false
				log 'start timer'
				panelHideTimer = setTimeout ->
					log 'timer work'
					hidePanel()
				, 300

			return true


		if navigator.userAgent.indexOf('iPad') isnt -1

			xStartPos = 0
			xPos = 0
			element = panelEl
			elementWidth = 0
			critWidth = 0
			cssPos = -281
			walkAway = 0
			newCssPos = 0
			openClass = "j_open"
			closeClass = "j_close"


			if parseInt(element[0].style.right) < 0
				element.addClass closeClass

			element.live "click", ->
				if element.hasClass(closeClass)
					newCssPos = 0
					curOpt[panelPos] = newCssPos + "px"
					element.animate curOpt, 200, "swing", ->
						element.removeClass(closeClass).addClass openClass
						walkAway = 0

			element.live "touchstart", (e) ->
				xStartPos = e.originalEvent.touches[0].pageX
				elementWidth = element.width()
				critWidth = (elementWidth/100)*13
				cssPos = parseInt(element.css(panelPos))

			element.bind "touchmove", (e) ->
				#touchmove
				e.preventDefault()
				xPos = e.originalEvent.touches[0].pageX
				walkAway = xPos - xStartPos
				newCssPos = ( cssPos - walkAway )
				if newCssPos < -281
					newCssPos = -281
				else if newCssPos > 0
					newCssPos = 0
				#alert(walkAway);
				element[0].style.right = newCssPos + 'px'

			element.bind "touchend", (e) ->
				if walkAway >= critWidth and walkAway < 0
					newCssPos = "-281px";
					curOpt[panelPos] = newCssPos;
					element.animate curOpt, 200, "swing"

			if walkAway * -1 >= critWidth and walkAway > 0
				newCssPos = "0px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 200, "swing"


			if walkAway < critWidth and walkAway < 0
				newCssPos = "0px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 100, "swing", ->
					element.removeClass(closeClass).addClass(openClass)

			if walkAway *-1 < critWidth && walkAway > 0
				newCssPos = "-281px"
				curOpt[panelPos] = newCssPos
				element.animate curOpt, 100, "swing", ->
					element.removeClass(openClass).addClass(closeClass)


		$('.h_phone_number_input', panelEl).on 'click', ".i_phone_popup_button", (e) ->
			inputBox = $(this).parent().parent()
			showPhonePopup inputBox, e
			popupKeypad = panelEl.find(".b_phone_keypad")
			if popupKeypad.is(":visible")
				popupKeypad.slideUp(200)
			else
				popupKeypad.slideDown(200)

		$(document).on "click", (e) =>
			element = $(e.target);
			if element.parents(".j_phone_keypad", panelEl).size() is 0 and element.parents(".h_phone_number_input", panelEl).size() is 0
				$(".i_phone_number_bg_active", panelEl).removeClass("i_phone_number_bg_active", panelEl);

		$('.b_phone_keypad li a', panelEl).bind 'click', (e) ->
			e.preventDefault()
			input = panelEl.find "input.b_phone_number_input"
			input.focus()
			input.val( input.val() + $(this).attr("href") )
			input.change()


		onDOMchange = ->
			debounce ->
				$(".j_panel_actionlist").each ->
					it = $(this)
					number = it.text()
					if it.next().hasClass("b_button_action") then return
					DOMactionList =	'<ul class="b_button_action m_button_action_call">' +
						'<li class="g_first">' +
							'<img src="/img/icons/action/white/call.png">' +
						'</li>' +
						'<li class="g_last drop_down">' +
							'<img src="/img/icons/action/drop_down.png">' +
						'</li>' +
					'</ul>'
					it.after DOMactionList
			, 1000
			debounce ->
				$(".j_panel_userbusy").each ->
					it = $(this)
					if it.find(".b_user_busy_mark").size() then return
					DOMactionList = '<span class="b_user_busy_mark">&nbsp;</span>'
					it.append DOMactionList
			, 1000


	elsForInitButtonAfterConnect = []
	elsWithButton = []

	afterOktellConnect = ->
		for el in elsForInitButtonAfterConnect
			addActionButtonToEl el
		elsForInitButtonAfterConnect = []

	initBttonOnElement = (el) ->
		el.addClass(getOptions().buttonCss)
		phone = el.attr('data-phone')
		if phone
			el.html(actionButtonHtml)
			user = usersService.getUser phone
			ko.applyBindings user, el.children()[0]
		elsWithButton.push el

	addActionButtonToEl = (el) ->
		if not oktellConnected
			elsForInitButtonAfterConnect.push el
		else
			initBttonOnElement el


	initActionButtons = (selector) ->
		$(selector+":not(."+ actionButtonContainerClass + ")").each ->
			addActionButtonToEl $(this)


	$.oktellPanel = (arg) ->
		if typeof arg is 'string'
			if panelWasInitialized
				initActionButtons(arg)
		else if not panelWasInitialized
			initPanel(arg)



	$.fn.oktellButton = ->
		$(this).each ->
			addActionButtonToEl $(this)



)($, ko)