class ActionList
	constructor: ( oktell, $menu ) ->

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
			v.css = ko.computed =>
				css = 'i_'+k
				if v.firstClass()
					css += ' g_first'
				if v.lastClass()
					css += ' g_last'
				css



		@actions = ko.observableArray []
		@target = ko.observable()

		@panelNumber = ko.observable('')

		#@isVisible = ko.observable false

		@menu = $menu

#		timeout_id = ''
#
#		@menu.hover =>
#			clearTimeout(timeout_id);
#		, =>
#			timeout_id = setTimeout =>
#				x = 1
#				@menu.fadeOut(150)
#			, 500

		@showActions = ( actions, number, ul ) =>
			#log 'actionList.showActions', actions, number, ul
			@actions actions or []
			@target number or ''
			@showList ul

		@doActionByClick = (item) =>
			@menu.hide()
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
			@menu.css
				'top': ul.offset().top,
				'left': ul.offset().left - width_menu + ul.width()
				'visibility': 'visible'


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
			if items.length > 0
				_.last(items).lastClass true
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
