attributionHtml = require('./leaflet.attribution.html')
require("leaflet/dist/leaflet.js")

class CUI.LeafletMap extends CUI.Map

	@defaults =
		urlCss: "https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
		tileLayerUrl: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png'
		tileLayerOptions:
			attribution: attributionHtml

	__getMapClassName: ->
		"cui-leaflet-map"

	__buildMap: ->
		map = L.map(@DOM)

		tileLayer = L.tileLayer(CUI.LeafletMap.defaults.tileLayerUrl, CUI.LeafletMap.defaults.tileLayerOptions)

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

	hideMarkers: ->
		for marker in @_markers
			marker.setOpacity(0)
		return

	showMarkers: ->
		for marker in @_markers
			marker.setOpacity(1)
		return

	destroy: ->
		@__map.remove()
		CUI.dom.remove(@DOM)

CUI.ready =>
	if not CUI.LeafletMap.defaults.urlCss
		return

	leafletDeferred = new CUI.Deferred()

	# Load Leaflet CSS to avoid bundle it.
	new CUI.CSSLoader().load(url: CUI.LeafletMap.defaults.urlCss).done ->
		leafletDeferred.resolve()

	leafletDeferred.promise()