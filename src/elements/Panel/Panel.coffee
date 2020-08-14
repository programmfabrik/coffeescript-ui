###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Panel.html'));

class CUI.Panel extends CUI.DOMElement

	@defaults:
		arrow_down: "fa-chevron-down"
		arrow_right: "fa-chevron-right"

	constructor: (opts) ->
		super(opts)
		@panel = new CUI.Template
			name: "panel"
			map:
				header: true
				content: true

		@registerTemplate(@panel)

		if @_content_placeholder
			@append(@_content_placeholder, "content")
			@__has_placeholder = true

		if CUI.util.isFunction(@_content)
			if not @_load_on_open
				@loadContent()
		else if @_content
			@append(@_content, "content")

		@__activations = 0

		@button = new CUI.Button
			text: @_text
			class: "cui-panel-header-button"
			radio: @_radio
			radio_allow_null: @_radio_allow_null
			icon_active: @_icon_opened
			icon_inactive: @_icon_closed
			onActivate: (btn, flags, event) =>
				@__activations++
				if @__activations == 1
					@_onFirstActivate?(@, flags, event)

				@__open(not flags.initial_activate)
				@_onActivate?(btn, flags, event)

			onDeactivate: (btn, flags, event) =>
				@__close(not flags.initial_activate)
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
					CUI.util.isContent(v) or CUI.util.isString(v)
			content_placeholder:
				check: (v) ->
					CUI.util.isContent(v)
			load_on_open:
				check: Boolean
			radio:
				default: "panel-switcher"
				check: (v) ->
					CUI.util.isString(v) or v == true
			radio_allow_null:
				default: true
				mandatory: true
				check: Boolean
			closed:
				default: true
				check: Boolean
			icon_opened:
				default: CUI.defaults.class.Panel.defaults.arrow_down
				check: String
			icon_closed:
				default: CUI.defaults.class.Panel.defaults.arrow_right
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
		CUI.dom.hasClass(@DOM, "cui-panel-closed")

	isOpen: ->
		!@isClosed()

	open: ->
		@button.activate()
		@

	close: ->
		@button.deactivate()
		@

	__close: (trigger = true) ->
		CUI.dom.addClass(@DOM, "cui-panel-closed")

		if trigger
			CUI.Events.trigger
				type: "content-resize"
				node: @DOM
		@

	__open: (trigger = true) ->
		done = =>
			CUI.dom.removeClass(@DOM, "cui-panel-closed")
			if trigger
				CUI.Events.trigger
					type: "content-resize"
					node: @DOM
			return

		if @_load_on_open and not @__content_loaded
			@loadContent().done(done)
		else
			done()
		@

	loadContent: ->
		if CUI.util.isFunction(@_content)
			ret = @_content(@)
		else
			ret = @_content

		dfr = new CUI.Deferred()
		if CUI.util.isPromise(ret)
			ret.always (content) =>
				@setContent(content)
				dfr.resolve()
		else
			@setContent(ret)
			dfr.resolve()
		@__content_loaded = true
		dfr.promise()

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

CUI.defaults.class.Panel = CUI.Panel
