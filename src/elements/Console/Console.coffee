class CUI.Console extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)
		@__console = CUI.DOM.element("DIV", class: "cui-console")
		@registerDOMElement(@__console)

	initOpts: ->
		super()
		console.debug "init opts console"
		@addOpts
			markdown:
				mandatory: true
				default: true
				check: Boolean

	clear: ->
		@__console.innerHTML = ""

	log: (txt, markdown = @_markdown) ->
		console.debug "markdown:", @_markdown, markdown
		lbl = new CUI.defaults.class.Label(text: txt, multiline: true, markdown: markdown)
		@__console.appendChild(lbl.DOM[0])
		@__console.scrollTop = @__console.scrollHeight
