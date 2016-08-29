
# Buttonbar groups {Button}s
class Buttonbar extends DOM

	# @param [Object] options for {Buttonbar} creation
	#   "horizontal", this is the default.
	#   "vertical"
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

		# FIXME: this needs to be removed, once the SCSS is fixed
		@DOM.addClass("cui-buttonbar-horizontal")

		if @_tooltip
			tt_opts = copyObject(@_tooltip)
			tt_opts.element = @__buttons
			@__tooltip = new Tooltip(tt_opts)

		# @DOM.addClass("cui-buttonbar-"+@_orientation)

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
		for el in @__buttons.find(".cui-button,.cui-select")
			ele = DOM.data(el, "element")
			ele[func].apply(ele, args)
		@

	disable: ->
		@__proxy("disable")

	enable: ->
		@__proxy("enable")


	# hide the group if no children
	__checkVisibility: ->
		@__buttons.css("display", "")
		for grp of @__groupDivs
			d = @__groupDivs[grp]
			count = 0
			for _c in d.children()
				c = $(_c)
				c.removeClass("cui-first-visible-child")
				el = DOM.data(_c, "element")
				if el
					count += el.isShown()
				else
					count += c.is(":visible")

				if count == 1
					c.addClass("cui-first-visible-child")

			if count > 0
				d.css("display", "")
			else
				d.css("display", "none")

		visible = 0

		# Hide the entire Buttonbar, if everything inside is hidden
		for _el in @__buttons.children(".cui-buttonbar-group,.cui-button,.cui-select")
			el = $(_el)
			el.removeClass("cui-first-visible-child")
			if el.css("display") != "none"
				visible++
				if visible == 1
					el.addClass("cui-first-visible-child")
				break

		# CUI.debug "Buttonbar.__checkVisibility", visible, @, @DOM[0]

		if visible > 0
			if @__tooltip?.isShown()
				@__tooltip.position()
		else
			@__buttons.css("display", "none")
		@

	removeButtons: ->
		DOM.empty(@__buttons)

	prependButton: (btn, check_visibility = true) ->
		@addButton(btn, check_visibility, true)

	addButton: (btn, check_visibility = true, prepend = false) ->
		if isNull(btn)
			return

		if $.isPlainObject(btn)
			btn = new CUI.defaults.class.Button(btn)

		if btn instanceof Button or btn instanceof DataFieldInput
			btn_dom = btn.DOM
			grp = btn.getGroup()
		else if btn instanceof Label
			btn_dom = btn.DOM
		else if btn?.hasClass?("cui-button")
			# FIXME: this should be not needed
			btn_dom = btn
			grp = btn.group or null
		else
			assert(false, "new #{@__cls}", "button must be instance of Button or have class \".cui-button\" but is #{getObjectClass(btn)}.", button: btn, opts: @opts, )

		Events.listen
			type: ["show", "hide"]
			node: btn
			call: (ev) =>
				@__checkVisibility()

		if prepend
			func = "prependTo"
		else
			func = "appendTo"

		if grp
			if not @__groupDivs[grp]
				@__groupDivs[grp] = $div("cui-buttonbar-group cui-buttonbar-group-#{grp}").appendTo(@__buttons)

			btn_dom[func](@__groupDivs[grp])
		else
			btn_dom[func](@__buttons)

		if check_visibility
			@__checkVisibility()
		btn
