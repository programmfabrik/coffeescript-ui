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

		@removeOpt("placements")
		@removeOpt("placement")
		@

	readOpts: ->
		super()
		if @_parent_menu
			@_placements = ["es", "en", "ws", "wn"]
		else
			@_placements = ["se", "sw", "ne", "nw"]

		@_placement = @_placements[0]

	show: (@__event) ->
		assert(not @isDestroyed(), "#{getObjectClass(@)}.show", "Element is already destroyed.")

		if not @isShown() and @__itemList
			@__itemList.render(@, @__event)
			.done =>
				# FIXME: this can go, once #30529 is fixed
				; # autoSize()

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

	hasItems: ->
		@__itemList?.hasItems()

	getItemList: ->
		@__itemList

	setItemList: (itemList) ->
		if @_itemList instanceof CUI.ItemList
			@__itemList = itemList
		else

			delete(itemList.maximize)
			itemList.maximize_vertical = false
			itemList.maximize_horizontal = true

			@__itemList = new CUI.ItemList(itemList)

		@__itemList.__init()
		@replace(@__itemList)
		@proxy(@__itemList, ["setActiveIdx"])

		if @isShown()
			@__itemList.render(@, @__event)
			.done =>
				# FIXME: this can go, once #30529 is fixed
				; # @autoSize()
		@

	isAutoCloseAfterClick: ->
		@_auto_close_after_click

	destroy: ->
		@__itemList?.destroy()
		super()

	hide: (ev) ->
		ev?.preventDefault()
		super(ev)
		@

	hideAll: (ev) ->
		@hide(ev)
		@_parent_menu?.hideAll(ev)
		@

	# return button if part of a button
	getButton: ->
		DOM.data(@getElement()?[0], "element")



Menu = CUI.Menu