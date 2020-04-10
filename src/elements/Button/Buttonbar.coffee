###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Buttonbar.html'));

# Buttonbar groups {Button}s
class CUI.Buttonbar extends CUI.DOMElement

	# @param [Object] options for {Buttonbar} creation
	# @option options [Array] buttons is an array of {Button} Objects. Use thie 'group' option in {Button} to let {Buttonbar} sort the buttons into groups.
	# @option options [Object] tooltip is a list of options for creating a {Tooltip} for the {Buttonbar}.
	constructor: (opts) ->
		super(opts)

		@__box = new CUI.Template
			name: "buttonbar"

		@registerTemplate(@__box)

		#__box is the template
		#__buttons can either hold groupDivs with buttons (when they have a group specified) or buttons
		# css styles can be defined for each group, by default each group looks like one buttonbar
		@__buttons = @__box.DOM
		@__groupDivs = {}

		if @_tooltip
			tt_opts = CUI.util.copyObject(@_tooltip)
			tt_opts.element = @__buttons
			@__tooltip = new CUI.Tooltip(tt_opts)

		for btn, idx in @_buttons
			@addButton(btn, false)

		# legacy, do not use
		if @_size
			@addClass("cui-buttonbar--size-"+@_size)

		@__checkVisibility()

	initOpts: ->
		super()
		@addOpts
			size:
				check: ["big"]
			buttons:
				mandatory: true
				default: []
				check: Array
			tooltip:
				check: "PlainObject"

	__proxy: (func, args...) ->
		for el in CUI.dom.matchSelector(@__buttons, ".cui-button,.cui-select")
			ele = CUI.dom.data(el, "element")
			ele[func].apply(ele, args)
		@

	disable: ->
		@__proxy("disable")

	enable: ->
		@__proxy("enable")

	# sets classes on all children of "el"
	# returns the number of visible children
	__setVisibilityClasses: (el) =>
		count = 0
		last_visible_child = null
		for c, idx in el.children
			c.classList.remove("cui-first-visible-child")
			c.classList.remove("cui-last-visible-child")

			if CUI.dom.data(c, 'element')?.isHidden?() or not CUI.dom.isVisible(c)
				continue

			count++
			last_visible_child = c
			if count == 1
				c.classList.add("cui-first-visible-child")

		if last_visible_child
			last_visible_child.classList.add("cui-last-visible-child")

		count


	# hide the group if no children
	__checkVisibility: ->
		CUI.dom.showElement(@__buttons)

		for grp of @__groupDivs
			d = @__groupDivs[grp]

			if @__setVisibilityClasses(d) > 0
				CUI.dom.showElement(d)
			else
				CUI.dom.hideElement(d)

		if @__setVisibilityClasses(@__buttons) > 0
			if @__tooltip?.isShown()
				@__tooltip.position()
		else
			CUI.dom.showElement(@__buttons)
		@

	removeButtons: ->
		CUI.dom.empty(@__buttons)

	prependButton: (btn, check_visibility = true) ->
		@addButton(btn, check_visibility, true)

	addButton: (btn, check_visibility = true, prepend = false) ->
		if CUI.util.isNull(btn)
			return

		if CUI.util.isPlainObject(btn)
			btn = new CUI.defaults.class.Button(btn)

		if btn instanceof CUI.Button or btn instanceof CUI.DataFieldInput
			btn_dom = btn.DOM
			grp = btn.getGroup()
		else if btn instanceof CUI.Label
			btn_dom = btn.DOM
			grp = btn.getGroup()
		else if btn?.classList?.contains("cui-button")
			# FIXME: this should be not needed
			btn_dom = btn
			grp = btn.group or null
		else
			CUI.util.assert(false, "new #{@__cls}", "button must be instance of Button or have class \".cui-button\" but is #{CUI.util.getObjectClass(btn)}.", button: btn, opts: @opts)

		CUI.Events.listen
			type: ["show", "hide"]
			node: btn
			call: (ev) =>
				@__checkVisibility()

		if prepend
			func = "prepend"
		else
			func = "append"

		if grp
			if not @__groupDivs[grp]
				div = CUI.dom.div("cui-buttonbar-group cui-buttonbar-group-#{grp}")
				CUI.dom.append(@__buttons, div)
				@__groupDivs[grp] = div

			CUI.dom[func](@__groupDivs[grp], btn_dom)
		else
			CUI.dom[func](@__buttons,btn_dom)

		if check_visibility
			@__checkVisibility()
		btn
