###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class WaitBlock extends Block
	constructor: (@opts={}) ->
		super(@opts)
		if @_inactive
			@DOM.addClass("cui-wait-block-inactive")

		if @_fullscreen
			@DOM.addClass("cui-wait-block-fullscreen")

	initOpts: ->
		super()
		@mergeOpt "icon",
			check: (v) ->
				v instanceof Icon or isString(v)

		@removeOpt("header")
		@removeOpt("content")

		@addOpts
			# inactive is used to block content
			# from being accessed
			inactive:
				check: Boolean
			element:
				check: (v) ->
					isElement(v) or isElement(v.DOM)
			# use to put this wait block fullscreen
			fullscreen:
				check: Boolean

	readOpts: ->
		super()
		assert(xor(@_element, @_fullscreen), "new WaitBlock", "opts.element or opt.fullscreen needs to be set.", opts: @opts)

		if @_fullscreen
			@__element = $(document.body)
		else if @_element.DOM
			@__element = @_element.DOM
		else
			@__element = @_element

		if not @_inactive and not @opts.hasOwnProperty("icon")
			@_icon = "spinner"

		@__shown = false
		@__savedPosition = null
		@

	getTemplateName: ->
		"wait-block"

	show: ->
		position = @__element[0].style.position
		if not DOM.isPositioned(@__element[0])
			@__savedPosition = @__element[0].style.position
			@__element[0].style.position = "relative"
		else
			@__savedPosition = null

		@__element.addClass("cui-wait-block-active")
		if @_fullscreen
			@DOM.appendTo(@__element)
		else
			@__element.append(@DOM)
		@__shown = true
		@

	isShown: ->
		!!@__shown

	hide: ->
		if not @isShown()
			return @
		@DOM.detach()
		if @__savedPosition != null
			@__element[0].style.position = @__savedPosition

		@__element.removeClass("cui-wait-block-active")
		@__shown = false
		@__savedPosition = null
		@

	destroy: ->
		@hide()
		super()
