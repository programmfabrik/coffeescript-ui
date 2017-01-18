###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Pane with Header and Footer
class CUI.SimplePane extends CUI.Pane

	# @param [Object] options for pane creation
	# @option options [Array, Element, jQuery] header_left access the "left" of the PaneHeader
	# @option options [Array, Element, jQuery] header_center access the "center" of the PaneHeader
	# @option options [Array, Element, jQuery] header_right access the "right" of the PaneHeader
	# @option options [Array, Element, jQuery] footer_left access the "left" of the PaneFooter
	# @option options [Array, Element, jQuery] footer_right access the "right" of the PaneFooter

	__init: ->
		super()
		for k in [
			"header_left"
			"header_center"
			"header_right"
			"footer_left"
			"footer_right"
		]
			@append(@["_#{k}"], k)

		if @_title
			@append(new Label(text: @_title), "header_left")
		
		if @_padded
			@addClass("cui-simple-pane--padded")

		if not CUI.__ng__
			@addClass("cui-simple-pane")

	initOpts: ->
		super()
		@addOpts
			title: {}
			header_right: {}
			header_center: {}
			header_left: {}
			footer_left: {}
			footer_right: {}
			content: {}
			padded:
				check: Boolean
				default: false

		@removeOpt("top")
		@removeOpt("bottom")
		@removeOpt("center")

		@

	readOpts: ->
		# Skip readOpts from Pane as it sets defaults in top and bottom
		# which is not allowed in our initOpts
		VerticalLayout::readOpts.call(@)

		if @_title
			assert(not @_header_left, "new SimplePane", "opts.header_left conflicts with opts.title", opts: @opts)

		@__pane_header = new PaneHeader()
		@__pane_footer = new PaneFooter()

		@_top =
			content: @__pane_header

		@_bottom =
			content: @__pane_footer

		@_center =
			content: @_content
		@

	destroy: ->
		@__pane_header.destroy()
		@__pane_footer.destroy()
		super()

	getPaneAndKey: (key) ->
		# this reaches the panels directly
		if key in ["center", "top", "bottom"]
			[ @getLayout(), key ]
		else if key == "content"
			[ @getLayout(), "center" ]
		else
			m = key.match(/^(.*?)_(.*)$/)
			assert(m?.length==3, "SimplePane.getPaneAndKey", "key #{key} not matched.", matched: m)
			pn = "__pane_#{m?[1]}"
			pane = @[pn]
			assert(pane, "SimplePane.getPaneAndKey", "pane #{pn} not found.")

			[ pane, m[2] ]

	empty: (key="center") ->
		[ pane, _key ] = @getPaneAndKey(key)
		pane.empty(_key)
		@

	append: (content, key="center") ->
		[ pane, _key ] = @getPaneAndKey(key)
		pane.append(content, _key)
		@

	replace: (content, key="center") ->
		[ pane, _key ] = @getPaneAndKey(key)
		pane.replace(content, _key)
		@

SimplePane = CUI.SimplePane
