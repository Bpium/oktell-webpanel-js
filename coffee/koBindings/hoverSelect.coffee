ko.bindingHandlers.hoverSelect =
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		el = $(element)
		el.hover =>
			 el.addClass 'g_hover'
		, =>
			el.removeClass 'g_hover'
		return