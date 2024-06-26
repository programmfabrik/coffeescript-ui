###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FormPopover extends CUI.Form
	constructor: (opts) ->
		super(opts)
		# console.debug "FormPopover", @opts
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
					CUI.util.isPlainObject(v) and not v.onClick
			trigger_data_changed_while_open:
				default: false
				check: Boolean
			renderDisplayButton:
				check: Function
			renderDisplayContent:
				check: Function
			onClose:
				check: Function

	readOpts: ->
		super()
		if @_class
			@__class = @_class
			delete(@_class)

		@__fields_is_func = CUI.util.isFunction(@_fields)

		if @__fields_is_func
			CUI.util.assert(@_data_not_for_others != true, "new CUI.FormPopover", "opts.data_not_for_others cannot be set to true if fields are created on open by a Function.", opts: @opts)

	init: ->
		if not @__fields_is_func
			return super()

		@__initUndo()
		# don't initFields here, if fields are a function
		# @setFormDepth()

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
			"hasUserData"
			"getFieldByIdx"
			"setFormDepth"
			"getDataFields"
		]
			return @__fields or []

		CUI.util.assert(@__fields, "FormPopover.getFields("+func+")", "Fields not rendered yet. This is a programming error in CUI.")
		return super()

	# this is for the button container
	initTemplate: ->
		# @__horLayout = new CUI.HorizontalLayout
		# 	maximize: false
		# 	right: {}

		# for now we leave a vertical layout here, the
		# design is adjusted to this
		@__horLayout = new CUI.VerticalLayout
			maximize: false
			bottom: {}

		@registerTemplate(@__horLayout.getLayout())

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
			# console.debug df.getName(), func, args
			df[func].apply(df, args)
		@

	__renderDisplay: ->

		if @_renderDisplayContent
			display = @_renderDisplayContent(@, @__data)
		else if @_renderDisplayButton
			render = @_renderDisplayButton(@, @__data)
		else if not @__data
			text = "Data not set."
			display = CUI.dom.textEmpty(text)
		else
			display = text = ""
			# console.debug("display", display,@__formPopover.getGroupData())

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
				# console.debug "FormPopover.__renderDisplay: triggering list-view-resize:", @__old_render, render
				CUI.Events.trigger
					type: "content-resize"
					node: @DOM
			@__old_render = render

		else
			if @__old_display == null or @__old_display != display
				@replace(display, "bottom") # change to "right" for horLayout
				if @__old_display != null
					CUI.Events.trigger
						type: "content-resize"
						node: @DOM
						bubble: false

				@__old_display = display

		@checkChanged()
		@

	# overwritten in FormModal
	initPopover: (opts) ->
		new CUI.Popover(opts)

	getPopoverOpts: ->
		pop_opts = CUI.util.copyObject(@_popover, true)

		if not pop_opts.backdrop
			pop_opts.backdrop = {}

		if not pop_opts.backdrop.policy
			pop_opts.backdrop.policy = "click"

		if not pop_opts.pane
			pop_opts.pane = {}

		CUI.util.assert(CUI.util.isPlainObject(pop_opts.pane), "new CUI.FormPopover", "opts.pane must be PlainObject", opts: pop_opts)
		CUI.util.mergeMap(pop_opts.pane, padded: true)

		if CUI.util.isEmpty(pop_opts.class)
			pop_opts.class = ""
		pop_opts.class += " cui-form-popover-popover"	

		if @__class
			pop_opts.class += " " + @__class + "-popover"
		# console.debug "getPopoverOpts", pop_opts
		pop_opts

	getPopover: ->
		@__popover

	renderAsBlock: ->
		false

	renderTable: ->
		super()
		@getLayout().addClass(@__class)
		return

	removeFields: ->
		@callOnFields("remove")

		@__rendered = null
		@__fields = null
		@

	__openPopover: ->
		# console.time "FormPopover"

		pop_opts = @getPopoverOpts()

		if @__fields_is_func
			# dynamic fields, we need to reload the form
			if @__rendered
				@removeFields()

			@initFields()
			@callOnFields("setData", @__data)

		if not @__rendered
			@renderTable()
			@__rendered = true
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
				# console.debug("data changed on popover, render display", @, @_trigger_data_changed_while_open)
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
		CUI.dom.remove(@getLayout().DOM)
		@__popover.destroy()
		@__popover = null
		@__triggerDataChanged()
		if @_onClose
			@_onClose(@)
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
		@__horLayout = null
		@__button = null
