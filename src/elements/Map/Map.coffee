googleMapsApi = require('load-google-maps-api')

class CUI.Map extends CUI.DOMElement

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
						check: (v) =>
							v >= 0
					lng:

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
		@addClass("cui-map")

		if not CUI.Map.googleMapsPromise
			CUI.Map.googleMapsPromise = googleMapsApi(CUI.Map.defaults.google_api)

		@__init()
		@__mapDefered = new CUI.Deferred()
		@__mapDeferredPromise = @__mapDeferred.promise()


	__init: () ->
		CUI.Map.googleMapsPromise.then(() =>
			@map = new google.maps.Map(@DOM, {
				zoom: @_zoom
				center: @_center
			})

			if @_clickable
				@map.addListener('click', (event) =>
					@map.setCenter(event.latLng)
					@map.setZoom(@_zoom)
					@setSelectedMarkerPosition(event.latLng)
				)

			@__mapDefered.resolve(@map)
		)

	getMap: ->
		@__mapDeferredPromise

	addMarkers: (markers) ->
		CUI.Map.googleMapsPromise.then(() =>
			for marker in markers
				@__addMarker(marker)
		)

	getSelectedMarkerPosition: () ->
		@__selectedMarker?.getPosition()

	setSelectedMarkerPosition: (location) ->
		CUI.Map.googleMapsPromise.then(() =>
			if @__selectedMarker
				@__selectedMarker.setPosition(location)
			else
				@__selectedMarker = @__addMarker(
					location: location
					draggable: @_clickable
					label: @_selectedMarkerLabel
				)

				@__selectedMarker.addListener('dragend', (event) =>
					@map.setCenter(event.latLng)
					@_onMarkerSelected?(@getSelectedMarkerPosition())
				)

			@_onMarkerSelected?(@getSelectedMarkerPosition())
		)

	hideMarkers: ->
		for marker in @_markers
			marker.setMap(null)

	showMarkers: ->
		for marker in @_markers
			marker.setMap(@map)

	__addMarker: (marker) ->
		marker.map = @__map
		options = @__getMarkerOptions(marker)




		marker = new google.maps.Marker(options)

		@_markers.push(marker)

		if marker.infoWindow
			marker.addListener('click', () =>
				marker.infoWindow.open(@map, marker)
			)

		marker

	getMap: ->


	@getInfoWindow: (content) ->
			div = CUI.dom.div()
			CUI.dom.append(div, marker.content)


	__getMarkerOptions: (marker) ->

		options = {}

		for k, v of marker
			if not k.startWith("cui_")
				options[k] = v
				continue

			switch k
				when "cui_content"
					options.infoWindow = @getInfoWindow(v)
				else
					assert(false, "CUI.Map", "Unknown option"

		options




		options = {
			position: marker.location
			draggable: marker.draggable
			label: marker.label
			map: @map
		}

		if marker.icon
			options.icon = marker.icon

		if marker.cui_content

			)

		options

CUI.ready =>
	if not CUI.Map.google_api.key
		return

	dfr = new CUI.Deferred()
	googleMapsApi(CUI.Map.defaults.google_api)


