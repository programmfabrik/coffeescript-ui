###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FormPopover extends CUI.Form
	constructor: (@opts={}) ->
		super(@opts)
		# CUI.debug "FormPopover", @opts
		@__old_display = null
		@__old_render = null

		@

	initOpts: ->
		super()
		@addOpts
			popover:
				default: {}
				check: "PlainObject"
			button:
				default: {}
				check: (v) ->
					CUI.isPlainObject(v) and not v.onClick
			trigger_data_changed_while_open:
				default: false
				check: Boolean
			renderDisplayButton:
				check: Function
			renderDisplayContent:
				check: Function

	readOpts: ->
		super()
		if @_class
			@__class = @_class
			delete(@_class)

		@__fields_is_func = CUI.isFunction(@_fields)

		if @__fields_is_func
			CUI.util.assert(@_data_not_for_others != true, "new CUI.FormPopover", "opts.data_not_for_others cannot be set to true if fields are created on open by a Function.", opts: @opts)

	init: ->
		if not @__fields_is_func
			return super()

		@__initUndo()
		# don't initFields here, if fields are a function
		@setFormDepth()

	setDataOnOthers: ->
		if @__fields_is_func
			false
		else
			super()

	isChanged: ->
		if @__fields
			super()
		else
			false

	getFields: (func="") ->
		if func in ["render", "displayValue"]
			return []

		if func in [
			"show"
			"hide"
			"remove"
			"enable"
			"disable"
			"getFieldsByName"
			"getFieldByIdx"
			"setFormDepth"
			"getDataFields"
		]
			return @__fields or []

		CUI.util.assert(@__fields, "FormPopover.getFields("+func+")", "Fields not rendered yet. This is a programming error in CUI.")
		return super()

	# this is for the button container
	initTemplate: ->
		vl = new CUI.VerticalLayout
			maximize: false
			bottom: {}

		@registerTemplate(vl.getLayout())

	hasContentForAppend: ->
		# FormPopver always shows a button
		true

	render: ->
		button_opts = CUI.util.copyObject(@_button, true)
		button_opts.onClick = =>
			@__openPopover()

		CUI.mergeMap button_opts,
			left: true
			text: ""

		@__button = new CUI.defaults.class.Button(button_opts)

		@addClass("cui-data-field-input")

		# this means the button's text is rendered by
		# the "renderDisplay" function
		if @_renderDisplayButton
			@addClass("cui-form-popover-has-button-text")
		@append(@__button, "center")
		# @append(@getChangedMarker(), "center")
		CUI.DataField::render.call(@)
		@

	getButton: ->
		@__button

	displayValue: ->
		CUI.DataField::displayValue.call(@)
		@__renderDisplay()

	callOnFields: (func, args...) ->
		for df in @getFields()
			# CUI.debug df.getName(), func, args
			df[func].apply(df, args)
		@

	__renderDisplay: ->

		if @_renderDisplayContent
			display = @_renderDisplayContent(@, @__data)
		else if @_renderDisplayButton
			render = @_renderDisplayButton(@, @__data)
		else if not @__data
			text = "Data not set."
			display = CUI.DOM.textEmpty(text)
		else
			display = text = ""
			# CUI.debug("display", display,@__formPopover.getGroupData())

		if @_renderDisplayButton
			if render == false
				@__button.deactivate()
			else if render == true
				@__button.activate()
			else if render instanceof CUI.Icon
				@__button.setIcon(render)
				@__button.setText()
			else
				@__button.setIcon()
				@__button.setText(render)

			if @__old_render != null
				# CUI.debug "FormPopover.__renderDisplay: triggering list-view-resize:", @__old_render, render
				CUI.Events.trigger
					type: "content-resize"
					node: @DOM
			@__old_render = render

		else
			if @__old_display == null or @__old_display != display
				@replace(display, "bottom")
				if @__old_display != null
					CUI.Events.trigger
						type: "content-resize"
						node: @DOM
				@__old_display = display

		@checkChanged()
		@

	renderTable: ->
		@table = super()
		# in "ng" design, table is the center element of layout
		CUI.DOM.addClass(@getLayout().DOM, @__class)
		@table

	# overwritten in FormModal
	initPopover: (opts) ->
		new CUI.Popover(opts)

	getPopoverOpts: ->
		pop_opts = CUI.util.copyObject(@_popover, true)

		if not pop_opts.backdrop
			pop_opts.backdrop = {}

		if not pop_opts.backdrop.policy
			pop_opts.backdrop.policy = "click"

		# pop_opts.element = @__button
		if not pop_opts.pane
			pop_opts.pane = {}

		CUI.util.assert(CUI.isPlainObject(pop_opts.pane), "new CUI.FormPopover", "opts.pane must be PlainObject", opts: pop_opts)

		if CUI.util.isEmpty(pop_opts.class)
			pop_opts.class = ""
		pop_opts.class += " cui-form-popover-popover"
		# CUI.debug "getPopoverOpts", pop_opts
		pop_opts

	getPopover: ->
		@__popover

	renderAsBlock: ->
		false

	resetTableAndFields: ->
		# console.error "resetTableAndFields", @table
		@callOnFields("remove")
		@unregisterTableListeners()
		# console.error "resetTableAndFields", DOM.data(@getLayout().center())
		if CUI.__ng__
			CUI.DOM.empty(@table)
		else
			CUI.DOM.remove(@table)
		@table = null
		@__fields = null
		@

	__openPopover: ->
		# console.time "FormPopover"

		# console.debug "open popover", @__data, @table, @__fields

		pop_opts = @getPopoverOpts()

		if @__fields_is_func
			# dynamic fields, we need to reload the form
			if @table
				@resetTableAndFields()

			@initFields()
			@callOnFields("setData", @__data)

		if not @table
			@renderTable()
			@callOnFields("start")

		if not pop_opts.hasOwnProperty("element")
			pop_opts.element = @__button

		onHide = pop_opts.onHide
		pop_opts.onHide = (pop, ev) =>
			@__closePopover()
			onHide?(pop, ev)

		onShow = pop_opts.onShow
		if onShow
			pop_opts.onShow = (pop) =>
				onShow?(pop, @)

		pop_opts.pane.content = @getLayout()

		@__popover = @initPopover(pop_opts)

		CUI.Events.listen
			type: "data-changed"
			node: @__popover
			call: (ev, info={}) =>
				# CUI.debug("data changed on popover, render display", @_trigger_data_changed_while_open)
				@__renderDisplay()
				@__dataChanged = info
				if @_trigger_data_changed_while_open
					@__triggerDataChanged()
				return

		# @__renderDisplay()
		@__popover.show()
		@addClass("focus")
		# console.timeEnd "FormPopover"

	__closePopover: ->
		@removeClass("focus")
		CUI.DOM.remove(@getLayout().DOM)
		@__popover.destroy()
		@__popover = null
		@__triggerDataChanged()
		@

	# this calls the "onHide" function
	closePopover: ->
		@__popover?.hide()

	hide: (trigger_event=false) ->
		@closePopover()
		super(trigger_event)

	__triggerDataChanged: ->
		if @__dataChanged
			@triggerDataChanged()
		@__dataChanged = null

	triggerDataChanged: ->
		CUI.Events.trigger
			type: "data-changed"
			node: @__button
			info: @__dataChanged

	disable: ->
		super()
		@__button?.disable()

	enable: ->
		super()
		@__button?.enable()


	destroy: ->
		super()
		@__popover?.destroy()
		@__dataChanged = null
