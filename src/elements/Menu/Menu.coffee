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
					v instanceof ItemList or CUI.isPlainObject(v)

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

	getPlacements: ->
		if @_parent_menu
			["es", "en", "ws", "wn"]
		else
			["se", "sw", "ne", "nw"]


	getPositioner: ->
		if @__show_at_position
			@__show_at_position
		else
			super()

	show: (@__show_at_position, @__event) ->
		assert(not @__show_at_position or @__show_at_position instanceof Positioner, "#{@__cls}.show", "position needs to be instance of Positioner.", position: @__show_at_position)

		assert(not @isDestroyed(), "#{getObjectClass(@)}.show", "Element is already destroyed.")

		if not @isShown() and @__itemList
			@__itemList.render(@, @__event)
			.done =>
				# FIXME: this can go, once #30529 is fixed
				@autoSize()

		super(null, @__event)

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
		if @_itemList instanceof ItemList
			@__itemList = itemList
		else

			delete(itemList.maximize)
			itemList.maximize_vertical = false
			itemList.maximize_horizontal = true

			@__itemList = new ItemList(itemList)

		@__itemList.__init()
		@replace(@__itemList)
		@proxy(@__itemList, ["setActiveIdx"])

		if @isShown()
			@__itemList.render(@, @__event)
			.done =>
				# FIXME: this can go, once #30529 is fixed
				@autoSize()
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

	#we compensate the vertical scrollbar here
	# __compensateScrollbars: ( new_dimension_in_out ) ->

	# 	#have scrollbar ?
	# 	if new_dimension_in_out.height < @__layer_dim._css_height
	# 		# we shrunk, set new height and watch if scrollbar appears
	# 		@__layer.DOM.height(new_dimension_in_out.height)

	# 		scrolling_div = @__layer.DOM.find(".cui-tmpl-item-list-body")

	# 		scrollbar_width = scrolling_div.width() - scrolling_div[0].clientWidth

	# 		#give space for scrollbar
	# 		new_dimension_in_out.width += scrollbar_width

	# 		#dont touch the underlying logic, revert size.
	# 		@__layer.DOM.height(@__layer_dim._css_width)

	# 	@


Menu = CUI.Menu