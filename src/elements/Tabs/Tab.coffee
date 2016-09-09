class Tab extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		if not isEmpty(@_name)
			cls = "ez-tab-#{toClass(@_name)}"
			attr = tab: @_name
		else
			cls = null
			attr = undefined

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

		@__button = new Button
			role: "tab-header"
			radio: "tabs"
			class: "tab-header-button"
			size: "big"
			group: "tabs"
			text: @_text
			attr: attr
			active: false
			onActivate: =>
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

			onDeactivate: =>
				@hide()
				@_onDeactivate?(@)
				Events.trigger
					type: "tab_deactivate"
					node: @DOM

	initOpts: ->
		super()
		@addOpts
			name:
				check: String
			text:
				mandatory: true
				check: String
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
		@DOM.addClass("cui-tab-hidden")
		@

	show: ->
		# move to first position
		@DOM.removeClass("cui-tab-hidden")
		@

	destroy: ->
		Events.trigger
			type: "tab_destroy"
			node: @DOM

		@__button.destroy()
		super()

	activate: ->
		@__button.activate()
		@

	deactivate: ->
		@__button.deactivate()
		@

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

