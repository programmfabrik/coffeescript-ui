###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Menu extends CUI.Layer
	constructor: (@opts={}) ->
		# @opts.role = "menu"
		super(@opts)
		if @_itemList
			@setItemList(@_itemList)

	initOpts: ->
		super()
		@addOpts
			itemList:
				check: (v) ->
					v instanceof CUI.ItemList or CUI.isPlainObject(v)

			auto_close_after_click:
				default: true
				check: Boolean

			parent_menu:
				check: Menu

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

		if @__itemList
			@__itemList.render(@, @__event)
			.done =>
				super(@__event)
				# Events.trigger
				# 	type: "content-resize"
				# 	node: @__itemList
		else
			super(@__event)

		Events.listen
			type: "keydown"
			instance: @  # will be ignored by onHide in Layer
			node: @DOM
			capture: true
			call: (ev) =>
				if ev.hasModifierKey()
					return

				if ev.keyCode() == 27
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
		# ev?.preventDefault()
		super(ev)
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
		button = DOM.data(element.DOM or element, "element")
		if button instanceof CUI.Button
			return button
		null

