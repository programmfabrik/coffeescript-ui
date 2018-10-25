###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Tab.html'));

class CUI.Tab extends CUI.DOMElement
	constructor: (@opts={}) ->
		super(@opts)

		if not CUI.util.isEmpty(@_name)
			cls = "ez-tab-#{CUI.util.toClass(@_name)}"
		else
			cls = null

		@__body = new CUI.Template
			name: "tab-body"
			class: cls

		@registerTemplate(@__body)

		if @_content_placeholder
			@append(@_content_placeholder)
			@__has_placeholder = true

		if CUI.util.isFunction(@_content)
			if not @_load_on_show
				@loadContent()
		else if @_content
			@append(@_content)

		@__activations = 0

	initButton: (tabs) ->
		CUI.util.assert(tabs instanceof CUI.Tabs, "Tab.initButton", "Parameter #1 need to be instance of Tabs.", tabs: tabs)

		@__button = new CUI.Button
			role: "tab-header"
			radio: "tabs--"+tabs.getUniqueId()
			class: "cui-tab-header-button"
			disabled: @_disabled
			qa: if @_qa then @_qa + "-button"
			id: @_button_id
			size: "normal"
			group: "tabs"
			text: @_text
			attr:
				tab: @_name
			active: false
			onActivate: (btn, flags, event) =>
				@__activations++
				if @_load_on_show and not @__content_loaded
					@loadContent()

				@show()
				if @__activations == 1
					@_onFirstActivate?(@)

				@_onActivate?(@, flags, event)
				CUI.Events.trigger
					type: "tab_activate"
					node: @DOM

			onDeactivate: (btn, flags, event) =>
				@hide()
				@_onDeactivate?(@, flags, event)
				CUI.Events.trigger
					type: "tab_deactivate"
					node: @DOM

		@

	initOpts: ->
		super()
		@addOpts
			name:
				check: String
			button_id:
				check: String
			text:
				mandatory: true
				check: String
			disabled:
				mandatory: true
				default: false
				check: Boolean
			content:
				mandatory: true
				check: (v) ->
					CUI.util.isContent(v) or CUI.util.isString(v)
			onFirstActivate:
				check: Function
			onActivate:
				check: Function
			onDeactivate:
				check: Function
			content_placeholder:
				check: (v) ->
					CUI.util.isContent(v)
			load_on_show:
				check: Boolean

	loadContent: ->
		CUI.Panel::loadContent.call(@)

	setContent: (content) ->
		CUI.Panel::setContent.call(@, content, false)

	appendContent: (content) ->
		CUI.Panel::appendContent.call(@, content, false)

	getText: ->
		@_text

	hide: ->
		# console.error "hiding tab...", @getUniqueId(), @DOM
		CUI.dom.addClass(@DOM, "cui-tab-hidden")
		@

	show: ->
		# console.error "showing tab...", @getUniqueId(), @DOM
		# move to first position
		CUI.dom.removeClass(@DOM, "cui-tab-hidden")

		if CUI.__ng__
			CUI.Events.trigger
				type: "viewport-resize"
				node: @DOM
				info:
					tab: true
		@

	destroy: ->
		CUI.Events.trigger
			type: "tab_destroy"
			node: @DOM

		@__button.destroy()
		super()

	disable: ->
		@__button.disable()
		@

	enable: ->
		@__button.enable()
		@

	activate: ->
		@__button.activate()
		@

	deactivate: ->
		@__button.deactivate()
		@

	isActive: ->
		@__button.isActive()

	getButton: ->
		@__button

	getBody: ->
		@DOM


CUI.ready =>
	CUI.Events.registerEvent
		type: "tab_destroy"

	CUI.Events.registerEvent
		type: "tab_deactivate"

	CUI.Events.registerEvent
		type: "tab_activate"


