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

	render: ->
		super()
		if @_showOnlyPreferredKey
			key = @_control.getPreferredKey()
			CUI.util.assert(key, "Output.displayValue", "MultiInputControl: no preferred key set.", control: @_control)
			label = new CUI.Label(text: @getValue()[key.name])
			@replace(label)
		else
			for key, idx in @_control.getKeys()
				if not @_control.isEnabled(key.name)
					continue

				value = @getValue()[key.name]
				if CUI.util.isEmpty(value)
					continue

				template = @__buildTemplateForKey(key)
				@append(template)
		@

	__buildTemplateForKey: (key) ->
		label =  new CUI.Label(text: @getValue()[key.name])

		template = new CUI.Template
			name: "data-field-multi-output"
			map:
				center: true
				right: true
		template.append(label, "center")

		button = new CUI.defaults.class.Button
			text: key.tag
			tabindex: null
			disabled: !@_control.hasUserControl()
			role: "multi-output-tag"
			tooltip: key.tooltip
			onClick: (ev) =>
				@_control.showUserControl(ev, button)

		template.append(button, "right")
		return template
