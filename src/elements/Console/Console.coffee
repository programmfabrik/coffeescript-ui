###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Console extends CUI.DOMElement
	constructor: (opts) ->
		super(opts)
		@__console = CUI.dom.element("DIV", class: "cui-console")
		@registerDOMElement(@__console)

	initOpts: ->
		super()
		@addOpts
			markdown:
				mandatory: true
				default: true
				check: Boolean

	clear: ->
		@__console.innerHTML = ""

	log: (txt, markdown = @_markdown) ->
		lbl = new CUI.defaults.class.Label(text: txt, multiline: true, markdown: markdown)
		@__console.appendChild(lbl.DOM)
		@__console.scrollTop = @__console.scrollHeight
