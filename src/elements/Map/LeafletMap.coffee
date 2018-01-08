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
			CUI.LeafletMap.defaults.tileLayerOptions.maxZoom = CUI.Map.defaults.maxZoom
			CUI.LeafletMap.loadCSSPromise = @__loadCSS()

		@__groups = {}
		super(@opts)

	__getMapClassName: ->
		"cui-leaflet-map"

	__buildMap: ->
		map = L.map(@__template.map.center,
			zoomControl: false
		)

		tileLayer = L.tileLayer(CUI.LeafletMap.defaults.tileLayerUrl, CUI.LeafletMap.defaults.tileLayerOptions)

		CUI.dom.waitForDOMInsert(node: @).done =>
			CUI.LeafletMap.loadCSSPromise.done =>
				if @_zoomToFitAllMarkersOnInit
					@zoomToFitAllMarkers()
				else
					map.setView(@_center, @_zoom)
				tileLayer.addTo(map)

				@__onReady()

		if @_onClick
			map.on("click", @_onClick)

		if @_onZoomEnd
			map.on("zoomend", @_onZoomEnd)

		map.on("moveend", => @__onMoveEnd(arguments))

		map

	__buildMarker: (options) ->
		if options.iconName and options.iconColor
			iconMarker = new CUI.IconMarker(icon: options.iconName, color: options.iconColor)
			iconSize = iconMarker.getSize()
			iconAnchor = iconMarker.getAnchor()

			options.icon = L.divIcon(
				html: iconMarker.toHtml()
				iconAnchor: [iconAnchor.left, iconAnchor.top]
				iconSize: [iconSize, iconSize]
			)

			delete options.iconName
			delete options.iconColor

		if options.group and @_showPolylines
			@__groups[options.group] = @__groups[options.group] or {positions: []}
			@__groups[options.group].positions.push([options.position.lat, options.position.lng])

			delete options.group

		L.marker(options.position, options)

	__addMarkerToMap: (marker) ->
		marker.addTo(@__map);
		@__updateGroups()

	__bindOnClickMapEvent: ->
		@__map.on('click', (event) =>
			@setSelectedMarkerPosition(event.latlng)
			if @__selectedMarker
				@__map.setView(@getSelectedMarkerPosition())
		)

	__afterMarkerCreated: (marker, options) ->
		onClickFunction = options["cui_onClick"]
		if onClickFunction
			marker.on("click", onClickFunction)

	__removeMarker: (marker) ->
		@__map.removeLayer(marker)

	__updateGroups: ->
		for groupColor, group of @__groups
			if group.polyline
				@__map.removeLayer(group.polyline)
			@__groups[groupColor].polyline = L.polyline(group.positions, {color: groupColor, weight: 2, dashArray: '4, 4'})
			@__groups[groupColor].polyline.addTo(@__map)

	getSelectedMarkerPosition: ->
		@__selectedMarker?.getLatLng()

	setSelectedMarkerPosition: (position) ->
		if not CUI.Map.isValidPosition(position)
			return

		if @__selectedMarker
			@__selectedMarker.setLatLng(position)
		else
			options = @_selectedMarkerOptions or {}
			options.position = position
			options.draggable = @_clickable
			@__selectedMarker = @addMarker(options)

			@__selectedMarker.on('dragstart', =>
				@__selectedMarkerPositionOnDragStart = @getSelectedMarkerPosition()
			)

			@__selectedMarker.on('dragend', =>
				latLng = @getSelectedMarkerPosition()
				if CUI.Map.isValidPosition(latLng)
					@_onMarkerSelected?(@getSelectedMarkerPosition())
				else
					@setSelectedMarkerPosition(@__selectedMarkerPositionOnDragStart)

				@__map.setView(@getSelectedMarkerPosition())
			)

		@_onMarkerSelected?(@getSelectedMarkerPosition())

	removeSelectedMarker: ->
		if @__selectedMarker
			@__removeMarker(@__selectedMarker)
			delete @__selectedMarker

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

	getZoom: ->
		return @__map.getZoom()

	setZoom: (zoom) ->
		@__map.setZoom(zoom)

	setCenter: (position, zoom = @getZoom()) ->
		@__map.setView(position, zoom)

	getCenter: ->
		return @__map.getCenter()

	destroy: ->
		if not @__map
			return

		for marker in @__markers
			@__removeMarker(marker)

		for _, group of @__groups
			if group.polyline
				@__map.removeLayer(group.polyline)

		@__map.remove()

		delete @__markers
		delete @__map
		delete @__selectedMarker

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