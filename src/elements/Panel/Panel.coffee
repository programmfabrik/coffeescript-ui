###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Panel.html'));

class CUI.Panel extends CUI.DOM
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

		if CUI.isFunction(@_content)
			if not @_load_on_open
				@loadContent()
		else if @_content
			@append(@_content, "content")

		@button = new Button
			text: @_text
			class: "cui-panel-header-button"
			radio: @_radio
			radio_allow_null: @_radio_allow_null
			icon_active: @_icon_opened
			icon_inactive: @_icon_closed
			onActivate: (btn, flags, event) =>
				@open(not flags.initial_activate)
				@_onActivate?(btn, flags, event)

			onDeactivate: (btn, flags, event) =>
				@close(not flags.initial_activate)
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
			radio_allow_null:
				default: true
				mandatory: true
				check: Boolean
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
		CUI.DOM.hasClass(@DOM, "cui-panel-closed")

	isOpen: ->
		!@isClosed()

	close: (trigger = true) ->
		CUI.DOM.addClass(@DOM, "cui-panel-closed")

		if trigger
			Events.trigger
				type: "content-resize"
				node: @DOM
		@

	open: (trigger = true) ->
		done = =>
			CUI.DOM.removeClass(@DOM, "cui-panel-closed")
			if trigger
				Events.trigger
					type: "content-resize"
					node: @DOM
			return

		if @_load_on_open and not @__content_loaded
			@loadContent().done(done)
		else
			done()
		@

	loadContent: ->
		if CUI.isFunction(@_content)
			ret = @_content(@)
		else
			ret = @_content

		dfr = new CUI.Deferred()
		if isPromise(ret)
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


