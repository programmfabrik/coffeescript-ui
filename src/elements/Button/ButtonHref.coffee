###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadHtml(require('./ButtonHref.html'));
CUI.Template.loadHtml(require('./ButtonHref_ng.html'));

class CUI.ButtonHref extends CUI.Button
	constructor: (@opts={}) ->
		super(@opts)
		attr =
			href: @_href
			tabindex: "0"
			target: @_target

		if @_download
			attr.download = "download"

		@DOM.attr(attr)

	initOpts: ->
		super()
		@addOpts
			href:
				check: String
			download:
				check: Boolean
			target:
				check: String

	readOpts: ->
		super()

		if @_icon_right == undefined and @_appearance == "link"
			@_icon_right = "external_link"

		@

	setHref: (href) ->
		@DOM.attr("href", href)

	getTemplateName: ->
		# super sets @__has_left + @__has_right
		super()
		return if CUI.__ng__ then "buttonHref-ng" else "buttonHref"

