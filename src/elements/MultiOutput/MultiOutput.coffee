###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./MultiOutput.html'));

class CUI.MultiOutput extends CUI.DataField
	initOpts: ->
		super()
		@addOpts
			control:
				mandatory: true
				check: CUI.MultiInputControl
			showOnlyPreferredKey:
				check: Boolean
				default: true
			markdown:
				mandatory: true
				default: false
				check: Boolean
			markdown_opts:
				check: "PlainObject"
			text_node_func:
				check: Function

	readOpts: ->
		super()
		@__keyTemplates = {}

	render: ->
		super()
		if @_showOnlyPreferredKey
			key = @_control.getPreferredKey()
			CUI.util.assert(key, "Output.displayValue", "MultiInputControl: no preferred key set.", control: @_control)
			label = @__getLabel(key.name)
			@replace(label)
		else
			for key, idx in @_control.getKeys()
				value = @getValue()[key.name]
				if CUI.util.isEmpty(value)
					continue

				template = @__buildTemplateForKey(key)
				@__keyTemplates[key.name] = template

				@append(template)

			@__updateListener = CUI.Events.listen
				type: "multi-input-control-update"
				node: @DOM
				call: =>
					@__hideShowElements()
			@__hideShowElements()

		return @

	__getLabel: (name) ->
		labelOpts =
			multiline: true
			text: @getValue()[name]
			text_node_func: @_text_node_func
			markdown: @_markdown
			markdown_opts: @_markdown_opts

		if @_ui
			labelOpts.ui = "#{@_ui}:#{name}"

		return new CUI.Label(labelOpts)

	__buildTemplateForKey: (key) ->
		label =  @__getLabel(key.name)

		template = new CUI.Template
			name: "data-field-multi-output"
			map:
				center: true
				aside: true

		template.append(label, "center")

		opts =
			text: key.tag
			tabindex: null
			disabled: !@_control.hasUserControl()
			role: "multi-output-tag"
			tooltip: key.tooltip
			appearance: "flat"
			onClick: (ev) =>
				@_control.showUserControl(ev, button)

		if @_ui
			opts.ui = "#{@_ui}.button:#{key.name}"

		button = new CUI.defaults.class.Button(opts)

		template.append(button, "aside")
		return template

	__hideShowElements: ->
		for key, template of @__keyTemplates
			if @_control.isEnabled(key)
				template.show()
			else
				template.hide()

	destroy: ->
		@__updateListener.destroy()
		delete @__keyTemplates

		super()
