###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./StickyHeader.html'));

class CUI.StickyHeader extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		@header = new Template
			name: "sticky-header"
			map:
				center: true

		@registerTemplate(@header)

		@addClass("cui-sticky-header-level-#{@_level}")
		if not CUI.util.isEmpty(@_text)
			@replace($text(@_text), "center")
		else
			@replace(@_content, "center")

		@_control.addStickyHeader(@)

	initOpts: ->
		super()
		@addOpts
			control:
				mandatory: true
				check: StickyHeaderControl
			text:
				check: String
			content: {}
			level:
				default: 0
				check: (v) ->
					v == 0 or v == 1 or v == 2


	getLevel: ->
		@_level


