###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Tab extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		if not isEmpty(@_name)
			cls = "ez-tab-#{toClass(@_name)}"
		else
			cls = null

		@__body = new Template
			name: "tab-body"
			class: cls

		@registerTemplate(@__body)

		if @_content_placeholder
			@append(@_content_placeholder)
			@__has_placeholder = true

		if CUI.isFunction(@_content)
			if not @_load_on_show
				@loadContent()
		else if @_content
			@append(@_content)

		@__activations = 0

	initButton: (tabs) ->
		assert(tabs instanceof CUI.Tabs, "Tab.initButton", "Parameter #1 need to be instance of Tabs.", tabs: tabs)

		@__button = new Button
			role: "tab-header"
			radio: "tabs--"+tabs.getUniqueId()
			class: "cui-tab-header-button"
			disabled: @_disabled
			size: if CUI.__ng__ then "normal" else "big"
			group: if CUI.__ng__ then "tabs" else null
			text: @_text
			attr:
				tab: @_name
			active: false
			onActivate: (btn) =>
				@__activations++
				if @_load_on_show and not @__content_loaded
					@loadContent()

				@show()
				if @__activations == 1
					@_onFirstActivate?(@)

				@_onActivate?(@)
				Events.trigger
					type: "tab_activate"
					node: @DOM

			onDeactivate: (btn) =>
				@hide()
				@_onDeactivate?(@)
				Events.trigger
					type: "tab_deactivate"
					node: @DOM

		@

	initOpts: ->
		super()
		@addOpts
			name:
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
					isContent(v) or isString(v)
			onFirstActivate:
				check: Function
			onActivate:
				check: Function
			onDeactivate:
				check: Function
			content_placeholder:
				check: (v) ->
					isContent(v)
			load_on_show:
				check: Boolean

	loadContent: ->
		Panel::loadContent.call(@)

	setContent: (content) ->
		Panel::setContent.call(@, content, false)

	appendContent: (content) ->
		Panel::appendContent.call(@, content, false)

	getText: ->
		@_text

	hide: ->
		# console.error "hiding tab...", @getUniqueId(), @DOM
		@DOM.addClass("cui-tab-hidden")
		@

	show: ->
		# console.error "showing tab...", @getUniqueId(), @DOM
		# move to first position
		@DOM.removeClass("cui-tab-hidden")

		if CUI.__ng__
			Events.trigger
				type: "viewport-resize"
				node: @DOM
				info:
					tab: true
		@

	destroy: ->
		Events.trigger
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
	Events.registerEvent
		type: "tab_destroy"

	Events.registerEvent
		type: "tab_deactivate"

	Events.registerEvent
		type: "tab_activate"


Tab = CUI.Tab
