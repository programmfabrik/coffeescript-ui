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
			markersOptions:
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
		@addClass(@__getMapClassName())

		@__markers = []
		@__map = @__buildMap()
		if @_clickable
			@__bindOnClickMapEvent()

		@addMarkers(@_markersOptions)

	addMarkers: (optionsArray) ->
		for options in optionsArray
			@addMarker(options)

	addMarker: (options) ->
		markerOptions = @__getMarkerOptions(options)
		marker = @__buildMarker(markerOptions)
		@__markers.push(marker)
		@__addMarkerToMap(marker)
		marker

	getSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getSelectedMarkerPosition needs to be implemented.")

	setSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setSelectedMarkerPosition needs to be implemented.")

	hideMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".hideMarkers needs to be implemented.")

	showMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".showMarkers needs to be implemented.")

	__addMarkerToMap: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__addMarkerToMap needs to be implemented.")

	__getMapClassName: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__getMapClassName needs to be implemented.")

	__buildMap: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__buildMap needs to be implemented.")

	__buildMarker: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__buildMarker needs to be implemented.")

	__bindOnClickMapEvent: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__bindOnClickMapEvent needs to be implemented.")

	__addCustomOption: (options, key, value) ->
		return false

	__getMarkerOptions: (options) ->
		markerOptions = {}

		for key, value of options
			if not key.startsWith("cui_")
				markerOptions[key] = value
				continue

			@__addCustomOption(markerOptions, key, value)

		markerOptions