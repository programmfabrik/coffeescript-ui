
# Buttonbar groups {Button}s
class Buttonbar extends CUI.DOM

	# @param [Object] options for {Buttonbar} creation
	# @option options [Array] buttons is an array of {Button} Objects. Use thie 'group' option in {Button} to let {Buttonbar} sort the buttons into groups.
	# @option options [Object] tooltip is a list of options for creating a {Tooltip} for the {Buttonbar}.
	constructor: (@opts={}) ->
		super(@opts)

		@__box = new Template
			name: "buttonbar"

		@registerTemplate(@__box)

		#__box is the template
		#__buttons can either hold groupDivs with buttons (when they have a group specified) or buttons
		# css styles can be defined for each group, by default each group looks like one buttonbar
		@__buttons = @__box.DOM
		@__groupDivs = {}

		if @_tooltip
			tt_opts = copyObject(@_tooltip)
			tt_opts.element = @__buttons
			@__tooltip = new Tooltip(tt_opts)

		for btn, idx in @_buttons
			@addButton(btn, false)

		@__checkVisibility()

	initOpts: ->
		super()
		@addOpts
			buttons:
				mandatory: true
				default: []
				check: Array
			tooltip:
				check: "PlainObject"

	__proxy: (func, args...) ->
		for el in DOM.matchSelector(@__buttons, ".cui-button,.cui-select")
			ele = DOM.data(el, "element")
			ele[func].apply(ele, args)
		@

	disable: ->
		@__proxy("disable")

	enable: ->
		@__proxy("enable")


	# hide the group if no children
	__checkVisibility: ->
		DOM.showElement(@__buttons)

		for grp of @__groupDivs
			d = @__groupDivs[grp]
			count = 0
			for c, idx in d.children
				c.classList.remove("cui-first-visible-child")
				el = DOM.data(c, "element")

				if el
					count += el.isShown()
				else
					count += CUI.DOM.isVisible(c)

				if count == 1
					c.classList.add("cui-first-visible-child")

			if count > 0
				DOM.showElement(d)
			else
				DOM.hideElement(d)

		visible = 0

		# Hide the entire Buttonbar, if everything inside is hidden
		for el in DOM.matchSelector(@__buttons, ".cui-buttonbar-group,.cui-button,.cui-select")
			# el = $(_el)
			DOM.removeClass(el, "cui-first-visible-child")
			if DOM.isVisible(el)
				visible++
				if visible == 1
					DOM.addClass(el, "cui-first-visible-child")
				break

		# CUI.debug "Buttonbar.__checkVisibility", visible, @, @DOM[0]

		if visible > 0
			if @__tooltip?.isShown()
				@__tooltip.position()
		else
			DOM.showElement(@__buttons)
		@

	removeButtons: ->
		DOM.empty(@__buttons)

	prependButton: (btn, check_visibility = true) ->
		@addButton(btn, check_visibility, true)

	addButton: (btn, check_visibility = true, prepend = false) ->
		if isNull(btn)
			return

		if CUI.isPlainObject(btn)
			btn = new CUI.defaults.class.Button(btn)

		if btn instanceof Button or btn instanceof DataFieldInput
			btn_dom = btn.DOM
			grp = btn.getGroup()
		else if btn instanceof Label
			btn_dom = btn.DOM
		else if btn?.classList?.contains("cui-button")
			# FIXME: this should be not needed
			btn_dom = btn
			grp = btn.group or null
		else
			assert(false, "new #{@__cls}", "button must be instance of Button or have class \".cui-button\" but is #{getObjectClass(btn)}.", button: btn, opts: @opts)

		Events.listen
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
				div = $div("cui-buttonbar-group cui-buttonbar-group-#{grp}")
				DOM.append(@__buttons, div)
				@__groupDivs[grp] = div

			CUI.DOM[func](@__groupDivs[grp], btn_dom)
		else
			CUI.DOM[func](@__buttons,btn_dom)

		if check_visibility
			@__checkVisibility()
		btn
