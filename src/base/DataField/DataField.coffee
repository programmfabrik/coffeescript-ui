class CUI.DataField extends CUI.DOM

	@changed_marker_css_class: "cui-data-field-changed-marker"

	constructor: (@opts={}) ->
		super(@opts)

		assertImplements(@, ["render"])

		if @_name
			assertImplements(@, ["getDefaultValue"])

		@__checkChangedValue = undefined

		if @_form
			assert(not (@_form.right and @_form.data_field_right), "#{@__cls}.renderTable", "opts.form.right and opts.form.data_field_right cannot be set together.", opts: @opts)
			if @_form.data_field_right
				@__form_data_field_right = CUI.DataField.new(@_form.data_field_right)

		@initTemplate()

		@addClass("cui-data-field")
		@updateDepthAttribute("cui-data-field-form-depth", 0)

		Events.listen
			type: "data-changed"
			node: @DOM
			call: (ev, info) =>
				if not info?.element
					CUI.warn("#{getObjectClass(@)}[DataField].listen[data-changed]: received event with element not set.", ev, info, @)
					return
				@_onDataChanged?(info.element.getData(), info.element, ev, info)
				return

		if @getName()
			@DOM.attr("cui-data-field-name", @getName())

		@init()
		if @_data and not CUI.isFunction(@_data)
			# CUI.debug "setting private data: "+@, @_data
			@setData(@_data)

		@__initDisabled()

		if @_hidden
			@hide()

		if @_tooltip
			tt_opts = copyObject(@_tooltip)
			tt_opts.element = @DOM
			@__tooltip = new Tooltip(tt_opts)

		@__opacity = 1
		@_onInit?(@)

		# CUI.debug "new: "+@

	initOpts: ->
		super()
		@addOpts
			name: @getNameOpt()
			data:
				check: (v) ->
					CUI.isFunction(v?.hasOwnProperty) or CUI.isFunction(v)
			data_not_for_others:
				default: false
				check: Boolean
			disabled:
				default: false
				check: (v) ->
					isBoolean(v) or CUI.isFunction(v)
			disabled_depends_on_data:
				check: Function
			tooltip:
				check: "PlainObject"
			hidden:
				check: Boolean
			form: {}
			undo_support:
				default: true
				check: Boolean
			# set undo_support, check_changed, mark_changed all at once
			undo_and_changed_support:
				check: Boolean
			mark_changed:
				default: true
				check: Boolean
			check_changed:
				default: true
				check: Boolean
			onDataChanged:
				check: Function
			onDataInit:
				check: Function
			onInit:
				check: Function
			onRender:
				check: Function

	readOpts: ->
		if @opts.hasOwnProperty("undo_and_changed_support")
			for k in ["undo_support", "check_changed", "mark_changed"]
				if not @opts.hasOwnProperty(k)
					@opts[k] = @opts.undo_and_changed_support
		super()

	initTemplate: ->
		@registerTemplate(@getTemplate())

	getTemplate: ->
		new Template
			name: "data-field"

	isResizable: ->
		false

	init: ->

	debug: ->
		CUI.debug "----"+@+"----", @
		if @__data
			CUI.debug "data:", @getData()
			CUI.debug "value:", @getValue()
			CUI.debug "init-value:", @getInitValue()
			CUI.debug "check-changed-value:", @getCheckChangedValue()

	toString: ->
		"[#{@__cls}[#{@__uniqueId}, #{@_name or '<no name>'}]}"


	reload: ->
		@remove()
		@render()
		@displayValue()

	remove: (purge = false) ->
		@callOnOthers("remove")
		if not @isDestroyed()
			@empty()
		@__isRendered = false

	getNameOpt: ->
		check: String

	getLabel: ->
		@_label

	setForm: (form) ->
		assertImplements(form, [
			"getFieldsByName"
			"getFieldByIdx"
			"getData"
			"getFields"
		])
		@__form = form
		if not @getForm().getFormPath
			return @

		@setFormDepth()
		@

	setFormDepth: ->
		# update depth
		path = @getFormPath()
		@updateDepthAttribute("cui-data-field-form-depth", path.length)
		@DOM.attr("cui-data-field-form-root", path[0].getUniqueId())
		# update our children
		@

	updateDepthAttribute: (name, depth) ->
		@DOM.attr(name, depth)

	getFormPath: (include_self=false, path=[], call=0) ->
		assert(call < 100, "CUI.DataField.getPath", "Recursion detected.")

		if @getForm()?.getFormPath
			@getForm().getFormPath(true, path, call+1)

		if include_self
			path.push(@)

		return path

	getForm: ->
		@__form

	# short-cut to get other field
	getOtherField: (name) ->
		@__form?.getFieldsByName(name)?[0]

	getRootForm: ->
		if @__form
			@__form.getRootForm()
		else if @ instanceof Form
			@
		else
			null

	__initDisabled: ->
		if @_disabled and (@_disabled == true or @_disabled.call(@, @))
			@disable()
		return

	enable: ->
		@removeClass("cui-data-field-disabled")
		@callOnOthers("enable")
		@

	disable: ->
		@addClass("cui-data-field-disabled")
		@callOnOthers("disable")
		@

	isDisabled: ->
		@hasClass("cui-data-field-disabled")

	isHidden: ->
		@hasClass("cui-data-field-hidden")

	isShown: ->
		!@isHidden()

	setOpacity: (opacity) ->
		if opacity == 1
			if @__opacity != 1
				@DOM.css("opacity", "")
		else
			@DOM.css("opacity", opacity)
		@__opacity = opacity
		@

	updateData: (data) ->
		if CUI.isFunction(@_data)
			@__data = @_data.call(@, data, @)
		else
			@__data = data
		@displayValue()

	setData: (data, init_data=true) ->
		if @__data and @_data and not CUI.isFunction(@_data)
			# CUI.debug "private data already set", @_data
			# we have private data set, ignore a setData from
			# e.g. a Form, as the private data is more important
			# than the Form data
			return

		assert(not @__data, "#{@}.setData", "data is already set.", opts: @opts, data: @__data)

		if CUI.isFunction(@_data)
			@__data = @_data.call(@, data, @)
		else
			@__data = data

		assert(CUI.isPlainObject(@__data) or @__data?.hasOwnProperty?(@getName()), "#{@}.setData", "data needs to be PlainObject or have a property \"#{@getName()}\".", data: data, opts: @opts)

		# CUI.debug "initData", @__data, @__data.hasOwnProperty

		if @setDataOnOthers()
			@callOnOthers("setData", @__data, init_data)

		if init_data
			@initData()
		# CUI.debug "setting data", @__uniqueId, @__data
		@

	setDataOnOthers: ->
		not @_data_not_for_others

	hide: (trigger_event=false) ->
		@addClass("cui-data-field-hidden")
		@callOnOthers("hide")
		if trigger_event
			Events.trigger
				type: "form-check-row-visibility"
				node: @DOM
				info:
					element: @
		@

	show: (trigger_event=false) ->
		@removeClass("cui-data-field-hidden")
		@callOnOthers("show")
		if trigger_event
			# FIXME: too many events were triggered and I dont
			# know where this is really
			Events.trigger
				type: "form-check-row-visibility"
				node: @DOM
				info:
					element: @
		@

	isRendered: ->
		@__isRendered

	render: ->
		assert(not @__isRendered, "#{@__cls}.render", "Cannot be called when already rendered.", opts: @opts, dataField: @)

		# for p of @__tmpl.map
		# 	content = @["__#{p}"]
		# 	if isNull(content)
		# 		continue
		# 	@append(content, p)

		@__isRendered = true
		if @isDisabled()
			@disable()
		if @isHidden()
			@hide()
		@setOpacity()
		@callOnOthers("render")
		@_onRender?(@)
		@

	displayValue: ->
		assert(not @isDestroyed(), "#{@__cls}.displayValue", "DataField already destroyed, cannot display value.", data_field: @)

		assert(@__isRendered, "#{@__cls}.displayValue", "not rendered yet, cannot display.", opts: @opts, data: @__data)
		@checkChanged()
		@callOnOthers("displayValue")

	start: ->
		assert(not @__isRendered, "#{@__cls}.start", "Cannot be called when already rendered.", opts: @opts, dataField: @)
		@__initDisabled()
		@render()
		@displayValue()
		@

	getAllDataFields: (all=false)->
		@getDataFields(true)

	getDataFields: (all=false, data_fields = [])->
		if @isDataField() or all
			data_fields.push(@)
		@callOnOthers("getDataFields", all, data_fields)
		data_fields


	isDataField: ->
		@hasData()

	# calls method on all DataFields
	# inside the "right" side
	callOnOthers: (func, args...) ->
		if @getFields
			other_fields = @getFields(func).slice(0)
		else
			other_fields = []

		# for p in ["right", "top", "bottom"]
		# 	other = @["__#{p}"]
		# 	if not other
		# 		continue

		# 	if other instanceof DataField
		# 		other_fields.push(other)
		# 	else if CUI.isArray(other)
		# 		for r in other
		# 			if r instanceof DataField
		# 				other_fields.push(r)

		# if @__form_data_field_right
		# 	other_fields.push(@__form_data_field_right)

		for df in other_fields
			if not df or not CUI.isFunction(df[func])
				assert(false, "CUI.DataField.callOnOthers", "Field found in other fields has no Function \"#{func}\".", field: df, other_fields: other_fields)
				return @

			df[func].apply(df, args)
		@

	# getFormDataFieldRight: ->
	# 	@__form_data_field_right

	getData: ->
		@__data

	hasData: ->
		not isEmpty(@_name) and @__data

	getArrayFromOpt: (opt, event, allowDeferred=false) ->
		v = @["_#{opt}"]
		if CUI.isFunction(v)
			arr = v.call(@, @, event)
			assert(CUI.isArray(arr) or (isPromise(arr) and allowDeferred), "#{@__cls}.getArrayFromOpt", "opts.#{opt}(dataField) did not return Array or Promise.", options: arr, opts: @opts)
		else
			arr = v
		return arr

	getPromiseFromOpt: (opt, event) ->
		ret = @getArrayFromOpt(opt, event, true)
		if isPromise(ret)
			ret
		else
			CUI.resolvedPromise(ret)

	getName: ->
		@_name


	# data field needs to return the empty value
	# to init data
	#
	getDefaultValue: ->

	# get the current value of the data field
	getValue: ->
		@__data[@_name]

	checkValue: ->
		throw new Error("#{@__cls}.checkValue is unimplemtented.")
		@

	setValue: (v, flags = {}) ->
		if not @hasData()
			if @isRendered()
				@displayValue()
			return @

		if v == @getValue()
			return @

		try
			@checkValue(v, flags)
		catch e
			if e not instanceof CheckValueError
				throw(e)
			throw(new Error("#{@__cls}.setValue: "+v+", Error: "+e))

		if flags.no_trigger not in [false, true]
			flags.no_trigger = true
		@storeValue(v, flags)
		if @isRendered()
			@displayValue()
		@

	getInitValue: ->
		undo = @getUndo()
		if not undo
			return undefined
		undo.values[0]

	getLastValue: ->
		undo = @getUndo()
		if not undo
			return undefined
		undo.values[undo.idx-1]

	reset: ->
		if undo = @getUndo()
			@__data[@_name] = undo.values[0]
			undo.values.splice(1)
			undo.idx = 0
			@displayValue()
			@triggerDataChanged
				action: "reset"
				undo_idx: 0
		@

	undo: ->
		if undo = @getUndo()
			if undo.idx == 0
				return false

			@__data[@_name] = undo.values[--undo.idx]

			@displayValue()
			@triggerDataChanged
				action: "undo"
				undo_idx: undo.idx

			return true
		return null

		@

	redo: ->
		if undo = @getUndo()
			if undo.idx == undo.values.length - 1
				return false

			@__data[@_name] = undo.values[++undo.idx]
			@displayValue()
			@triggerDataChanged
				action: "redo"
				undo_idx: undo.idx

			return true
		return null
		@

	goto: (idx) ->
		if undo = @getUndo()
			if isUndef(undo.values[idx])
				return false
			undo.idx = idx
			@__data[@_name] = undo.values[undo.idx]
			# CUI.debug @__uniqueId, @__data[@_name]
			@displayValue()
			@triggerDataChanged
				action: "goto"
				undo_idx: idx

			return true
		return null


	# data fields need to initialise the data array
	initData: ->
		@_onDataInit?(@, @__data)

		# CUI.debug "initData", @__cls, @_name, @__data
		if not @hasData()
			return

		@initValue()

		undo = @getUndo()
		if CUI.isPlainObject(undo) and CUI.isEmptyObject(undo)
			undo.values = [ @getValue() ]
			undo.idx = 0

		if isUndef(@getCheckChangedValue())
			@setCheckChangedValue(
				if undo
					@getInitValue()
				else
					@getValue()
			)

		if @setDataOnOthers()
			@callOnOthers("initData")

		@

	initValue: ->
		if isUndef(@__data[@_name])
			# CUI.debug "initValue", @getName(), @__data[@_name], @getDefaultValue()
			@__data[@_name] = @getDefaultValue()
		@

	setCheckChangedValue: (value) ->
		assert(@hasData(), "#{@__cls}.setCheckChangedValue", "Cannot set without data.", opts: @opts, value: value, dataField: @)
		if @_check_changed == false
			return undefined
		@__checkChangedValue = JSON.stringify(value)

	getCheckChangedValue: ->
		if @_check_changed == false
			return undefined
		assert(@hasData(), "#{@__cls}.getCheckChangedValue", "No data set.", opts: @opts)
		@__checkChangedValue

	getUndo: ->
		if not @hasData() or @_undo_support == false
			return false

		if isUndef(@__data._undo)
			@__data._undo = {}
		# CUI.debug @__data, @__data._undo, @_name
		if isUndef(undo = @__data._undo[@_name])
			undo = @__data._undo[@_name] = {}
		undo


	# stores a user changed value and
	# manages old and new values
	storeValue: (value, flags={}) ->
		if not @hasData()
			return false

		store_last = not flags.prior_activate and flags.initial_activate != true and flags.no_store != true

		if store_last and (undo = @getUndo())
			# CUI.debug(".undo[#{@_name}][#{@undo.idx}]", @__data[@_name], ">", value)
			undo.values[++undo.idx] = value
			# clean evertyhing after the undo idx
			undo.values.splice(undo.idx+1)

		@__data[@_name] = value

		@checkChanged()
		if store_last and not flags.no_trigger
			# CUI.debug @__cls+".storeValue: triggering data-changed: ", @
			@triggerDataChanged
				action: "store"
				undo_idx: undo?.idx
		@

	triggerDataChanged: (info={}) ->
		info.element = @

		Events.trigger
			type: "data-changed"
			node: @DOM
			info: info

	isChanged: ->
		if not @hasData() or @_check_changed == false
			return undefined

		@getCheckChangedValue() != JSON.stringify(@getValue())

	checkChanged: ->
		if @_check_changed == false
			return

		if @isChanged()
			@addClass("changed")
		else
			@removeClass("changed")
		@

	getChangedMarker: ->
		if @_mark_changed == false or @_check_changed == false
			return
		@checkChanged()
		$div(CUI.DataField.changed_marker_css_class)

	destroy: ->
		@remove(true)
		@__tooltip?.destroy()
		super()

	@new: (field, delete_keys=[], default_data={}) ->
		if field instanceof DataField
			return field

		assert(CUI.isPlainObject(field), "CUI.DataField.new", "field needs to be PlainObject.", field: field, delete_keys: delete_keys, default_data: default_data)

		field_opts = {}
		for k, v of field
			if k == "type"
				type = v
				continue
			if delete_keys.indexOf(k) > -1
				continue
			# if v instanceof Icon
			#	field_opts[k] = v.copy()
			#	continue
			field_opts[k] = v

		for k, v of default_data
			if field_opts.hasOwnProperty(k)
				continue
			field_opts[k] = v

		assert(CUI.isFunction(type), "CUI.DataField.new", "type is unknown: \"#{type}\".", field: field)
		_field = new type(field_opts)
		assert(_field instanceof CUI.DataField, "CUI.DataField.new", "field.type needs to be of class DataField, but is #{getObjectClass(_field)}.", field: field)
		return _field

DataField = CUI.DataField


CUI.Events.registerEvent
	type: "data-changed"
	bubble: true