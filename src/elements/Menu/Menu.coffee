###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Menu extends CUI.Layer
	constructor: (opts) ->
		super(opts)
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

		# It is necessary to save this status, to be able to focus again the button after the menu is closed.
		@__openedByKeyboard = @__event?.getNativeEvent() instanceof KeyboardEvent

		if @isShown()
			@position()
			return @

		if @__loading
			return @

		# After the menu is shown, it is focused so keydown/keyup events work.
		onShow = =>
			if @getButton()
				@DOM.focus()
			return

		if @__itemList
			@__loading = true
			@__itemList.render(@, @__event).done( =>
				super(@__event)
				onShow()
				@__loading = false
			)
		else
			super(@__event)
			onShow()

		@__keyUpListener = CUI.Events.listen
			type: "keyup"
			node: @DOM
			capture: true
			call: (ev) =>
				if ev.hasModifierKey()
					return

				if ev.getKeyboardKey() in ["Esc", "Tab"]
					@hide()
					ev.stop()

				return

		@__keydownListener = CUI.Events.listen
			type: "keydown"
			node: @DOM
			capture: true
			call: (ev) =>
				if @__itemList
					CUI.Events.trigger
						node: @__itemList.DOM
						type: "item-list-keydown"
						info:
							event: ev
				return
		@

	hide: ->
		if @__openedByKeyboard
			@getButton()?.DOM.focus()

		@__keyUpListener?.destroy()
		@__keydownListener?.destroy()
		return super();

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
				# If we have a scroll position, we set it after the rendering.
				if @__updateScroll
					@__itemList.DOM.scrollTop = @__updateScroll
				# If we have a wait block, we hide it after the rendering.
				if @__waitBlock
					@__waitBlock.hide()
					@__waitBlock = null
					delete(@__updateScroll)
		@

	isAutoCloseAfterClick: ->
		@_auto_close_after_click

	destroy: ->
		@__itemList?.destroy()
		super()

	reload: (keepScroll) ->
		# We call the setItemList method to re-render the menu.
		@__waitBlock = new CUI.WaitBlock(element: @DOM)
		if keepScroll
			@__updateScroll = @getItemList().DOM.scrollTop
		@setItemList(@_itemList)
		@__waitBlock.show()

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
