class CUI.Map extends CUI.DOMElement

	initOpts: ->
		super()
		@addOpts
			center:
				check:
					lat:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 90 and value >= -90
					lng:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 180 and value >= -180
				default:
					lat: 0
					lng: 0
			zoom:
				check: "Integer"
				default: 10
			markers:
				check: Array
				default: []
			clickable:
				check: Boolean
				default: true
			selectedMarkerLabel:
				check: String
			onMarkerSelected:
				check: Function

	constructor: (@opts = {}) ->
		super(@opts)
		@registerDOMElement(CUI.dom.div())
		@addClass(@getMapClass())

		@__map = @buildMap()
		if @_clickable
			@bindOnClickMapEvent()

	getMapClass: ->
		"cui-map"

	addMarkers: (markers) ->
		for marker in markers
			@addMarker(marker)

	addMarker: (marker) ->
		options = @__getMarkerOptions(marker)
		marker = @buildMarker(options)
		@_markers.push(marker)
		@addMarkerToMap(marker)
		marker

	buildMap: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".buildMap needs to be implemented.")

	buildMarker: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".buildMarker needs to be implemented.")

	addMarkerToMap: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".addMarkerToMap needs to be implemented.")

	bindOnClickMapEvent: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".addOnClickEvent needs to be implemented.")

	getSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getSelectedMarkerPosition needs to be implemented.")

	setSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setSelectedMarkerPosition needs to be implemented.")

	hideMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".hideMarkers needs to be implemented.")

	showMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".showMarkers needs to be implemented.")

	__addCustomOption: (options, key, value) ->
		return false

	__getMarkerOptions: (marker) ->
		options = {}

		for key, value of marker
			if not key.startsWith("cui_")
				options[key] = value
				continue

			@__addCustomOption(options, key, value)

		options