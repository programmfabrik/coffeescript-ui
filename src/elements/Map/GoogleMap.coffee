googleMapsApi = require('load-google-maps-api')

class CUI.GoogleMap extends CUI.Map

	@defaults =
		google_api:
			key: null # "google-api-key-here",
			language: "en"

	constructor: (@opts = {}) ->
		@__listeners = []
		super(@opts)

	__getMapClassName: ->
		"cui-google-map"

	__buildMap: ->
		map = new google.maps.Map(@DOM,
			zoom: @_zoom
		)

		# Workaround to 'refresh' the map once it's in the DOM tree.
		CUI.dom.waitForDOMInsert(node: @).done =>
			google.maps.event.trigger(map, 'resize');
			map.setCenter(@_center)

		map

	__bindOnClickMapEvent: ->
		@__listeners.push(@__map.addListener('click', (event) =>
			@__map.setCenter(event.latLng)
			@__map.setZoom(@_zoom)
			@setSelectedMarkerPosition(event.latLng)
		))

	__buildMarker: (options) ->
		new google.maps.Marker(options)

	__addMarkerToMap: (marker) ->
		marker.setMap(@__map)

		if marker.infoWindow
			@__listeners.push(marker.addListener('click', =>
				marker.infoWindow.open(@__map, marker)
			))

	getSelectedMarkerPosition: ->
		position = @__selectedMarker?.getPosition()
		if position
			lat: position.lat(), lng: position.lng()

	setSelectedMarkerPosition: (position) ->
		if @__selectedMarker
			@__selectedMarker.setPosition(position)
		else
			@__selectedMarker = @addMarker(
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
		return

	showMarkers: ->
		for marker in @_markers
			marker.setMap(@__map)
		return

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

	__addCustomOption: (options, key, value) ->
		switch key
			when "cui_content"
				options.infoWindow = CUI.GoogleMap.getInfoWindow(value)
			else
				assert(false, "CUI.GoogleMap", "Unknown option. Known options: ['cui_content']")

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
	


