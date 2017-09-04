###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./WaitBlock.html'));

class CUI.WaitBlock extends CUI.Block
	constructor: (@opts={}) ->
		super(@opts)
		if @_inactive
			CUI.DOM.addClass(@DOM, "cui-wait-block-inactive")

		if @_fullscreen
			CUI.DOM.addClass(@DOM, "cui-wait-block-fullscreen")

	initOpts: ->
		super()
		@mergeOpt "icon",
			check: (v) ->
				v instanceof CUI.Icon or CUI.util.isString(v)

		@removeOpt("header")
		@removeOpt("content")

		@addOpts
# inactive is used to block content
# from being accessed
			inactive:
				check: Boolean
			element:
				check: (v) ->
					CUI.util.isElement(v) or CUI.util.isElement(v.DOM)
# use to put this wait block fullscreen
			fullscreen:
				check: Boolean

	readOpts: ->
		super()
		CUI.util.assert(CUI.util.xor(@_element, @_fullscreen), "new CUI.WaitBlock", "opts.element or opt.fullscreen needs to be set.", opts: @opts)

		if @_fullscreen
			@__element = document.body
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
		if not CUI.DOM.isPositioned(@__element)
			@__savedPosition = CUI.DOM.getComputedStyle(@__element)["position"]
			CUI.DOM.setStyleOne(@__element, "position", "relative")
		else
			@__savedPosition = null

		CUI.DOM.addClass(@__element.DOM, "cui-wait-block-active")
		if @_fullscreen
			CUI.DOM.append(@__element, @DOM)
		else
			CUI.DOM.append(@__element, @DOM)
		@__shown = true
		@

	isShown: ->
		!!@__shown

	hide: ->
		if not @isShown()
			return @
		CUI.DOM.remove(@DOM)
		if @__savedPosition != null
			CUI.DOM.setStyleOne(@__element, "position", @__savedPosition)

		CUI.DOM.removeClass(@__element, "cui-wait-block-active")
		@__shown = false
		@__savedPosition = null
		@

	destroy: ->
		@hide()
		super()
