ko.bindingHandlers.inputClear =
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