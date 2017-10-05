googleMapsApi = require('load-google-maps-api')

class CUI.GoogleMap extends CUI.DOMElement

	@defaults =
		google_api:
			key: null # "google-api-key-here",
			language: "en"

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
		@addClass("cui-google-map")
		@__listeners = []

	init: ->
		@__map = new google.maps.Map(@DOM, {
			zoom: @_zoom
			center: @_center
		})

		if @_clickable
			@__listeners.push(@__map.addListener('click', (event) =>
				@__map.setCenter(event.latLng)
				@__map.setZoom(@_zoom)
				@setSelectedMarkerPosition(event.latLng)
			))

	addMarkers: (markers) ->
		for marker in markers
			@__addMarker(marker)

	getSelectedMarkerPosition: ->
		@__selectedMarker?.getPosition()

	setSelectedMarkerPosition: (position) ->
		if @__selectedMarker
			@__selectedMarker.setPosition(position)
		else
			@__selectedMarker = @__addMarker(
				position: position
				draggable: @_clickable
				label: @_selectedMarkerLabel
			)

			@__listeners.push(@__selectedMarker.addListener('dragend', (event) =>
				@__map.setCenter(event.latLng)
				@_onMarkerSelected?(@getSelectedMarkerPosition())
			))

		@_onMarkerSelected?(@getSelectedMarkerPosition())

	hideMarkers: ->
		for marker in @_markers
			marker.setMap(null)

	showMarkers: ->
		for marker in @_markers
			marker.setMap(@__map)

	destroy: ->
		for listener in @__listeners
			listener.remove()

		for marker in @_markers
			marker.setMap(null)

		delete @_markers
		delete @__listeners
		delete @__map
		delete @__selectedMarker
		CUI.dom.remove(@DOM)

		@__destroyed = true

	__addMarker: (marker) ->
		options = @__getMarkerOptions(marker)

		marker = new google.maps.Marker(options)
		marker.setMap(@__map)

		@_markers.push(marker)

		if marker.infoWindow
			@__listeners.push(marker.addListener('click', =>
				marker.infoWindow.open(@__map, marker)
			))

		marker

	__getMarkerOptions: (marker) ->
		options = {}

		for key, value of marker
			if not key.startsWith("cui_")
				options[key] = value
				continue

			switch key
				when "cui_content"
					options.infoWindow = CUI.GoogleMap.getInfoWindow(value)
				else
					assert(false, "CUI.GoogleMap", "Unknown option. Known options: ['cui_content']")

		options

	@getInfoWindow: (content) ->
		div = CUI.dom.div()
		CUI.dom.append(div, content)
		return new google.maps.InfoWindow(content: div)

CUI.ready =>
	if not CUI.GoogleMap.defaults.google_api.key
		return

	googleMapsDeferred = new CUI.Deferred()

	googleMapsApi(CUI.GoogleMap.defaults.google_api).then ->
		googleMapsDeferred.resolve()

	googleMapsDeferred.promise()
	


