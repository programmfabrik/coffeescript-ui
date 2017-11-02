attributionHtml = require('./leaflet.attribution.html')
require("leaflet/dist/leaflet.js")

class CUI.LeafletMap extends CUI.Map

	@defaults =
		urlCss: "https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
		tileLayerUrl: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png'
		tileLayerOptions:
			attribution: attributionHtml

	constructor: (@opts = {}) ->
		if not CUI.LeafletMap.loadCSSPromise
			CUI.LeafletMap.loadCSSPromise = @__loadCSS()
		super(@opts)


	__getMapClassName: ->
		"cui-leaflet-map"

	__buildMap: ->
		map = L.map(@DOM,
			zoomControl: @_zoomControl
		)

		tileLayer = L.tileLayer(CUI.LeafletMap.defaults.tileLayerUrl, CUI.LeafletMap.defaults.tileLayerOptions)

		CUI.dom.waitForDOMInsert(node: @).done =>
			CUI.LeafletMap.loadCSSPromise.done =>
				if @_zoomToFitAllMarkersOnInit
					@zoomToFitAllMarkers()
				else
					map.setView(@_center, @_zoom)
				tileLayer.addTo(map)

		if @_onClick
			map.on("click", @_onClick)

		map

	__buildMarker: (options) ->
		L.marker(options.position, options)

	__addMarkerToMap: (marker) ->
		marker.addTo(@__map);

	__bindOnClickMapEvent: ->
		@__map.on('click', (event) =>
			@__map.setView(event.latlng)
			@setSelectedMarkerPosition(event.latlng)
		)

	__afterMarkerCreated: (marker, options) ->
		onClickFunction = options["cui_onClick"]
		if onClickFunction
			marker.on("click", onClickFunction)

	__removeMarker: (marker) ->
		@__map.removeLayer(marker)

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
				@__map.setView(@getSelectedMarkerPosition())
				@_onMarkerSelected?(@getSelectedMarkerPosition())
			)

		@_onMarkerSelected?(@getSelectedMarkerPosition())

	hideMarkers: ->
		for marker in @__markers
			marker.setOpacity(0)
		return

	showMarkers: ->
		for marker in @__markers
			marker.setOpacity(1)
		return

	zoomToFitAllMarkers: ->
		CUI.dom.waitForDOMInsert(node: @).done =>
			if @__markers.length > 0
				group = new L.featureGroup(@__markers);
				@__map.fitBounds(group.getBounds().pad(0.05));
			else
				@__map.setView(@_center, @_zoom)

	zoomIn: ->
		@__map.setZoom(@__map.getZoom() + 1)

	zoomOut: ->
		@__map.setZoom(@__map.getZoom() - 1)

	resize: ->
		@__map.invalidateSize()

	destroy: ->
		if not @__map
			return

		for marker in @__markers
			@__removeMarker(marker)

		@__map.remove()

		delete @__markers
		delete @__map
		delete @__selectedMarker

		CUI.dom.remove(@DOM)
		super()

	__loadCSS: ->
		leafletDeferred = new CUI.Deferred()
		# Load Leaflet CSS to avoid bundle it.
		if CUI.LeafletMap.defaults.urlCss
			new CUI.CSSLoader().load(url: CUI.LeafletMap.defaults.urlCss).done ->
				leafletDeferred.resolve()
		else
			leafletDeferred.resolve()
		leafletDeferred.promise()