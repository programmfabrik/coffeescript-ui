attributionHtml = require('./leaflet.attribution.html')
require("leaflet/dist/leaflet.js")

class CUI.LeafletMap extends CUI.Map

	@defaults =
		mapboxToken: "pk.eyJ1Ijoicm9tYW4tcHJvZ3JhbW1mYWJyaWsiLCJhIjoiY2o4azVmb2duMDhwNTJ4bzNsMG9iMDN5diJ9.SfqU1rxrf5to9-ggCM6V9g",
		urlCss: "https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"

	__getMapClassName: ->
		"cui-leaflet-map"

	__buildMap: ->
		map = L.map(@DOM)

		tileLayer = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}',
			attribution: attributionHtml,
			maxZoom: 20,
			id: 'mapbox.streets',
			accessToken: CUI.LeafletMap.defaults.mapboxToken
		)

		CUI.dom.waitForDOMInsert(node: @).done =>
			map.setView(@_center, @_zoom)
			tileLayer.addTo(map)

		map

	__buildMarker: (options) ->
		L.marker(options.position, options)

	__addMarkerToMap: (marker) ->
		marker.addTo(@__map);

	__bindOnClickMapEvent: ->
		@__map.on('click', (event) =>
			@__map.setView(event.latlng, @_zoom)
			@setSelectedMarkerPosition(event.latlng)
		)

	getSelectedMarkerPosition: ->
		@__selectedMarker?.getLatLng()

	setSelectedMarkerPosition: (position) ->
		if @__selectedMarker
			@__selectedMarker.setLatLng(position)
		else
			@__selectedMarker = @addMarker(
				position: position
				draggable: @_clickable
				title: @_selectedMarkerLabel
			)

			@__selectedMarker.on('dragend', () =>
				@__map.setView(@getSelectedMarkerPosition(), @_zoom)
				@_onMarkerSelected?(@getSelectedMarkerPosition())
			)

		@_onMarkerSelected?(@getSelectedMarkerPosition())

	destroy: ->
		@__map.remove()
		CUI.dom.remove(@DOM)

CUI.ready =>
	if not CUI.LeafletMap.defaults.mapboxToken or not CUI.LeafletMap.defaults.urlCss
		return

	leafletDeferred = new CUI.Deferred()

	# Load Leaflet CSS to avoid bundle it.
	new CUI.CSSLoader().load(url: CUI.LeafletMap.defaults.urlCss).done ->
		leafletDeferred.resolve()

	leafletDeferred.promise()