class Form extends DataField

	initOpts: ->
		super()
		@addOpts
			fields:
				mandatory: true
				check: (v) ->
					$.isFunction(v) or $.isArray(v)
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
				check: Boolean
			maximize_horizontal:
				check: Boolean
			maximize_vertical:
				check: Boolean
			top: {}
			bottom: {}


	readOpts: ->
		super()
		if @_horizontal == 1
			@__horizontal = false
		else
			@__horizontal = @_horizontal

		vl_opts = class: "cui-form cui-padding-reset cui-form-appearance-"+@_appearance

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

		@__verticalLayout = new VerticalLayout(vl_opts)
		@__verticalLayout

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
			if $.isFunction(field)
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

	initFields: ->
		@__fields = @__createFields()

	setData: (data) ->
		if @_name and not $.isFunction(data)
			# CUI.debug "init data ", @_name, data, 1
			if isUndef(data[@_name])
				data[@_name] = {}
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
		if $.isFunction(@_fields) and @__fields and @__fields.length == 0
			# CUI.debug "fields depends on data...", @__data
			@initFields()
			@callOnOthers("setData", @__data)
		@

	# this hides a form row, if all
	# datafields in it are hidden
	__setRowVisibility: (tr) ->
		df = DOM.data(tr[0], "data-field")
		if not df
			CUI.warn("Form.__setRowVisibility", "data-field not found", df, @)
			return

		for _f in df.getAllDataFields()
			if not _f.isHidden()
				tr.css("display", "")
				return
		tr.css("display", "none")

	render: ->
		@renderTable()
		super()
		@

	getTable: ->
		@table

	renderTable: ->
		@table = $table("cui-form-table")

		Events.listen
			node: @table
			type: "form-check-row-visibility"
			call: (ev) =>
				tr = $(ev.getNode()).closest(".cui-form-tr")
				# CUI.debug "form check row visibiltiy", ev, tr
				ev.stopPropagation()
				if not tr.hasClass("cui-form-tr-vertical")
					return
				if tr.length
					@__setRowVisibility(tr)

		if @_class_table
			@table.addClass(@_class_table)

		# add all classes from the top level
		for cls in (@_class or "").split(/\s+/)
			if isEmpty(cls)
				continue
			@table[0].classList.add(cls+"-table")

		td_classes = ("cui-padding cui-form-td cui-form-#{k}" for k in ["left", "center", "right"])

		# CUI.error "Form.renderTable", @table[0], @__horizontal, @getFields().length

		getAppend = (v, info=@) =>
			if $.isPlainObject(v) # assume a label constructor
				# new Label(v).DOM
				new MultilineLabel(v).DOM
			else if isString(v)
				# new Label(text: v).DOM
				new MultilineLabel(text: v).DOM
			else if v?.DOM
				v.DOM
			else if $.isFunction(v)
				getAppend(v(info))
			else
				v

		if @_header
			tr_head = $tr("cui-form-tr-head").appendTo(@table)

			for td_class, idx in td_classes
				head = @_header[idx]
				th = $th(td_class).appendTo(tr_head)

				if not head
					continue
				th.append(getAppend(head.label))

		has_left = false

		for _field, idx in @getFields()
			if @__horizontal and
				(((@__horizontal == true) and idx == 0) or
				(@__horizontal > 1 and idx % @__horizontal == 0))
					tr_labels = $tr("cui-form-tr cui-form-tr-horizontal cui-form-tr-labels").appendTo(@table)
					tr_fields = $tr("cui-form-tr cui-form-tr-horizontal cui-form-tr-fields").appendTo(@table)
					tr_rights = $tr("cui-form-tr cui-form-tr-horizontal cui-form-tr-rights").appendTo(@table)

			fopts = _field._form or {}

			tds = []
			if _field.__form_data_field_right
				right = _field.__form_data_field_right
			else
				right = fopts.right

			for app, idx in [fopts, _field, right]
				attrs = {}
				if skip_next
					skip_next = false
					continue
				if idx == 0
					if app.label
						content = getAppend(app.label, _field)
					else if app.use_field_as_label
						assert(not @__horizontal, "Form.render", "form.use_field_as_label not supported for horizontal Forms", opts: @opts)
						content = getAppend(_field, _field)
						attrs.colspan = 2
						skip_next = true
					else
						content = null
				else
					content = getAppend(app, _field)

				if idx == 0 and content
					has_left = true

				if idx == 2 and content
					has_right = true

				tds.push($td(td_classes[idx], attrs).append(content))

			if @__horizontal
				tr_labels.append(tds[0])
				tr_fields.append(tds[1])
				tr_rights.append(tds[2])
			else
				tr = $tr("cui-form-tr cui-form-tr-vertical").appendTo(@table)

				# used to set row visibility
				DOM.data(tr[0], "data-field", _field)
				tr.append(tds)

		if @__horizontal == false
			if has_left
				@table.addClass("cui-form-table-has-left-column")
			else
				@table.addClass("cui-form-table-has-not-left-column")

			if has_right
				@table.addClass("cui-form-table-has-right-column")
			else
				@table.addClass("cui-form-table-has-not-right-column")


		Events.listen
			type: "data-changed"
			node: @table
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

		@getLayout().replace(@table, "center")
		@__setChildDepths()
		@table

	__setChildDepths: (unique_id = @getUniqueId()) ->
		# checks all children for their depth levels, takes the
		# max
		#
		max_depth = 0
		forms = [@]
		for dom_el in CUI.DOM.matchSelector(@getLayout().DOM[0], "[cui-data-field-form-depth][cui-data-field-form-root=\"#{unique_id}\"]")
			df = DOM.data(dom_el, "element")
			if df instanceof Form
				forms.push(df)

			depth = parseInt(dom_el.getAttribute("cui-data-field-form-depth"))
			# CUI.debug depth, df
			if depth > max_depth
				max_depth = depth

		for df in forms
			curr_depth = df.DOM.attr("cui-data-field-form-depth")
			df.updateDepthAttribute("cui-data-field-form-child-depth", max_depth - curr_depth)

		@


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

	getFieldsByName: (name, found_fields = []) ->
		assert(isString(name), "#{@__cls}.getFieldsByName", "name must be String.", name: name)

		# CUI.debug @dataFields, @, typeof(@getFields)

		for _field in @getFields("getFieldsByName")
			if _field instanceof Form
				_field.getFieldsByName(name, found_fields)
				continue

			# CUI.debug _field, getObjectClass(_field), name, _field.getName
			if _field.getName() == name
				found_fields.push(_field)
				continue

		# if found_fields.length == 0
		#	CUI.warn("#{@__cls}.getFieldsByName: No field found matching \"#{name}\".")

		return found_fields

	setFormDepth: ->
		# set the form depth on us
		super()
		# set form depth on our children
		for f in @getFields("setFormDepth")
			f.setFormDepth()
		@

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
			DOM.remove(@table)
			@table = null
		super()


CUI.Events.registerEvent
	type: "form-check-row-visibility"
	bubble: true
