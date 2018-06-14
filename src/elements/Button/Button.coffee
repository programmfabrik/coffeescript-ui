###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Base class for all Buttons. Yeahhhh
#
#TODO document this in class...
#	role: ui-role
#	disabled: true, false
#
#
#Button.DOM: the actual button object
#Button.disable: disable button
#Button.enable: enable button
CUI.Template.loadTemplateText(require('./Button.html'));
CUI.Template.loadTemplateText(require('./Button_ng.html'));

class CUI.Button extends CUI.DOMElement

	@defaults:
		confirm_ok: "Ok"
		confirm_icon: "question"
		confirm_cancel: "Cancel"
		confirm_title: "Confirmation"
		disabled_css_class: "cui-disabled"
		active_css_class: "cui-active"

	#Construct a new CUI.Button.
	#
	# @param [Object] options for button creation
	# @option options [String] size controls the size of the button.
	#   "mini", small button.
	#   "normal", medium size button.
	#   "big", big sized button.
	#   "bigger", bigger sized button.
	# @option options [String] appearance controls the style or appearance of the button.
	#   "flat", button has no border and inherits its background color from its parent div.
	#   "normal", standard button with border and its own background color.
	#   "link", standard button without border and a underlined text.
	#   "important", emphasized button , to show the user that the button is important.

	constructor: (@opts={}) ->

		super(@opts)

		if @_tooltip
			if @_tooltip.text or @_tooltip.content
				@__tooltipOpts = @_tooltip

		@__has_left = true
		@__has_right = true
		@__has_center = true

		tname = @getTemplateName()
		# getTemplateName, also sets has_left / has_right

		@__box = new CUI.Template
			name: tname
			map:
				left: if @__has_left then ".cui-button-left" else undefined
				center: if @__has_center then ".cui-button-center" else undefined
				visual: if CUI.__ng__ then ".cui-button-visual" else undefined
				right: if @__has_right then ".cui-button-right" else undefined

		@registerTemplate(@__box)

		@__active = null
		@__disabled = false
		@__hidden = false
		@__txt =  null

		if CUI.__ng__
			@addClass("cui-button-button")

		if CUI.util.isString(@__tooltipOpts?.text)
			@setAria("label", @__tooltipOpts?.text)
			@__hasAriaLabel = true
		else
			@__hasAriaLabel = false

		CUI.dom.setAttribute(@DOM, "tabindex", @_tabindex)

		if not @_attr?.role
			CUI.dom.setAttribute(@DOM, "role", @_role)

		if not @_left or @_left == true
			if @_icon
				CUI.util.assert(CUI.util.isUndef(@_icon_left), "new #{@__cls}", "opts.icon conflicts with opts.icon_left", opts: @opts)
				icon_left = @_icon
			else
				icon_left = @_icon_left

			if icon_left
				CUI.util.assert(not @_icon_active and not @_icon_inactive, "new CUI.Button", "opts.icon_active or opts.icon_inactive cannot be set together with opts.icon or opts.icon_left", opts: @opts)
				@setIcon(icon_left)
		else
			@append(@_left, "left")

		if not @_right
			if @_icon_right
				@setIconRight(@_icon_right)
			else if @_menu and @_icon_right != false
				@addClass("cui-button--has-caret")

				if @_menu_parent
					@setIconRight("fa-angle-right")
				else
					@setIconRight("fa-angle-down")

		else if @_right != true
			@append(@_right, "right")

		@setSize(@_size)

		if @_appearance
			@addClass("cui-button-appearance-"+@_appearance)

		if @_primary
			@addClass("cui-button--primary")

		if @_center
			@append(@_center, "center")
		else if @_text
			@setText(@_text)

		if @_disabled and (@_disabled == true or @_disabled.call(@, @))
			@disable()

		if @_hidden and (@_hidden == true or @_hidden.call(@, @))
			@hide()

		if @_active == true
			@activate(initial_activate: true)
		else if @_active == false or @_switch #switch default is active=false TODO initial_activate: true == bug!?
			@deactivate(initial_activate: true)
		else
			@__setState()

		@__radio_allow_null = @_radio_allow_null

		if @_radio
			CUI.util.assert(CUI.util.isUndef(@_switch), "new CUI.Button", "opts.switch conflicts with opts.radio.", opts: @opts)
			if @_radio == true
				@__radio = "radio--"+@getUniqueId()
			else
				@__radio = @_radio
		else if not CUI.util.isNull(@_switch)
			@__radio = "switch--"+@getUniqueId()
			@__radio_allow_null = true

		if @__radio
			CUI.util.assert(not @_attr?.radio, "new CUI.Button", "opts.radio conflicts with opts.attr.radio", opts: @opts)
			CUI.dom.setAttribute(@DOM, "radio", @__radio)

		@setGroup(@_group)

		if @_menu
			@__menu_opts = {}
			itemList_opts = {}

			# rescue options for menu and separate them
			# from itemlist
			for k, v of @_menu
				switch k
					when "onShow", "onHide"
						continue
					when "class", "backdrop", "onPosition", "placement", "placements", "pointer"
						@__menu_opts[k] = v
					else
						itemList_opts[k] = v

			if not CUI.util.isEmpty(@_class)
				if @__menu_opts.class
					@__menu_opts.class += " "+@_class
				else
					@__menu_opts.class = @_class

			if @_menu.itemList
				@__menu_opts.itemList = @_menu.itemList
			else
				@__menu_opts.itemList = itemList_opts

			@__menu_opts.element = @

			if not @__menu_opts.hasOwnProperty("use_element_width_as_min_width")
				if not @_menu_parent
					@__menu_opts.use_element_width_as_min_width = true

			@__menu_opts.onHide = =>
				@_menu.onHide?()

			@__menu_opts.onShow = =>
				@_menu.onShow?()

			if not @__menu_opts.hasOwnProperty("backdrop")
				@__menu_opts.backdrop = policy: "click-thru"

			if not @__menu_opts.backdrop.hasOwnProperty("blur") and
				@_menu_parent?.getOpt("backdrop")?.blur
					if @_menu_on_hover
						@__menu_opts.backdrop =
							policy: "click-thru"
							blur: true
					else
						@__menu_opts.backdrop.blur = true

			if @_menu_parent
				@__menu_opts.parent_menu = @_menu_parent


		CUI.Events.listen
			type: "keydown"
			node: @DOM
			capture: true
			call: (ev) =>
				if ev.hasModifierKey()
					return

				if ev.keyCode() in [13, 32]
					#space / return
					@onClickAction(ev)
					ev.stop()
					return

				if ev.keyCode() == 27
					# blur button
					@DOM.blur()
					ev.stop()
					return

				el = null

				right = =>
					el = CUI.dom.findNextVisibleElement(@DOM, "[tabindex]")

				left = =>
					el = CUI.dom.findPreviousVisibleElement(@DOM, "[tabindex]")

				switch ev.keyCode()
					when 39 # right cursor
						right()
					when 40 # down cursor
						right()
					when 37 # left cursor
						left()
					when 38 # up cursor
						left()

				if el
					el.focus()
					ev.stop()

				return

		CUI.Events.listen
			type: CUI.Button.clickTypesPrevent[@_click_type]
			node: @DOM
			call: (ev) =>
				ev.preventDefault()
				# ev.stopPropagation()
				return

		CUI.Events.listen
			type: CUI.Button.clickTypes[@_click_type]
			node: @DOM
			call: (ev) =>

				if CUI.globalDrag
					# ev.stop()
					return

				if ev.getButton() != 0 and not ev.getType().startsWith("touch")
					# ev.stop()
					return

				ev.stopPropagation()
				@onClickAction(ev)
				return

		if @_menu_on_hover
			CUI.Button.menu_timeout = null

			menu_stop_hide = =>
				if not CUI.Button.menu_timeout
					return

				CUI.clearTimeout(CUI.Button.menu_timeout)
				CUI.Button.menu_timeout = null

			menu_start_hide = (ev, ms=700) =>
				menu_stop_hide()
				# we set a timeout, if during the time
				# the focus enters the menu, we cancel the timeout
				CUI.Button.menu_timeout = CUI.setTimeout
					ms: ms
					call: =>
						@getMenu().hide(ev)

		if @_menu_on_hover or @__tooltipOpts or @_onMouseenter
			CUI.Events.listen
				type: "mouseenter"
				node: @DOM
				call: (ev) =>

					if CUI.globalDrag
						return

					@_onMouseenter?(ev)
					if ev.isImmediatePropagationStopped()
						return

					if @__tooltipOpts
						@__initTooltip()
						@getTooltip().showTimeout(null, ev)

					if @_menu_on_hover
						menu = @getMenu()
						menu_stop_hide()

						if not @__disabled and menu.hasItems(ev)

							menu_shown = CUI.dom.data(CUI.dom.find(".cui-button--hover-menu")[0], "element")
							if menu_shown and menu_shown != menu
								menu_shown.hide(ev)

							CUI.dom.addClass(menu.DOM, "cui-button--hover-menu")

							CUI.Events.ignore
								instance: @
								node: menu

							CUI.Events.listen
								type: "mouseenter"
								node: menu
								instance: @
								only_once: true
								call: =>
									menu_stop_hide()

							CUI.Events.listen
								type: "mouseleave"
								node: menu
								instance: @
								only_once: true
								call: =>
									menu_start_hide(ev)

							menu.show(ev)

					return

		CUI.Events.listen
			type: "mouseleave"
			node: @DOM
			call: (ev) =>
				# @__prevent_btn_click = false

				if CUI.globalDrag
					return

				@_onMouseleave?(ev)

				@getTooltip()?.hideTimeout(ev)

				if @_menu_on_hover
					menu_start_hide(ev, 100)

				return

	setSize: (size) ->

		remove = []
		for cls in @DOM.classList
			if cls.startsWith("cui-button-size")
				remove.push(cls)

		for cls in remove
			@DOM.classList.remove(cls)

		if size
			@DOM.classList.add("cui-button-size-"+size)
		@

	onClickAction: (ev) ->
		if @__disabled # or ev.button != 0
			ev.preventDefault()
			return

		@getTooltip()?.hide(ev)

		if @__radio
			if @__radio_allow_null
				@toggle({}, ev)
			else
				@activate({}, ev)

		if @hasMenu() and
			# not (ev.ctrlKey or ev.shiftKey or ev.altKey or ev.metaKey) and
			not @_menu_on_hover and
			@getMenu().hasItems(ev)

				@getMenu().show(ev)

				# in some contexts (like FileUploadButton), this
				# is necessary, so we stop the file upload
				# to open
				#
				ev.preventDefault()
				return

		if ev.isImmediatePropagationStopped()
			return

		CUI.Events.trigger
			type: "cui-button-click"
			node: @
			info:
				event: ev

		if ev.isImmediatePropagationStopped() or not @_onClick
			return

		@_onClick.call(@, ev, @)

	initOpts: ->
		super()
		@addOpts
			tabindex:
				default: 0
				check: (v) ->
					CUI.util.isInteger(v) or v == false
			size:
				check: ["mini","normal","big","bigger"]
			appearance:
				check: ["link","flat","normal","important","transparent-border"]
			primary:
				mandatory: true
				default: false
				check: Boolean
			onClick:
				check: Function
			click_type:
				default: "click" # "touchend"
				mandatory: true
				check: (v) ->
					!!CUI.Button.clickTypes[v]

			text:
				check: String
			tooltip:
				check: "PlainObject"
			disabled:
				default: false
				check: (v) ->
					CUI.util.isBoolean(v) or CUI.util.isFunction(v)
			active_css_class:
				default: CUI.defaults.class.Button.defaults.active_css_class
				check: String
			left:
				check: (v) ->
					if v == true
						return true

					(CUI.util.isElement(v) or
						v instanceof CUI.Element or
						CUI.util.isString(v)) and
						not @_icon and
						not @_icon_left and
						not @_icon_active and
						not @_icon_inactive
			right:
				check: (v) ->
					(v == true or CUI.util.isContent(v)) and not @_icon_right
			center:
				check: (v) ->
					CUI.util.isContent(v) or CUI.util.isString(v)
			icon:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			icon_left:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			icon_right:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v) or v == false
			icon_active:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			icon_inactive:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			text_active:
				check: String
			text_inactive:
				check: String
			value: {}
			name:
				check: String
			hidden:
				check: (v) ->
					CUI.util.isBoolean(v) or CUI.util.isFunction(v)
			menu:
				check: "PlainObject"
			menu_on_hover:
				check: Boolean
			menu_parent:
				check: CUI.Menu
			onActivate:
				check: Function
			onDeactivate:
				check: Function
			onMouseenter:
				check: Function
			onMouseleave:
				check: Function

			# if set, this button belongs
			# to a group of buttons
			# on click, the active state of
			# this button will be set and unset
			# on the others
			radio:
				check: (v) ->
					CUI.util.isString(v) or v == true
			# whether to allow de-select
			# on radio buttons
			radio_allow_null:
				check: Boolean
			switch:
				check: Boolean
			active:
				check: Boolean
			# set to false to skip running onActivate and onDeactivate
			# callbacks on initial activate/deactivate when the button is
			# created
			activate_initial:
				default: true
				check: Boolean
			#group can be used for buttonbars to specify a group css style
			group:
				check: String
			role:
				default: "button"
				mandatory: true
				check: String

	# return icon for string
	__getIcon: (icon) ->
		if not icon
			null
		else if icon instanceof CUI.Icon
			icon
		else
			new CUI.Icon(icon: icon)

	readOpts: ->

		if @opts.switch
			CUI.util.assert(CUI.util.isUndef(@opts.radio_allow_null), "new CUI.Button", "opts.switch cannot be used together with opts.radio_allow_null", opts: @opts)

		super()

		if @_left
			CUI.util.assert(@_left == true or not (@_icon_active or @_icon_inactive or @_icon), "new CUI.Button", "opts.left != true cannot be used togeter with opts.icon*", opts: @opts)


	getCenter: ->
		return @__box.map.center;

	__getTemplateName: ->
		if @_icon or @_icon_left or @_icon_active or @_icon_inactive or @_left
			@__has_left = true
		else
			@__has_left = false

		if @_icon_right or (@_menu and @_icon_right != false) or @_right
			@__has_right = true
		else
			@__has_right = false

		if @__has_left and
			CUI.util.isUndef(@_text) and
			CUI.util.isUndef(@_center) and
			CUI.util.isUndef(@_text_active) and
			CUI.util.isUndef(@_text_inactive) and
			CUI.__ng__
				@__has_center = false

		if @__has_left and @__has_right
			return "button"
		else if @__has_left
			if @__has_center
				return "button-left-center"
			else
				return "button-left"
		else if @__has_right
			return "button-center-right"
		else
			return "button-center"

	getTemplateName: ->
		if CUI.__ng__
			@__getTemplateName() + "-ng"
		else
			@__getTemplateName()

	getValue: ->
		@_value

	getElementForLayer: ->
		return @__box.map.visual

	getRadioButtons: ->
		if not @__radio
			return []
		@__getButtons("radio", @__radio)

	getGroupButtons: ->
		if not @getGroup()
			return []
		@__getButtons("button-group", @getGroup())

	# returns other buttons
	__getButtons: (key, value) ->
		parents = CUI.dom.parents(@DOM, ".cui-buttonbar,.cui-form-table,.cui-item-list-body,.cui-layer")

		if parents.length == 0
			# buttons are not grouped by anything, so we
			# have no other buttons, so we use the top level element
			parents = CUI.dom.parents(@DOM)

		if parents.length > 0
			docElem = parents[parents.length-1]
		else
			return []

		(CUI.dom.data(c, "element") for c in CUI.dom.matchSelector(docElem, ".cui-button[#{key}=\"#{value}\"]"))


	hasMenu: ->
		!!@__menu_opts

	hasLeft: ->
		@__has_left

	getMenu: ->
		if not @hasMenu()
			return

		if @__menu
			@__menu
		else
			@__menu = new CUI.Menu(@__menu_opts)

	menuSetActiveIdx: (idx) ->
		if @__menu
			@__menu.setActiveIdx(idx)
		else
			@__menu_opts.itemList.active_item_idx = idx
		@

	getMenuRootButton: ->
		if @_menu_parent
			return @_menu_parent.getButton()?.getMenuRootButton()
		else if @hasMenu()
			return @
		else
			null

	#TODO rename to toggleActiveState
	toggle: (flags={}, event) ->
		@setActive(not @__active, flags, event)

	setActive: (active, flags={}, event) ->
		if active
			@activate(flags, event)
		else
			@deactivate(flags, event)

	__callOnGroup: (call, flags, event) ->

		group = @getGroup()
		if not group or not event?.ctrlKey() or flags.ignore_ctrl
			return

		flags.ignore_ctrl = true
		if not event.altKey()
			started = true
		else
			started = false

		for btn in @getGroupButtons()
			if btn == @
				started = true
				continue
			if not started
				continue
			btn[call](flags, event)
		return

	activate: (flags={}, event) ->
		# console.error "activate", flags, @getUniqueId(), @__active, @_activate_initial

		activate = =>
			@addClass(@_active_css_class)
			@setAria("pressed", true)
			@__setState()
			@__callOnGroup("activate", flags, event)
			return

		if @_activate_initial == false and flags.initial_activate
			@__active = true
			activate()
			return @

		if @__active == true and CUI.util.isEmptyObject(flags)
			return @

		if @__radio
			for btn, idx in @getRadioButtons()
				if btn == @ or not btn.isActive()
					continue

				btn.deactivate(prior_activate: true, initial_activate: flags.initial_activate)

		@__active = true
		ret = @_onActivate?(@, flags, event)
		if CUI.util.isPromise(ret)
			ret.done(activate).fail =>
				@__active = false
			return ret

		activate()
		@


	deactivate: (flags={}, event) ->
		# console.error "deactivate", flags, @getUniqueId(), @__active, @_activate_initial, @_icon_inactive

		deactivate = =>
			@removeClass(@_active_css_class)
			@setAria("pressed", false)
			@__setState()
			@__callOnGroup("deactivate", flags, event)
			return

		if @_activate_initial == false and flags.initial_activate
			@__active = false
			deactivate()
			return @

		if @__active == false and CUI.util.isEmptyObject(flags)
			return @

		@__active = false
		ret = @_onDeactivate?(@, flags, event)
		if CUI.util.isPromise(ret)
			ret.done(deactivate).fail =>
				@__active = true
			return ret

		deactivate()
		@

	setIconRight: (icon=null) ->
		@setIcon(icon, "right")

	setIcon: (icon=null, _key="left") ->
		key = "__icon_"+_key

		if icon == ""
			@[key] = ""
		else
			@[key] = @__getIcon(icon)

		CUI.util.assert(@[key] == null or @[key] == "" or @[key] instanceof CUI.Icon, "CUI.Button.setIcon", "icon needs to be instance of Icon", icon: icon)

		if @[key] == null
			@empty(_key)
		else if @[key] == ""
			@replace(CUI.dom.element("SPAN"), _key)
		else
			@replace(@[key], _key)
		@

	startSpinner: ->
		CUI.util.assert(@__has_left, "CUI.Button.startSpinner", "No space for Icon found, make sure the Button was created with opts.left set.", opts: @opts)
		if @__hasSpinner
			return

		@__iconBeforeSpinner = @getIcon()
		@__hasSpinner = true
		@setIcon("spinner")
		@

	stopSpinner: ->
		@setIcon(@__iconBeforeSpinner)
		@__hasSpinner = false
		@__iconBeforeSpinner = null
		@

	getIcon: ->
		@__icon_left

	getIconRight: ->
		@__icon_right

	__setState: ->
		@__setIconState()
		@__setTextState()

	__setIconState: ->
		if not (@_icon_active or @_icon_inactive)
			return @

		if @isActive()
			if not @_icon_active
				@setIcon("")
			else
				@setIcon(@_icon_active)
		else
			if not @_icon_inactive
				@setIcon("")
			else
				@setIcon(@_icon_inactive)
		@

	__setTextState: ->
		if not (@_text_active or @_text_inactive)
			return @

		if @isActive()
			if not CUI.util.isNull(@_text_active)
				@setText(@_text_active)
		else
			if not CUI.util.isNull(@_text_inactive)
				@setText(@_text_inactive)
		@


	isActive: ->
		!!@__active

	isDisabled: ->
		@__disabled

	isEnabled: ->
		not @__disabled

	setEnabled: (enabled) ->
		if enabled
			@enable()
		else
			@disable()

	disable: ->
		CUI.dom.addClass(@DOM, CUI.defaults.class.Button.defaults.disabled_css_class)
		CUI.dom.removeAttribute(@DOM, "tabindex")
		@__disabled = true
		@

	enable: ->
		CUI.dom.removeClass(@DOM, CUI.defaults.class.Button.defaults.disabled_css_class)
		CUI.dom.setAttribute(@DOM, "tabindex", @_tabindex)
		@__disabled = false
		@

	setText: (@__txt) ->
		if CUI.util.isEmpty(@__txt)
			@__txt = ''

		span = CUI.dom.text(@__txt)
		if not @__hasAriaLabel
			span.id = "button-text-"+@getUniqueId()
			@setAria("labelledby", span.id)
		@replace(span, "center")

	setTextMaxChars: (max_chars) ->
		CUI.dom.setAttribute(@getCenter().firstChild, "data-max-chars", max_chars)

	getText: ->
		@__txt

	getGroup: ->
		@__group

	setGroup: (@__group) ->
		if @__group
			CUI.dom.setAttribute(@DOM, "button-group", @__group)
		else
			CUI.dom.removeAttribute(@DOM, "button-group")

	__initTooltip: ->
		if @__tooltip
			return @

		tt_opts = CUI.util.copyObject(@__tooltipOpts)

		tt_opts.element ?= @DOM

		# make sure the tooltip does not register any listeners
		for k in ["on_hover", "on_click"]
			CUI.util.assert(not tt_opts.hasOwnProperty(k), "CUI.Button.__initTooltip", "opts.tooltip cannot contain #{k}.", opts: @opts)
			tt_opts[k] = false

		@__tooltip = new CUI.Tooltip(tt_opts)
		@

	getTooltip: ->
		@__tooltip

	isShown: ->
		not @isHidden()

	isHidden: ->
		@__hidden

	destroy: ->
		# console.debug "destroying button", @__uniqueId, @getText()
		@__menu?.destroy()
		@__menu = null
		@__tooltip?.destroy()
		@__tooltip = null
		super()

	show: ->
		@__hidden = false
		CUI.dom.removeClass(@DOM, "cui-button-hidden")
		CUI.dom.showElement(@DOM)
		CUI.Events.trigger
			type: "show"
			node: @DOM

	hide: ->
		@__hidden = true
		CUI.dom.addClass(@DOM, "cui-button-hidden")
		CUI.dom.hideElement(@DOM)
		CUI.Events.trigger
			type: "hide"
			node: @DOM

	@clickTypes:
		click: ['click']
		mouseup: ['mouseup']
		dblclick: ['dblclick']

	@clickTypesPrevent:
		click: ['dblclick', 'mousedown']
		mouseup: ['mouseup', 'mousedown']
		dblclick: ['click', 'mousedown']

CUI.defaults.class.Button = CUI.Button

CUI.Events.registerEvent
	type: ["show", "hide", "cui-button-click"]
	bubble: true
