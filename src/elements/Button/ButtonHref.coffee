class ButtonHref extends Button
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

	setHref: (href) ->
		@DOM.attr("href", href)

	getTemplateName: ->
		# super sets @__has_left + @__has_right
		super()
		return "buttonHref"

