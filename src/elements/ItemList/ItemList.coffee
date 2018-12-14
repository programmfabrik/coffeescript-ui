###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./ItemList.html'));

class CUI.ItemList extends CUI.VerticalLayout

	init: ->
		super()
		@addClass("cui-item-list")
		@__body = new CUI.Template(name: "item-list-body")
		@append(@__body, "center")

		if @_keyboardControl
			@__initListeners()

	initOpts: ->
		super()
		@addOpts
			items:
				mandatory: true
				check: (v) ->
					CUI.util.isFunction(v) or CUI.util.isArray(v)
			# if set no "null", don't manage this for us
			# otherwise ItemList sets the active item
			# according to the active idx
			# set to -1, if you want manage, but nothing can be highlighted
			active_item_idx:
				check: "Integer"

			# use this if your items method
			# returns a Deferred, the @hasItems
			# method of ItemList will then
			# return immediately and not run
			# "@_items()"
			has_items:
				default: false
				check: Boolean
			allow_null:
				check: Boolean
			onClick:
				check: Function
			onActivate:
				check: Function
			onDeactivate:
				check: Function
			orientation:
				default: "vertical"
				check: ["horizontal","vertical"]
			keyboardControl:
				check: Boolean
				default: false
		@

	readOpts: ->
		super()
		if @_orientation == "horizontal"
			console.error("new CUI.ItemList, orientation == horizontal needs implementation!")
		@

	setActiveIdx: (@__active_idx) ->

	getActiveIdx: ->
		@__active_idx

	getBody: ->
		@__body

	getItemByValue: (value) ->
		for el in @__body.DOM.children
			btn = CUI.dom.data(el, "element")

			if btn not instanceof CUI.Button
				continue

			if btn.getValue() == value
				return btn
		null

	# returns immediately, if "Promise" we assume yes
	hasItems: (event) ->
		if @_has_items
			return true

		items = @__getItems(event)
		if CUI.util.isPromise(items)
			console.warn("ItemList.hasItems: opts.items Function returned a Promise. Set opts.has_items to true, in order to avoid the call of that Function.")
			true
		else
			items.length > 0

	__getItems: (event) ->
		if CUI.util.isFunction(@_items)
			@_items(event, @) or []
		else
			@_items

	getItems: (event) ->
		items = @__getItems(event)

		if CUI.util.isPromise(items)
			items
		else
			new CUI.Deferred().resolve(items)


	__initActiveIdx: ->

		active_idx = @_active_item_idx

		if active_idx == undefined
			items = @__getItems()

			if CUI.util.isPromise(items)
				active_idx = -1
			else
				for item, idx in items
					if not item
						continue
					if CUI.util.isUndef(item.active)
						continue
					if item.active
						active_idx = idx
						break

				# we only get here, if any
				# of out items has an
				# "active" property
				if active_idx == undefined
					active_idx = -1

		if active_idx != null
			if active_idx == -1
				@__active_idx = null
			else
				@__active_idx = active_idx

			@__radio = "item-list--"+@getUniqueId()

		# console.debug "active:", active_idx, @__radio
		@__isInitActiveIdx = true


	render: (menu, event) ->
		if not @__isInitActiveIdx
			@__initActiveIdx()

		@__body.empty()

		promise = @getItems(event)

		promise.done (items) =>

			opt_keys = CUI.defaults.class.Button.getOptKeys()
			list_has_button_left = false

			for _item, idx in items
				if CUI.util.isFunction(_item)
					item = _item(@, menu, event)
				else
					item = _item

				do (item, idx) =>
					if not item or item.hidden == true or item.hidden?()
						return

					if item.divider
						divider = CUI.dom.div("cui-menu-divider cui-item-list-divider", role: "menu-item")
						# DOM.data(divider[0], "itemListIdx", idx)
						@__body.append(divider)
						return

					if item.label
						if item.label instanceof CUI.Label
							label = item.label
						else if CUI.util.isPlainObject(item.label)
							label = new CUI.defaults.class.Label(item.label)
						else
							label = new CUI.defaults.class.Label(text: item.label)

						# DOM.data(label.DOM[0], "itemListIdx", idx)
						label.addClass("cui-menu-item")
						CUI.dom.append(@__body.DOM, label.DOM)
						return

					if item.content
						# console.debug "adding item content", item.content
						CUI.dom.append(@__body.DOM, item.content.DOM or item.content)
						return

					listenButtonClick = (btn) =>

						CUI.Events.listen
							type: "cui-button-click"
							node: btn
							call: (ev, info) =>
								@_onClick?(info.event, btn, item, idx)

								if not menu?.isAutoCloseAfterClick() or btn.hasMenu()
									return

								hide = =>
									menu.hideAll(info.event)

								el = menu.getElement()
								if el
									dim = CUI.dom.getDimensions(menu.getElement())
									if dim.clientWidth == 0 and dim.clientHeight == 0
										hide()
										return

								# we need to do this after a timeout, because
								# some buttons have default actions
								# which might be interruped if we destroy the button
								# width menu.hideAll
								CUI.setTimeout(call: hide)

						return

					if item instanceof CUI.Button
						listenButtonClick(item)

						if item.hasLeft()
							list_has_button_left = true

					if item instanceof CUI.Button or
						item instanceof CUI.DataField or
						item instanceof CUI.Label

							CUI.dom.append(@__body.DOM, item.DOM)
							return

					opts =
						role: "menu-item"
						radio: @__radio
						radio_allow_null: @_allow_null
						onActivate: (btn, flags) =>
							if @__radio
								@__active_idx = idx
							@_onActivate?(btn, item, idx, flags)
							@__deselectPreActivated()

						onDeactivate: (btn, flags) =>
							if @__radio
								@__active_idx = null
							@_onDeactivate?(btn, item, idx, flags)
							@__deselectPreActivated()

					for k in opt_keys
						if item.hasOwnProperty(k) and not opts.hasOwnProperty(k)
							opts[k] = item[k]

					if @__radio
						if @__active_idx == idx
							opts.active = true

					if menu
						opts.menu_parent = menu

					btn = new CUI.defaults.class.Button(opts)

					listenButtonClick(btn)

					if btn.hasLeft()
						list_has_button_left = true

					# DOM.data(btn.DOM[0], "itemListIdx", idx)
					CUI.dom.append(@__body.DOM, btn.DOM)
					return

				if list_has_button_left
					@__body.addClass("cui-item-list--has-button-left")
				else
					@__body.removeClass("cui-item-list--has-button-left")

			@__preActiveIndex = @__initPreActiveIndex()
			return
		promise

	destroy: ->
		super()
		@__body?.destroy()

	__initListeners: ->
		@__keyboardKeys = []
		preSelectByKeyword = =>
			@__preSelectByKeyword(@__keyboardKeys.join(""))
			@__keyboardKeys = []

		CUI.Events.listen
			type: "item-list-keydown"
			node: @DOM
			call: (_, info) =>
				event = info.event
				if not CUI.dom.isInDOM(@__body)
					return

				keyboardKey = event.getKeyboardKey()
				switch keyboardKey
					when "Down"
						event.preventDefault()
						@__preActivateNextButton()
						break
					when "Up"
						event.preventDefault()
						@__preActivatePreviousButton()
						break
					when "Return"
						@__activatePreSelected(event)
						break
					else
						if keyboardKey
							@__keyboardKeys.push(keyboardKey)
							CUI.scheduleCallback(ms: 200, call: preSelectByKeyword)
				return

		CUI.Events.listen
			type: "mouseover"
			node: @DOM
			call: (ev) =>
				item = CUI.dom.parents(ev.getTarget(), ".cui-button-button")[0]
				if CUI.dom.hasClass(item, CUI.defaults.class.Button.defaults.active_css_class)
					return

				index = @__getButtonIndex(item)
				if not CUI.util.isNull(index)
					@__preActivateButtonByIndex(index)
				return

		return

	__preSelectByKeyword: (keyword) ->
		elementMatches = (element) =>
			(element instanceof CUI.Button or element instanceof CUI.Label) and element.getText()?.startsWithIgnoreCase(keyword)

		nextIndex = @__preActiveIndex + 1
		nextElement = @__getButtonByIndex(nextIndex)
		if elementMatches(nextElement)
			@__preActivateButtonByIndex(nextIndex)
			return

		for item, index in @__body?.DOM.children
			element = CUI.dom.data(item, "element")
			if elementMatches(element)
				@__preActivateButtonByIndex(index)
				break
		return

	__activatePreSelected: (event) ->
		itemToActivate = @__getButtonByIndex(@__preActiveIndex)
		if itemToActivate instanceof CUI.Button
			itemToActivate.onClickAction(event)
			CUI.dom.removeClass(itemToActivate, CUI.defaults.class.Button.defaults.active_css_class)

	__preActivateNextButton: ->
		if CUI.util.isNull(@__preActiveIndex)
			index = 0
		else
			index = @__preActiveIndex + 1
		@__preActivateButtonByIndex(index)

	__preActivatePreviousButton: ->
		if CUI.util.isNull(@__preActiveIndex)
			items = @__getButtonItems()
			index = items.length - 1
		else
			index = @__preActiveIndex - 1
		@__preActivateButtonByIndex(index)

	__preActivateButtonByIndex: (newPreActiveIndex) ->
		buttonToPreActivate = @__getButtonByIndex(newPreActiveIndex)
		if buttonToPreActivate instanceof CUI.Button
			@__deselectPreActivated()
			@__preActiveIndex = newPreActiveIndex
			CUI.dom.addClass(buttonToPreActivate, CUI.defaults.class.Button.defaults.active_css_class)
			CUI.dom.scrollIntoView(buttonToPreActivate)

	__deselectPreActivated: ->
		previousItemSelected = @__getButtonByIndex(@__preActiveIndex)
		if previousItemSelected instanceof CUI.Button
			CUI.dom.removeClass(previousItemSelected, CUI.defaults.class.Button.defaults.active_css_class)

	__getButtonByIndex: (index) ->
		if not @__body or CUI.util.isNull(index) or index < 0
			return

		item = @__getButtonItems()[index]
		return CUI.dom.data(item, "element")

	__getButtonIndex: (item) ->
		for itemButton, index in @__getButtonItems()
			if item == itemButton
				return index
		return

	__getButtonItems: ->
		return Array::filter.call(@__body.DOM.children, (item) =>
			element = CUI.dom.data(item, "element")
			return element instanceof CUI.Button
		)

	__initPreActiveIndex: ->
		if @__active_idx
			return @__active_idx

		for item, index in @__body.DOM.children
			if CUI.dom.hasClass(item, CUI.defaults.class.Button.defaults.active_css_class)
				return index

CUI.ready =>
	CUI.Events.registerEvent
		type: "item-list-keydown"
		sink: true