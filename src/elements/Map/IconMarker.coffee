class CUI.IconMarker extends CUI.DOMElement

	initOpts: ->
		super()
		@addOpts
			icon:
				check: String
			color:
				check: String
			size:
				check: "Integer"
				default: 28
			arrowSize:
				check: "Integer"
				default: 5

	constructor: (@opts = {}) ->
		super(@opts)
		template = new CUI.Template
			name: "map-div-marker"
			map:
				icon: true
				arrow: true

		@registerTemplate(template)
		@render()
		@

	render: ->
		style = {
			"width": @_size
			"height": @_size
			"background": @_color
		}

		@append(new CUI.Icon(icon: @_icon), "icon")
		CUI.dom.setStyle(@DOM, style)

		styleArrow = {
			"width": @_arrowSize * 2
			"height": @_arrowSize * 2
			"margin-left": - @_arrowSize
		}

		CUI.dom.setStyle(@template.map.arrow, styleArrow)

	toHtml: ->
		@DOM.outerHTML

	getAnchor: ->
		top: @_size + @_arrowSize
		left: @_size / 2

	getSize: ->
		return @_size