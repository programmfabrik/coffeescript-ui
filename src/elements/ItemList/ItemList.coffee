class CUI.ItemList extends CUI.VerticalLayout

	init: ->
		# we postpone the init until we are rendered

	__init: ->
		super()
		@addClass("cui-item-list")

		if not isUndef(@__active_idx)
			active_idx = @__active_idx
		else
			active_idx = @_active_item_idx

		if isUndef(active_idx)
			items = @__getItems()
			if isPromise(items)
				active_idx = null

			for item, idx in items
				if not item
					continue
				if isUndef(item.active)
					continue
				if item.active
					active_idx = idx
					break
				if isUndef(active_idx)
					active_idx = null

		if not isUndef(active_idx)
			@__active_idx = active_idx
			@__radio = "item-list-#{@__uniqueId}"

		@__body = new Template(name: "item-list-body")
		@append(@__body, "center")
		@__isInit = true


	initOpts: ->
		super()
		@addOpts
			items:
				mandatory: true
				check: (v) ->
					CUI.isFunction(v) or CUI.isArray(v)
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
		@

	readOpts: ->
		super()
		if @_orientation == "horizontal"
			CUI.error("new CUI.ItemList, orientation == horizontal needs implementation!")
		@

	setActiveIdx: (@__active_idx) ->

	getItemByValue: (value) ->
		for el in @__body.DOM.children
			btn = DOM.data(el, "element")

			if btn not instanceof Button
				continue

			if btn.getValue() == value
				return btn
		null

	# returns immediately, if "Promise" we assume yes
	hasItems: ->
		if @_has_items
			return true

		items = @__getItems()
		if isPromise(items)
			CUI.warn("ItemList.hasItems: opts.items Function returned a Promise. Set opts.has_items to true, in order to avoid the call of that Function.")
			true
		else
			items.length > 0

	__getItems: (event) ->
		if CUI.isFunction(@_items)
			@_items(event, @)
		else
			@_items

	getItems: (event) ->
		items = @__getItems(event)

		if isPromise(items)
			items
		else
			new CUI.Deferred().resolve(items)

	render: (menu, event) ->
		if not @__isInit
			@__init()

		@__body.empty()

		@getItems(event)
		.done (items) =>

			opt_keys = CUI.defaults.class.Button.getOptKeys()
			list_has_button_left = false

			for _item, idx in items
				if CUI.isFunction(_item)
					item = _item(@, menu, event)
				else
					item = _item

				do (item, idx) =>
					if not item or item.hidden == true or item.hidden?()
						return

					if item.divider
						divider = $div("cui-menu-divider", role: "menu-item")
						# DOM.data(divider[0], "itemListIdx", idx)
						@__body.append(divider)
						return

					if item.label
						if item.label instanceof Label
							label = item.label
						else if CUI.isPlainObject(item.label)
							label = new CUI.defaults.class.Label(item.label)
						else
							label = new CUI.defaults.class.Label(text: item.label)

						# DOM.data(label.DOM[0], "itemListIdx", idx)
						label.addClass("cui-menu-item")
						@__body.append(label.DOM)
						return

					if item.content
						# CUI.debug "adding item content", item.content
						@__body.DOM.append(item.content.DOM or item.content)
						return

					listenButtonClick = (btn) =>

						Events.listen
							type: "cui-button-click"
							node: btn
							call: (ev, info) =>
								btn.getTooltip()?.destroy()
								@_onClick?(info.event, btn, item, idx)

								if not menu?.isAutoCloseAfterClick() or btn.hasMenu()
									return

								hide = =>
									menu.hideAll(info.event)

								el = menu.getElement()
								if el
									dim = DOM.getDimensions(menu.getElement()[0])
									if dim.clientWidth == 0 and dim.clientHeight == 0
										hide()
										return

								# we need to do this after a timeout, because
								# some buttons have default actions
								# which might be interruped if we destroy the button
								# width menu.hideAll
								CUI.setTimeout(call: hide)

						return

					if item instanceof Button
						listenButtonClick(item)
						if item.hasLeft()
							list_has_button_left = true

					if item instanceof Button or
						item instanceof DataField or
						item instanceof Label

							@__body.append(item.DOM)
							return

					opts =
						role: "menu-item"
						radio: @__radio
						radio_allow_null: @_allow_null
						onActivate: (btn, flags) =>
							if @__radio
								@__active_idx = idx
							@_onActivate?(btn, item, idx, flags)

						onDeactivate: (btn, flags) =>
							if @__radio
								@__active_idx = null
							@_onDeactivate?(btn, item, idx, flags)

					for k in opt_keys
						if item.hasOwnProperty(k) and not opts.hasOwnProperty(k)
							opts[k] = item[k]

					if @__radio
						if @__active_idx == idx
							opts.active = true

					if menu
						opts.menu_parent = menu

					btn = new CUI.defaults.class.ItemListButton(opts)

					listenButtonClick(btn)

					if btn.hasLeft()
						list_has_button_left = true

					# DOM.data(btn.DOM[0], "itemListIdx", idx)
					@__body.append(btn)
					return

				if list_has_button_left
					@__body.addClass("cui-item-list-has-button-left")
				else
					@__body.removeClass("cui-item-list-has-button-left")

			return

	destroy: ->
		super()
		@__body?.destroy()


ItemList = CUI.ItemList