###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Menu extends CUI.Layer
	constructor: (@opts={}) ->
		super(@opts)
		if @_itemList
			@setItemList(@_itemList)

	initOpts: ->
		super()
		@addOpts
			itemList:
				check: (v) ->
					v instanceof CUI.ItemList or CUI.util.isPlainObject(v)

			auto_close_after_click:
				default: true
				check: Boolean

			parent_menu:
				check: CUI.Menu

			onBeforeItemListInit:
				check: Function

		@

	readOpts: ->
		super()

		if not @opts.placements
			if @_parent_menu
				@_placements = ["es", "en", "ws", "wn"]
			else if @_show_at_position # the element has not width and height
				@_placements = ["es", "en", "ws", "wn"]
			else
				@_placements = ["se", "sw", "ne", "nw"]

		if not @opts.placement
			@_placement = @_placements[0]

		return

	show: (@__event) ->
		CUI.util.assert(not @isDestroyed(), "#{CUI.util.getObjectClass(@)}.show", "Element is already destroyed.")
		if @isShown()
			@position()
			return @

		if @__loading
			return @

		if @__itemList
			@__loading = true
			@__itemList.render(@, @__event).done( =>
				super(@__event)
				@__loading = false
			)
		else
			super(@__event)

		@__previousFocusedElement = document.activeElement
		@DOM.focus()

		CUI.Events.listen
			type: "keyup"
			instance: @  # will be ignored by onHide in Layer
			node: @DOM
			capture: true
			call: (ev) =>
				if ev.hasModifierKey()
					return

				if ev.getKeyboardKey() in ["Esc", "Tab"]
					@hide()
					ev.stop()

		@

	hasItems: (event) ->
		@__itemList?.hasItems(event)

	getItemList: ->
		@__itemList

	setItemList: (itemList) ->
		if itemList instanceof CUI.ItemList
			@__itemList = itemList
		else
			delete(itemList.maximize)
			itemList.maximize_vertical = false
			itemList.maximize_horizontal = true
			itemList.keyboardControl = true

			if not itemList.hasOwnProperty("active_item_idx")
				# tell item list to not manage active item
				itemList.active_item_idx = null

			@__itemList = new CUI.ItemList(itemList)

		@replace(@__itemList)
		@proxy(@__itemList, ["setActiveIdx"])

		if @isShown()
			@__itemList.render(@, @__event)
			.done =>
				@position()
		@

	isAutoCloseAfterClick: ->
		@_auto_close_after_click

	destroy: ->
		@__itemList?.destroy()
		super()

	hide: (ev) ->
		super(ev)
		@__previousFocusedElement?.focus()
		@

	hideAll: (ev) ->
		@hide(ev)
		@_parent_menu?.hideAll(ev)
		@

	# return button if part of a button
	getButton: ->
		element = @getOpt("element")
		if not element or element instanceof CUI.Button
			return element
		button = CUI.dom.data(element.DOM or element, "element")
		if button instanceof CUI.Button
			return button
		null
