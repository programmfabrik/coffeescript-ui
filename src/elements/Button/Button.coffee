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
class Button extends DOM

	@defaults:
		confirm_ok: "Ok"
		confirm_icon: "question"
		confirm_cancel: "Cancel"
		confirm_title: "Confirmation"
		pressed_css_class: "cui-pressed"
		disabled_css_class: "cui-disabled"
		active_css_class: "cui-active"
		menu_open_css_class: "cui-menu-open"

	#Construct a new Button.
	#
	# @param [Object] options for button creation
	# @option options [String] size controls the size of the button.
	#   "auto", the button is automatically formatted. e.g. when a button is in the lower right corner of a ConfirmationDialog it shown as big button.  this is the default.
	#   "mini", small button.
	#   "normal", medium size button.
	#   "big", big sized button.
	# @option options [String] appearance controls the style or appearance of the button.
	#   "auto", the button is automatically formatted. this is the default
	#   "flat", button has no border and inherits its background color from its parent div.
	#   "normal", standard button with border and its own background color.
	#   "link", standard button without border and a underlined text.
	#   "important", emphasized button , to show the user that the button is important.

	constructor: (@opts={}) ->

		super(@opts)

		tname = @getTemplateName()
		# getTemplateName, also sets has_left / has_right

		@__box = new Template
			name: tname
			map:
				left: if @__has_left then ".cui-button-left" else undefined
				center: ".cui-button-center"
				right: if @__has_right then ".cui-button-right" else undefined


		@registerTemplate(@__box)

		@__active = null
		@__disabled = false
		@__hidden = false
		@__txt =  null

		#TODO role was misused to set css_styles, now we use it in the right ARIA-way.
		#for compatibility we map the rules to styles now
		#remove this code when roles are removed from ez5
		if @_role == "minor"
			@_size = "mini"
		else if @_role == "menu-item"
			@DOM.addClass("cui-menu-item")

		DOM.setAttributeMap(@DOM[0], @_attr)
		DOM.setAttribute(@DOM[0], "tabindex", "0")

		if not @_attr?.role
			DOM.setAttribute(@DOM[0], "role", @_role)

		#add this to make sure our base css classes are in. e.g. ButtonHRef
		@DOM.addClass("cui-button") #seems unnecessary

		if not @_left or @_left == true
			if @_icon
				assert(isUndef(@_icon_left), "new #{@__cls}", "opts.icon conflicts with opts.icon_left", opts: @opts)
				icon_left = @_icon
			else
				icon_left = @_icon_left

			if icon_left
				assert(not @_icon_active and not @_icon_inactive, "new Button", "opts.icon_active or opts.icon_inactive cannot be set together with opts.icon or opts.icon_left", opts: @opts)
				@setIcon(icon_left)
		else
			@append(@_left, "left")

		if not @_right
			if @_icon_right
				icon_right = @__getIcon(@_icon_right)
			else if @_menu and @_icon_right != false
				if @_menu_parent
					icon_right = new Icon(class: "fa-angle-right")
				else
					icon_right = new Icon(class: "fa-angle-down")

			if icon_right
				@append(icon_right, "right")
		else if @_right != true
			@append(@_right, "right")

		if not icon_right and not icon_left and isUndef(@_text) and
			not @_icon_active and not @_icon_inactive
				text = @__cls
		else
			text = @_text

		assert(@_size)
		if @_size == "auto"
			@DOM.addClass("cui-button-size-normal") #additionally used as a fallback
		@DOM.addClass("cui-button-size-"+@_size)

		assert(@_appearance)
		if @_appearance == "auto"
			@DOM.addClass("cui-button-appearance-normal") #additionally used as a fallback
		@DOM.addClass("cui-button-appearance-"+@_appearance)

		if @_center
			@append(@_center, "center")
		else
			@setText(text)

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
			assert(isUndef(@_switch), "new Button", "opts.switch conflicts with opts.radio.", opts: @opts)
			if @_radio == true
				@__radio = "radio--#{@__uniqueId}"
			else
				@__radio = @_radio
		else if not isNull(@_switch)
			@__radio = "switch--#{@__uniqueId}"
			@__radio_allow_null = true

		if @__radio
			assert(not @_attr?.radio, "new Button", "opts.radio conflicts with opts.attr.radio", opts: @opts)
			DOM.setAttribute(@DOM[0], "radio", @__radio)

		@setGroup(@_group)

		if @_menu
			@__menu_opts = {}
			itemList_opts = {}

			# rescue options for menu and separate them
			# from itemlist
			for k, v of @_menu
				if k in [
					"onShow"
					"onHide"
					"class"
					"backdrop"
				]
					@__menu_opts[k] = v
				else
					itemList_opts[k] = v

			if not isEmpty(@_class)
				if @__menu_opts.class
					@__menu_opts.class += " "+@_class
				else
					@__menu_opts.class = @_class

			@__menu_opts.itemList = itemList_opts

			@__menu_opts.element = @

			if not @__menu_opts.hasOwnProperty("use_element_width_as_min_width")
				#submenus should always have the size of their parentmenus
				if @_menu_parent
					@__menu_opts.use_element_width_as_min_width = true

			@__menu_opts.onHide = =>
				@DOM.removeClass(CUI.defaults.class.Button.defaults.menu_open_css_class)
				@_menu.onHide?()

			@__menu_opts.onShow = =>
				@DOM.addClass(CUI.defaults.class.Button.defaults.menu_open_css_class)
				@_menu.onShow?()

			if not @__menu_opts.hasOwnProperty("backdrop")
				if @_menu_on_hover
					@__menu_opts.backdrop = false
				else
					@__menu_opts.backdrop = policy: "click"

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


		@__prevent_btn_click = false

		Events.listen
			type: "mouseisdown"
			node: @DOM
			call: (ev) =>

				if window.globalDrag?.dragStarted
					@__prevent_btn_click = true
					return

				if @_onMouseisdown
					@_onMouseisdown(ev, @)
					# this callback might prevent the event
					if ev.isDefaultPrevented()
						CUI.debug "preventing click..."
						@__prevent_btn_click = true
				ev.stopPropagation()

		Events.listen
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
					@DOM[0].blur()
					ev.stop()
					return

				el = null

				right = =>
					el = DOM.findNextVisibleElement(@DOM[0], "[tabindex]")

				left = =>
					el = DOM.findPreviousVisibleElement(@DOM[0], "[tabindex]")

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

		Events.listen
			type: "mousedown"
			node: @DOM
			call: (ev) =>
				@__prevent_btn_click = false

				# don't focus element
				ev.preventDefault()

				if window.globalDrag
					return

				if not @__disabled
					@DOM.addClass(CUI.defaults.class.Button.defaults.pressed_css_class)

				ev.stopPropagation()
				return

		Events.listen
			type: ["mouseup", "click", "dblclick"]
			node: @DOM
			call: (ev) =>

				if ev.getType() != @_click_type
					# click type can be changed after
					# button is created, so we
					# need to check if the
					# event is the desired one
					ev.stopPropagation()
					return

				# console.debug @_click_type, ev, ev.getButton(), @__prevent_btn_click
				if window.globalDrag
					ev.stop()
					return

				if ev.getButton() != 0
					ev.stop()
					return

				@DOM.removeClass(CUI.defaults.class.Button.defaults.pressed_css_class)

				if @__prevent_btn_click
					ev.stop()
					@__prevent_btn_click = false
					return

				ev.stopPropagation()
				@onClickAction(ev)
				return

		if @_menu_on_hover
			menu = @getMenu()
			Button.menu_timeout = null
			Button.menu_shown = null

			menu_stop_hide = =>
				if not Button.menu_timeout
					return

				CUI.clearTimeout(Button.menu_timeout)
				Button.menu_timeout = null

			menu_start_hide = (ev) =>
				# we set a timeout, if during the time
				# the focus enters the menu, we cancel the timeout
				Button.menu_timeout = CUI.setTimeout
					ms: 700
					call: =>
						menu.hide(ev)


		if @_menu_on_hover or @_tooltip
			Events.listen
				type: "mouseenter"
				node: @DOM
				call: (ev) =>
					if window.globalDrag
						return

					if @_tooltip
						@__initTooltip()
						@getTooltip().showTimeout(null, ev)

					if @_menu_on_hover
						menu_stop_hide()

						if not @__disabled and menu.hasItems()

							if Button.menu_shown and Button.menu_shown != menu
								menu_stop_hide()
								Button.menu_shown.hide(ev)

							menu.show(null, ev)

							Button.menu_shown = menu

							Events.ignore
								instance: @
								node: menu

							Events.listen
								type: "mouseenter"
								node: menu
								instance: @
								only_once: true
								call: =>
									menu_stop_hide()

							Events.listen
								type: "mouseleave"
								node: menu
								instance: @
								only_once: true
								call: =>
									menu.hide(ev)

					return

		Events.listen
			type: "mouseleave"
			node: @DOM
			call: (ev) =>
				@__prevent_btn_click = false

				if window.globalDrag
					return

				@DOM.removeClass(CUI.defaults.class.Button.defaults.pressed_css_class)

				@getTooltip()?.hideTimeout(ev)

				if @_menu_on_hover
					menu_start_hide(ev)
				return


	onClickAction: (ev) ->
		if @__disabled # or ev.button != 0
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
			@getMenu().hasItems()
				@getMenu().show(null, ev)

				# in some contexts (like FileUploadButton), this
				# is necessary, so we stop the file upload
				# to open
				#
				ev.preventDefault()
				return

		if ev.isImmediatePropagationStopped()
			return

		@DOM.addClass(CUI.defaults.class.Button.defaults.pressed_css_class)

		remove_click_class = =>
			@DOM.removeClass(CUI.defaults.class.Button.defaults.pressed_css_class)

		do_click = =>
			if ev.isImmediatePropagationStopped()
				remove_click_class()
				return

			Events.trigger
				type: "cui-button-click"
				node: @
				info:
					event: ev

			if ev.isImmediatePropagationStopped() or not @_onClick
				remove_click_class()
				return

			CUI.decide(@_onClick.call(@, ev, @))
			.always =>
				remove_click_class()
			return

		if @_onClick and @_confirm_on_click and not ev.ctrlKey()
			btns = []

			if not isEmpty(CUI.defaults.class.Button.defaults.confirm_cancel)
				btns.push
					text: CUI.defaults.class.Button.defaults.confirm_cancel
					onClick: =>
						dialog.destroy()
						remove_click_class()

			btns.push
				text: CUI.defaults.class.Button.defaults.confirm_ok
				onClick: =>
					dialog.destroy()
					do_click()

			dialog = new ConfirmationDialog
				text: @_confirm_on_click
				icon: CUI.defaults.class.Button.defaults.confirm_icon
				title: CUI.defaults.class.Button.defaults.confirm_title
				header_right:
					icon: "close"
					onClick: ->
						dialog.destroy()
				buttons: btns
			dialog.show()
		else
			do_click()
		@

	initOpts: ->
		super()
		@addOpts
			role:
				default: "button"
				check: String
			size:
				mandatory: true
				default: "auto"
				check: ["auto","mini","normal","big","bigger"]
			appearance:
				mandatory: true
				default: "auto"
				check: ["auto","link","flat","normal","important"]
			onClick:
				check: Function
			confirm_on_click:
				check: String
			onMouseisdown:
				check: Function
			onMouseover:
				check: Function
			onMouseout:
				check: Function
			click_type:
				default: "click"
				mandatory: true
				check: ["click", "mouseup", "dblclick"]
			text:
				check: String
			tooltip:
				check: "PlainObject"
			disabled:
				default: false
				check: (v) ->
					isBoolean(v) or $.isFunction(v)
			active_css_class:
				check: String
			left:
				check: (v) ->
					if v == true
						return true

					((v instanceof jQuery and v.length == 1) or
						v instanceof Element or
						isString(v)) and
						not @_icon and
						not @_icon_left and
						not @_icon_active and
						not @_icon_inactive
			right:
				check: (v) ->
					((v instanceof jQuery and v.length == 1) or v instanceof Element or v == true) and not @_icon_right
			center:
				check: (v) ->
					((v instanceof jQuery and v.length == 1) or v instanceof Element)
			icon:
				check: (v) ->
					v instanceof Icon or isString(v)
			icon_left:
				check: (v) ->
					v instanceof Icon or isString(v)
			icon_right:
				check: (v) ->
					v instanceof Icon or isString(v) or v == false
			icon_active:
				check: (v) ->
					v instanceof Icon or isString(v)
			icon_inactive:
				check: (v) ->
					v instanceof Icon or isString(v)
			text_active:
				check: String
			text_inactive:
				check: String
			value: {}
			# attributes for the @DOM element
			attr:
				default: {}
				check: "PlainObject"
			name:
				check: String
			hidden:
				check: (v) ->
					isBoolean(v) or $.isFunction(v)
			menu:
				check: "PlainObject"
			menu_on_hover:
				check: Boolean
			menu_parent:
				check: Menu
			onActivate:
				check: Function
			onDeactivate:
				check: Function

			# if set, this button belongs
			# to a group of buttons
			# on click, the active state of
			# this button will be set and unset
			# on the others
			radio:
				check: (v) ->
					isString(v) or v == true
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


	# return icon for string
	__getIcon: (icon) ->
		if not icon
			null
		else if icon instanceof Icon
			icon
		else
			new Icon(icon: icon)

	readOpts: ->

		if @opts.switch
			assert(isUndef(@opts.radio_allow_null), "new Button", "opts.switch cannot be used together with opts.radio_allow_null", opts: @opts)

		super()

		if @_left
			assert(@_left == true or not (@_icon_active or @_icon_inactive or @_icon), "new Button", "opts.left != true cannot be used togeter with opts.icon*", opts: @opts)

		if not isNull(@_active_css_class)
			@__active_css_class = @_active_css_class
		else
			@__active_css_class = CUI.defaults.class.Button.defaults.active_css_class

	getCenter: ->
		return @__box.map.center;

	getTemplateName: ->
		if @_icon or @_icon_left or @_icon_active or @_icon_inactive or @_left
			@__has_left = true
		else
			@__has_left = false

		if @_icon_right or (@_menu and @_icon_right != false) or @_right
			@__has_right = true
		else
			@__has_right = false

		if @__has_left and @__has_right
			return "button"
		else if @__has_left
			return "button-left-center"
		else if @__has_right
			return "button-center-right"
		else
			return "button-center"

	getValue: ->
		@_value

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
		div = @DOM.parents(".cui-buttonbar,.cui-form-table,.cui-tmpl-item-list-body,.cui-layer")
		if not div.length
			div = $(document.body) # @DOM.parent()
		else
			div = div.last()

		(DOM.data(c, "element") for c in div.find(".cui-button[#{key}=\"#{value}\"]"))


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
			@__menu = new Menu(@__menu_opts)

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

	activate: (flags={}, event) ->
		# CUI.error "activate", flags, @getUniqueId(), @__active, @_activate_initial

		activate = =>
			@DOM.addClass(@__active_css_class)
			@__setState()
			group = @getGroup()
			if not group or not event?.ctrlKey() or flags.ignore_ctrl
				return

			flags.ignore_ctrl = true
			for btn in @getGroupButtons()
				if btn == @
					continue
				btn.activate(flags, event)
			return

		if @_activate_initial == false and flags.initial_activate
			@__active = true
			activate()
			return @

		if @__active == true and $.isEmptyObject(flags)
			return @

		if @__radio
			for btn, idx in @getRadioButtons()
				if btn == @
					continue
				btn.deactivate(prior_activate: true, initial_activate: flags.initial_activate)

		@__active = true
		ret = @_onActivate?(@, flags, event)
		if isPromise(ret)
			ret.done(activate).fail =>
				@__active = false
			return ret

		activate()
		@

	deactivate: (flags={}, event) ->
		# CUI.error "deactivate", flags, @getUniqueId(), @__active, @_activate_initial, @_icon_inactive

		deactivate = =>
			@DOM.removeClass(@__active_css_class)
			@__setState()
			group = @getGroup()
			if not group or not event?.ctrlKey() or flags.ignore_ctrl
				return

			flags.ignore_ctrl = true
			for btn in @getGroupButtons()
				if btn == @
					continue
				btn.deactivate(flags, event)

		if @_activate_initial == false and flags.initial_activate
			@__active = false
			deactivate()
			return @

		if @__active == false and $.isEmptyObject(flags)
			return @

		@__active = false
		ret = @_onDeactivate?(@, flags, event)
		if isPromise(ret)
			ret.done(deactivate).fail =>
				@__active = true
			return ret

		deactivate()
		@

	setIcon: (icon=null) ->
		@__icon = @__getIcon(icon)
		assert(@__icon == null or @__icon instanceof Icon, "Button.setIcon", "icon needs to be instance of Icon", icon: icon)
		if @__icon == null
			@empty("left")
		else
			@replace(@__icon, "left")
		@

	startSpinner: ->
		assert(@__has_left, "Button.startSpinner", "No space for Icon found, make sure the Button was created with opts.left set.", opts: @opts)
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
		@__icon

	__setState: ->
		@__setIconState()
		@__setTextState()

	__setIconState: ->
		if not (@_icon_active or @_icon_inactive)
			return @

		if @isActive()
			if not @_icon_active
				@replace(DOM.element("SPAN"), "left")
				@__icon = null
			else
				@setIcon(@_icon_active, "left")
		else
			if not @_icon_inactive
				@replace(DOM.element("SPAN"), "left")
				@__icon = null
			else
				@setIcon(@_icon_inactive, "left")
		@

	__setTextState: ->
		if not (@_text_active or @_text_inactive)
			return @

		if @isActive()
			if not isNull(@_text_active)
				@setText(@_text_active)
		else
			if not isNull(@_text_inactive)
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
		@DOM.addClass(CUI.defaults.class.Button.defaults.disabled_css_class)
		DOM.removeAttribute(@DOM[0], "tabindex")
		@__disabled = true
		@

	enable: ->
		@DOM.removeClass(CUI.defaults.class.Button.defaults.disabled_css_class)
		DOM.setAttribute(@DOM[0], "tabindex", "0")
		@__disabled = false
		@

	setText: (@__txt) ->
		if isEmpty(@__txt)
			@empty("center")
		else
			@replace($text(@__txt), "center")

	getText: ->
		@__txt

	getGroup: ->
		@__group

	setGroup: (@__group) ->
		if @__group
			DOM.setAttribute(@DOM[0], "button-group", @__group)
		else
			DOM.removeAttribute(@DOM[0], "button-group")

	__initTooltip: ->
		if @__tooltip
			return @

		tt_opts = copyObject(@_tooltip)

		tt_opts.element ?= @DOM

		# make sure the tooltip does not register any listeners
		for k in ["on_hover", "on_click"]
			assert(not tt_opts.hasOwnProperty(k), "Button.__initTooltip", "opts.tooltip cannot contain #{k}.", opts: @opts)
			tt_opts[k] = false

		@__tooltip = new Tooltip(tt_opts)
		@

	getTooltip: ->
		@__tooltip

	isShown: ->
		not @isHidden()

	isHidden: ->
		@__hidden

	destroy: ->
		# CUI.debug "destroying button", @__uniqueId, @getText()
		@__menu?.destroy()
		@__tooltip?.destroy()
		super()

	show: ->
		@__hidden = false
		DOM.removeClass(@DOM[0], "cui-button-hidden")
		DOM.showElement(@DOM[0])
		Events.trigger
			type: "show"
			node: @DOM

	hide: ->
		@__hidden = true
		DOM.addClass(@DOM[0], "cui-button-hidden")
		DOM.hideElement(@DOM[0])
		Events.trigger
			type: "hide"
			node: @DOM


CUI.defaults.class.Button = Button

CUI.Events.registerEvent
	type: ["show", "hide", "cui-button-click"]
	bubble: true
