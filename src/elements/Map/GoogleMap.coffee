googleMapsApi = require('load-google-maps-api')

class CUI.GoogleMap extends CUI.Map

	@defaults =
		google_api:
			key: null # "google-api-key-here",
			language: "en"

	constructor: (@opts = {}) ->
		CUI.util.assert(CUI.GoogleMap.defaults.google_api.key, "It's necessary to add a google maps api key in order to use CUI.GoogleMap")
		@__listeners = []
		super(@opts)

	__getMapClassName: ->
		"cui-google-map"

	__buildMap: ->
		map = new google.maps.Map(@DOM,
			zoomControl: @_zoomControl
		)

		# Workaround to 'refresh' the map once it's in the DOM tree.
		CUI.dom.waitForDOMInsert(node: @).done =>
			google.maps.event.trigger(map, 'resize');
			if @_zoomToFitAllMarkersOnInit
				@zoomToFitAllMarkers()
			else
				map.setCenter(@_center)
				map.setZoom(@_zoom)

			@_onReady?()

		map

	__bindOnClickMapEvent: ->
		@__listeners.push(@__map.addListener('click', (event) =>
			@__map.setCenter(event.latLng)
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

	__removeMarker: (marker) ->
		marker.setMap(null)

	getSelectedMarkerPosition: ->
		position = @__selectedMarker?.getPosition()
		if position
			lat: position.lat(), lng: position.lng()

	setSelectedMarkerPosition: (position) ->
		if @__selectedMarker
			@__selectedMarker.setPosition(position)
		else
			options = @_selectedMarkerOptions or {}
			options.position = position
			options.draggable = @_clickable
			@__selectedMarker = @addMarker(options)

			@__listeners.push(@__selectedMarker.addListener('dragend', (event) =>
				@__map.setCenter(event.latLng)
				@_onMarkerSelected?(@getSelectedMarkerPosition())
			))

		@_onMarkerSelected?(@getSelectedMarkerPosition())

	removeSelectedMarker: ->
		if @__selectedMarker
			@__removeMarker(@__selectedMarker)
			delete @__selectedMarker

	hideMarkers: ->
		for marker in @__markers
			marker.setMap(null)
		return

	showMarkers: ->
		for marker in @__markers
			marker.setMap(@__map)
		return

	destroy: ->
		if not @__map
			return

		for listener in @__listeners
			listener.remove()

		for marker in @__markers
			marker.setMap(null)

		delete @__markers
		delete @__listeners
		delete @__map
		delete @__selectedMarker
		delete @__bounds
		CUI.dom.remove(@DOM)
		super()

	zoomToFitAllMarkers: ->
		CUI.dom.waitForDOMInsert(node: @).done =>
			if @__markers.length > 0
				@__bounds = new google.maps.LatLngBounds();
				for marker in @__markers
					@__bounds.extend(marker.position);
				@__map.fitBounds(@__bounds);
			else
				@__map.setCenter(@_center)
				@__map.setZoom(@_zoom)

	zoomIn: ->
		@__map.setZoom(@__map.getZoom() + 1)

	zoomOut: ->
		@__map.setZoom(@__map.getZoom() - 1)

	resize: ->
		google.maps.event.trigger(@__map, 'resize');

	getZoom: ->
		return @__map.getZoom()

	setZoom: (zoom) ->
		@__map.setZoom(zoom)

	setCenter: (position) ->
		@__map.setCenter(position)

	__addCustomOption: (markerOptions, key, value) ->
		switch key
			when "cui_content"
				markerOptions.infoWindow = CUI.GoogleMap.getInfoWindow(value)
			else
				CUI.util.assert(false, "CUI.GoogleMap", "Unknown option. Known options: ['cui_content']")

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
	


