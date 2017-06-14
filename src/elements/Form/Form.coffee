###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Form extends CUI.DataField

	initOpts: ->
		super()
		@addOpts
			fields:
				mandatory: true
				check: (v) ->
					CUI.isFunction(v) or CUI.isArray(v)
			class_table:
				check: String
			header:
				check: Array
			# true: all fields horizontal
			# int: n fields horizontal
			horizontal:
				default: false
				check: (v) ->
					isBoolean(v) or (isInteger(v) and v > 0)
			appearance:
				default: "normal"
				mandatory: true
				check: ["normal","separators"]
			# passed to underlying vertical layout
			maximize:
				default: false
				check: Boolean
			maximize_horizontal:
				check: Boolean
			maximize_vertical:
				check: Boolean
			render_as_block:
				check: Boolean
			render_as_grid:
				default: false
				mandatory: true
				check: Boolean
			top: {}
			bottom: {}


	readOpts: ->
		super()
		if @_horizontal == 1
			@__horizontal = null
		else
			@__horizontal = @_horizontal

		if CUI.__ng__
			if @__horizontal and @__horizontal != true
				console.error("new Form: opts.horizontal not supported in CUI.Form 'ng'.", opts: @opts)
			if @_header
				console.error("new Form: opts.header not supported in CUI.Form 'ng'.", opts: @opts)

		vl_opts = class: "cui-form cui-form-appearance-"+@_appearance

		for k in [
			"maximize"
			"maximize_horizontal"
			"maximize_vertical"
		]
			if @hasSetOpt(k)
				vl_opts[k] = @getSetOpt(k)

		if @hasSetOpt("top")
			vl_opts.top = content: @_top

		if @hasSetOpt("bottom")
			vl_opts.bottom = content: @_bottom

		if @_form?.checkbox
			# the form has a checkbox (for form context)
			assert(CUI.isPlainObject(@_form.checkbox, "new Form", "opts.form.checkbox needs to be PlainObject.", opts: @opts))
			assert(@_name, "new Form", "opts.form.checkbox requires opts.name to be set.", opts: @opts)
			assert(not @_form.checkbox.data, "new Form", "opts.form.checkbox cannot have 'data' set.", opts: @opts)
			assert(not @_form.checkbox.name, "new Form", "opts.form.checkbox cannot have 'name' set.", opts: @opts)

			cb_opts = copyObject(@_form.checkbox, true)

			cb_opts.data = @__checkbox_data = checkbox: false
			cb_opts.name = "checkbox"

			@__checkbox = new Checkbox(cb_opts).start()
			Events.listen
				type: "data-changed"
				node: @__checkbox
				call: =>
					if @__checkbox_data.checkbox
						@__checkbox_set_data[@_name] = @__checkbox_form_data
					else
						delete(@__checkbox_set_data[@_name])

		else
			@checkbox = null

		@__verticalLayout = new VerticalLayout(vl_opts)

		if @_render_as_grid
			@__verticalLayout.addClass("cui-form--grid")

		@__verticalLayout


	getCheckbox: ->
		@__checkbox

	initTemplate: ->
		@registerTemplate(@__verticalLayout.getLayout())

	getLayout: ->
		@__verticalLayout

	__createFields: ->
		fs = []
		fields = @getArrayFromOpt("fields")
		for field, idx in fields
			if not field
				continue
			if CUI.isFunction(field)
				_field = DataField.new(field(@))
			else
				_field = DataField.new(field)

			_field.setForm(@)
			fs.push(_field)
		fs

	getNameOpt: ->
		name:
			check: String

	init: ->
		@__initUndo()
		@initFields()
		@setFormDepth()

	initFields: ->
		@__fields = @__createFields()
		@__fields

	reload: ->
		@initFields()
		@callOnOthers("setData", @__data)
		super()

	displayValue: ->
		if @__checkbox
			@__checkbox.displayValue()
		super()

	getParentData: ->
		@__parent_data or @__data

	setData: (data) ->
		if @_name and @__checkbox
			assert(not CUI.isFunction(data), "Form.setData", "opts.data cannot be set by Function when data is managed by opts.form.checkbox.", opts: @opts)

		if @_name and not CUI.isFunction(data)
			# CUI.debug "init data ", @_name, data, 1
			#

			if @__checkbox
				@__checkbox_set_data = data
				if data[@_name]
					@__checkbox_form_data = data[@_name]
					@__checkbox_data.checkbox = true
					# @show()
				else
					@__checkbox_form_data = {}
					@__checkbox_data.checkbox = false
					# @hide()

				super(@__checkbox_form_data)

			else
				if isUndef(data[@_name])
					data[@_name] = {}

				@__parent_data = data
				super(data[@_name])
		else
			super(data)

		# sometimes fields depend on data, we need to see if
		# that is the case
		# these functions do this:
		#
		# fields: ->
		#    if not df.getData()
		#       return []
		#    else
		#       return [...]
		#
		# it can happen, like in FormPopover, that fields
		# are not yet initialized
		#
		if CUI.isFunction(@_fields) and @__fields and @__fields.length == 0
			# CUI.debug "fields depends on data...", @__data
			@initFields()
			@callOnOthers("setData", @__data)
		@

	# this hides a form row, if all
	# datafields in it are hidden
	__setRowVisibility: (tr) ->
		df = DOM.data(tr, "data-field")
		if not df
			console.warn("Form.__setRowVisibility", "data-field not found", df, @)
			return

		for _f in df.getAllDataFields()
			if not _f.isHidden()
				CUI.DOM.showElement(tr)
				return

		CUI.DOM.hideElement(tr)
		return

	render: ->
		# we need fields rendered before we render
		# us, so that <label for=...> can work, just
		# to be safe, for "ng" only until we know
		# it does not break anything
		super()
		@renderTable()
		if not @hasContentForAppend() or @__checkbox?.getValue() == false
			CUI.DOM.hideElement(@DOM)
		else
			CUI.DOM.showElement(@DOM)
		@

	getTable: ->
		assert(not CUI.__ng__, "Form.getTable is obsolete in \"ng\" design.", form: @)
		@table


	renderAsBlock: ->
		if @getCheckbox()
			return true

		if @_render_as_block == false
			return false

		if @_render_as_block == true
			return true

		fields = @getFields()
		for f in fields
			if f._form?.label
				return true

			if f instanceof Form
				if f.renderAsBlock()
					return true

		return false

	hasContentForAppend: ->
		if @__fields?.length > 0
			true
		else
			false

	renderTable: ->

		layout = @getLayout()

		form_depth = parseInt(CUI.DOM.getAttribute(@DOM, "cui-form-depth"))

		CUI.DOM.setAttribute(layout.center(), "cui-form-depth", form_depth)

		layout.empty("center")
		container = layout.center()

		Events.listen
			node: container
			type: "form-check-row-visibility"
			instance: @
			call: (ev) =>
				tr = CUI.DOM.closest(ev.getNode(), ".cui-form-tr,.cui-form-block,.cui-form-row")
				# console.error "check row visibility", ev, tr
				ev.stopPropagation()
				if tr
					@__setRowVisibility(tr)
				return

		table = null
		table_has_left = null

		append = (stuff, to) =>
			if not to
				layout.append(stuff, "center")
			else if stuff
				to.appendChild(stuff)
			return

		# getTable = =>
		# 	table = jQuery(CUI.DOM.element("TABLE", class: "cui-form-table"))

		# 	if @_class_table
		# 		table.addClass(@_class_table)

		# 	# add all classes from the top level
		# 	for cls in (@_class or "").split(/\s+/)
		# 		if isEmpty(cls)
		# 			continue
		# 		table.classList.add(cls+"-table")

		# CUI.error "Form.renderTable", @table[0], @__horizontal, @getFields().length

		if @_class_table
			CUI.DOM.addClass(container, @_class_table)

		get_append = (v, info=@) =>
			if v instanceof Form
				v.DOM
			else if CUI.isPlainObject(v) # assume a label constructor
				# new Label(v).DOM
				new MultilineLabel(v).DOM
			else if isString(v)
				# new Label(text: v).DOM
				new MultilineLabel(text: v).DOM
			else if v?.DOM
				v.DOM
			else if CUI.isFunction(v)
				get_append(v(info))
			else if isEmpty(v)
				null
			else
				v

		get_label = (field, register = false) =>
			lbl = field._form?.label
			if not lbl
				return

			if isString(lbl)
				label = CUI.DOM.element("label")
				label.textContent = lbl
				field.registerLabel(label)
				return label

			return get_append(lbl)

		fields = @getFields()
		len = fields.length
		field_idx = -1

		field_has_left = (_field) =>

			fopts = _field?._form or {}
			if fopts.label
				return true

			if fopts.use_field_as_label
				console.error("Form: use_field_as_label is obsolete in \"ng\" design", @)
				return true

			return false

		render_next_field = =>
			field_idx = field_idx + 1
			if field_idx == len
				# we are done
				return

			field = fields[field_idx]
			hint_div = null
			grid = field._form?.grid

			if field._form and (not isNull(field._form.hint) or field._form.right)

				add_hint_div = =>
					if hint_div
						return
					hint_div = CUI.DOM.element("DIV", class: "cui-form-hint", "data-for-field": field.getUniqueId())

				if not isNull(field._form.hint)
					add_hint_div()
					if isString(field._form.hint)
						hint_div.appendChild(new Label(class: "cui-form-hint-label", icon: field._form.hint_icon, text: field._form.hint, multiline: true, markdown: true).DOM)
					else
						CUI.DOM.append(hint_div, field._form.hint)

				if field._form.right
					add_hint_div()

					console.error("Form.renderTable: form.right is deprecated. Use 'hint' instead. Form:", @, "Field:", field, "Field#", field_idx)
					# append deprecated stuff to the hint div
					# you should use ".hint" instead
					append(get_append(field._form.right), hint_div)

			if field instanceof Form and field.renderAsBlock()
				level = parseInt(CUI.DOM.getAttribute(@DOM, "cui-form-depth"))+1
				if not level
					level = 1

				if level > 3
					level = 3

				cb = field.getCheckbox()

				if cb
					do (cb, field) =>
						Events.listen
							type: "data-changed"
							node: cb
							call: =>
								if cb.getValue()
									blk.addClass("cui-form-block--checkbox-checked")
									CUI.DOM.showElement(field.DOM)
								else
									blk.removeClass("cui-form-block--checkbox-checked")
									CUI.DOM.hideElement(field.DOM)
					left_side = cb
				else
					left_side = get_label(field)

				blk = new CUI.Block
					class: "cui-form-block"
					level: level
					header: left_side
					content: [
						get_append(field)
						hint_div
					]

				if cb
					blk.addClass("cui-form-block--has-checkbox")

					if cb.getValue()
						blk.addClass("cui-form-block--checkbox-checked")
					else
						blk.removeClass("cui-form-block--checkbox-checked")

				append(blk)

				# used to set row visibility
				DOM.data(blk.DOM, "data-field", field)

				@__setRowVisibility(blk.DOM)

				table = null
				table_has_left = null
				render_next_field()
				return

			if not table
				# check if next subform has a left side
				#
				has_left = false
				for idx in [field_idx...len] by 1
					if field_has_left(fields[idx])
						has_left = true
						break

				if not has_left
					table = CUI.DOM.element("DIV", class: "cui-form-container")
					table_has_left = false
				else
					table = CUI.DOM.element("DIV", class: "cui-form-table")
					table_has_left = true

				if @__horizontal
					CUI.DOM.addClass(table, "cui-form--horizontal")

				CUI.DOM.setAttribute(table, "cui-form-depth", form_depth)

				append(table)

			name = field.getName()
			classes = []
			if name
				classes.push("cui-form-field-name--"+name)

			if field instanceof Select
				classes.push("cui-form-field-type--select")
			else if field instanceof Checkbox
				classes.push("cui-form-field-type--checkbox")
			else if field instanceof Input
				classes.push("cui-form-field-type--input")

			if table_has_left
				tr = CUI.DOM.element("DIV", class: "cui-form-tr "+classes.join(" "), "data-for-field": field.getUniqueId())

				td = CUI.DOM.element("DIV", class: "cui-form-td cui-form-key")
				append(get_label(field, true), td)
				tr.appendChild(td)

				td = CUI.DOM.element("DIV", class: "cui-form-td cui-form-value")
				append(get_append(field), td)
				append(hint_div, td)
				tr.appendChild(td)

				# used to set row visibility
				DOM.data(tr, "data-field", field)

				@__setRowVisibility(tr)

				if grid
					tr.setAttribute("data-cui-grid", grid)

				table.appendChild(tr)
			else
				row = CUI.DOM.element("DIV", class: "cui-form-row "+classes.join(" "), "data-for-field": field.getUniqueId())
				row.appendChild(get_append(field))
				append(get_append(field), row)
				append(hint_div, row)

				# used to set row visibility
				DOM.data(row, "data-field", field)

				if grid
					row.setAttribute("data-cui-grid", grid)

				table.appendChild(row)

			render_next_field()



		render_next_field()

		Events.listen
			type: "data-changed"
			node: container
			instance: @
			call: (ev, info) =>
				if not info.element
					return

				# CUI.debug "Form data-changed", @getData()

				if info.action in ["goto", "reset"]
					return

				@__undo.log[++@__undo.idx] =
					name: info.element.getName()
					undo_idx: info.undo_idx
					action: info.action

				@__undo.log.splice(@__undo.idx+1)
				return

		container

	unregisterTableListeners: ->
		Events.ignore({node: @getLayout().center(), instance: @})

	remove: ->
		@unregisterTableListeners()
		super()

	__initUndo: ->
		if @__undo
			return

		@__undo =
			log: []
			idx: -1


	getLog: ->
		log = []
		for l in @__undo.log
			log.push("#{l.name} #{l.action} #{l.undo_idx}")
		log.join("\n")

	undo: ->
		if @__undo.idx == -1
			return false

		if @__undo.idx == 0
			# we dont exactly know which
			# field we need to tell to
			for df in @getFields()
				df.goto(@__undo.idx--)
			return true

		l = @__undo.log[--@__undo.idx]
		# CUI.debug ""+@getRootForm(), l.name, @getRootForm().getFieldsByName(l.name)
		for f in @getRootForm().getFieldsByName(l.name)
			f.goto(l.undo_idx)
		return true

	redo: ->
		if @__undo.idx == @__undo.log.length - 1
			return false

		l = @__undo.log[++@__undo.idx]
		for f in @getRootForm().getFieldsByName(l.name)
			f.goto(l.undo_idx)
		return true

	getFieldByIdx: (idx) ->
		assert(isInteger(idx) and idx >= 0, "#{@__cls}.getFieldByIdx", "idx must be Integer.", idx: idx)
		@getFields("getFieldByIdx")[idx]

	updateHint: (field_name, hint, trigger_resize = true) ->
		field = @getFieldsByName(field_name)[0]
		if not field
			console.error("Form.updateHint:", field_name, "not found.")
			return

		els = CUI.DOM.matchSelector(@getLayout().DOM, ".cui-form-hint[data-for-field='"+field.getUniqueId()+"'] > .cui-form-hint-label")
		if els.length != 1
			console.error("Form.updateHint:", field_name, "not found in DOM.")
			return

		CUI.DOM.data(els[0]).element.setText(hint)

		if trigger_resize
			Events.trigger
				type: "content-resize"
				node: els[0]
		@

	__setClassOnField: (field_name, cls, add_remove) ->
		for field in @getFieldsByName(field_name)
			row = CUI.DOM.closest(field.DOM, "[data-for-field]")
			if not row
				continue

			if add_remove
				CUI.DOM.addClass(row, cls)
			else
				CUI.DOM.removeClass(row, cls)
		@

	addClassToField: (field_name, cls) ->
		@__setClassOnField(field_name, cls, true)

	removeClassFromField: (field_name, cls) ->
		@__setClassOnField(field_name, cls, false)

	getFieldsByName: (name, found_fields = []) ->
		assert(isString(name), "#{@__cls}.getFieldsByName", "name must be String.", name: name)

		# CUI.debug @dataFields, @, typeof(@getFields)

		for _field in @getFields("getFieldsByName")
			# CUI.debug _field, getObjectClass(_field), name, _field.getName
			if _field.getName() == name
				found_fields.push(_field)

			if _field instanceof Form
				_field.getFieldsByName(name, found_fields)


		# if found_fields.length == 0
		#	CUI.warn("#{@__cls}.getFieldsByName: No field found matching \"#{name}\".")

		return found_fields

	getFields: (func) ->
		# CUI.debug "form get fields", @__fields
		@__fields

	isDataField: ->
		if @_name
			return true
		else
			return false

	hasData: ->
		false

	getValue: ->
		# CUI.debug "getValue FORM", @_name, @__data
		if not @_name
			data = {}
			for field in @getDataFields()
				if k = field.getName()
					data[k] = field.getValue()
			return data
		else
			# CUI.debug "getValue HENK", @_name, @__data
			data = copyObject(@__data, true)
			delete(data._undo)
			return data

	isChanged: ->
		for _field in @getFields()
			if _field.isChanged()
				return true
		return false

	destroy: ->
		if @table
			@unregisterTableListeners()
			DOM.remove(@table)
			@table = null
		super()


CUI.Events.registerEvent
	type: "form-check-row-visibility"
	bubble: true

Form = CUI.Form