class CUI.Map extends CUI.DOMElement

	initOpts: ->
		super()
		@addOpts
			center:
				check: CUI.Map.isValidPosition
				default:
					lat: 0
					lng: 0
			zoom:
				check: "Integer"
				default: 1
			markersOptions:
				check: Array
				default: []
			clickable:
				check: Boolean
				default: true
			selectedMarkerLabel:
				check: String
			selectedMarkerPosition:
				check: CUI.Map.isValidPosition
			onMarkerSelected:
				check: Function
			zoomToFitAllMarkersOnInit:
				check: Boolean
				default: false
			zoomControl:
				check: Boolean
				default: true
			onClick:
				check: Function
			onZoomEnd:
				check: Function
			onMoveEnd:
				check: Function
			onReady:
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

		if @_selectedMarkerPosition
			@setSelectedMarkerPosition(@_selectedMarkerPosition)

	addMarkers: (optionsArray) ->
		for options in optionsArray
			@addMarker(options)

	addMarker: (options) ->
		markerOptions = @__getMarkerOptions(options)
		marker = @__buildMarker(markerOptions)
		@__afterMarkerCreated(marker, options)
		@__markers.push(marker)
		@__addMarkerToMap(marker)
		marker

	removeMarkers: (markers) ->
		for marker in markers
			@removeMarker(marker)

	removeMarker: (marker) ->
		index = @__markers.indexOf(marker)
		if index == -1
			return false
		@__markers.splice(index, 1)
		@__removeMarker(marker)

	getSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getSelectedMarkerPosition needs to be implemented.")

	setSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setSelectedMarkerPosition needs to be implemented.")

	hideMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".hideMarkers needs to be implemented.")

	showMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".showMarkers needs to be implemented.")

	zoomToFitAllMarkers: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".zoomToFitAllMarkers needs to be implemented.")

	zoomIn: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".zoomIn needs to be implemented.")

	zoomOut: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".zoomOut needs to be implemented.")

	resize: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".resize needs to be implemented.")

	getZoom: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getZoom needs to be implemented.")

	setZoom: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setZoom needs to be implemented.")

	setCenter: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setCenter needs to be implemented.")

	getCenter: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getCenter needs to be implemented.")

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

	__onMarkerClick: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__onMarkerClick needs to be implemented.")

	__removeMarker: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".__removeMarker needs to be implemented.")

	__addCustomOption: (options, key, value) ->
		return false

	__afterMarkerCreated: (marker, options) ->
		return false

	__getMarkerOptions: (options) ->
		markerOptions = {}

		for key, value of options
			if not key.startsWith("cui_")
				markerOptions[key] = value
				continue

			@__addCustomOption(markerOptions, key, value)

		markerOptions

	@isValidLatitude: (value) ->
		CUI.util.isNumber(value) and value <= 90 and value >= -90

	@isValidLongitude: (value) ->
		CUI.util.isNumber(value) and value <= 180 and value >= -180

	@isValidPosition: (position) ->
		CUI.Map.isValidLatitude(position.lat) and CUI.Map.isValidLongitude(position.lng)