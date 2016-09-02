class Panel extends DOM
	constructor: (@opts={}) ->
		super(@opts)
		@panel = new Template
			name: "panel"
			map:
				header: true
				content: true

		@registerTemplate(@panel)

		if @_content_placeholder
			@append(@_content_placeholder, "content")
			@__has_placeholder = true

		if $.isFunction(@_content)
			if not @_load_on_open
				@loadContent()
		else if @_content
			@append(@_content, "content")

		@button = new Button
			text: @_text
			class: "cui-panel-header-button"
			radio: @_radio
			radio_allow_null: true
			icon_active: @_icon_opened
			icon_inactive: @_icon_closed
			onActivate: (btn, flags, event) =>
				@open()
				@_onActivate?(btn, flags, event)

			onDeactivate: (btn, flags, event) =>
				@close()
				@_onDeactivate?(btn, flags, event)

		@append(@button, "header")

		if @_closed
			@button.deactivate()
		else
			@button.activate()


	initOpts: ->
		super()
		@addOpts(
			text:
				mandatory: true
				check: String
			content:
				# mandatory: true
				check: (v) ->
					isContent(v) or isString(v)
			content_placeholder:
				check: (v) ->
					isContent(v)
			load_on_open:
				check: Boolean
			radio:
				default: "panel-switcher"
				check: (v) ->
					isString(v) or v == true
			closed:
				default: true
				check: Boolean
			icon_opened:
				default: "fa-angle-down"
				check: String
			icon_closed:
				default: "fa-angle-right"
				check: String
			footer_right: {}
			footer_left: {}
			onFirstActivate:
				check: Function
			onActivate:
				check: Function
			onDeactivate:
				check: Function
		)

	readOpts: ->
		super()
		@

	isClosed: ->
		@DOM.hasClass("cui-panel-closed")

	isOpen: ->
		!@isClosed()

	close: ->
		@DOM.addClass("cui-panel-closed")
		@

	open: ->
		if @_load_on_open and not @__content_loaded
			@loadContent()

		@DOM.removeClass("cui-panel-closed")
		@

	loadContent: ->
		if $.isFunction(@_content)
			ret = @_content()
		else
			ret = @_content

		if isPromise(ret)
			ret.always (content) =>
				@setContent(content)
		else
			@setContent(ret)

		@__content_loaded = true
		@

	setContent: (content, key="content") ->
		if content == false and @_content_placeholder
			# keep loading
			return @
		@__has_placeholder = false
		@replace(content, key)
		@

	appendContent: (content, key="content") ->
		if @__has_placeholder
			@setContent(content, key)
		else
			@append(content, key)
		@


