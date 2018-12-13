attributionHtml = require('./leaflet.attribution.html')
require("leaflet/dist/leaflet.js")

class CUI.LeafletMap extends CUI.Map

	@defaults =
		urlCss: "https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
		tileLayerUrl: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png'
		tileLayerOptions:
			attribution: attributionHtml

	constructor: (opts) ->
		super(opts)
		if not CUI.LeafletMap.loadCSSPromise
			CUI.LeafletMap.loadCSSPromise = @__loadCSS()

		CUI.LeafletMap.defaults.tileLayerOptions.maxZoom = CUI.Map.defaults.maxZoom
		@__groups = {}

	__getMapClassName: ->
		"cui-leaflet-map"

	__buildMap: ->
		map = L.map(@get("center"),
			zoomControl: false
		)

		tileLayer = L.tileLayer(CUI.LeafletMap.defaults.tileLayerUrl, CUI.LeafletMap.defaults.tileLayerOptions)

		CUI.dom.waitForDOMInsert(node: @).done =>
			CUI.LeafletMap.loadCSSPromise.done =>
				if @_zoomToFitAllMarkersOnInit
					@zoomToFitAllMarkers()
				else
					map.setView(@_centerPosition, @_zoom)
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

		marker = L.marker(options.position, options)

		if options.group?.type and @_showPolylines
			@__groups[options.group.type] = @__groups[options.group.type] or []
			@__groups[options.group.type].push(marker: marker, options: options.group.options)

			delete options.group

		marker

	__addMarkerToMap: (marker) ->
		marker.addTo(@__map);
		@__updateGroupsPolylines()

	__bindOnClickMapEvent: ->
		@__map.on('click', (event) =>
			@setSelectedMarkerPosition(event.latlng)
			if @__selectedMarker
				@__map.setView(@getSelectedMarkerPosition())
		)

	__afterMarkerCreated: (marker, options) ->
		onClickFunction = options["cui_onClick"]
		onDoubleClickFunction = options["cui_onDoubleClick"]

		# Workaround to fix a Leaflet non-implemented feature https://github.com/Leaflet/Leaflet/issues/108
		if onClickFunction and onDoubleClickFunction
			isDoubleClick = false

			onClickFunction = (event) ->
				CUI.setTimeout( ->
					if not isDoubleClick
						options["cui_onClick"](event)
				, 200)

			onDoubleClickFunction = (event) ->
				isDoubleClick = true
				options["cui_onDoubleClick"](event)
				CUI.setTimeout( ->
					isDoubleClick = false
				, 250)

		if onClickFunction
			marker.on("click", onClickFunction)

		if onDoubleClickFunction
			@__map.doubleClickZoom.disable() # If at least 1 marker has 'onDoubleClick' event, the map disables zoom on double click.
			marker.on("dblclick", onDoubleClickFunction)

		return

	__removeMarker: (marker) ->
		for _, group of @__groups
			foundElement = group.filter((element) => element.marker == marker)
			if foundElement = foundElement[0]
				indexOfElement = group.indexOf(foundElement)
				group.splice(indexOfElement, 1)
				break

		if foundElement && foundElement.polyline
			@__map.removeLayer(foundElement.polyline)

		marker.off()
		@__map.removeLayer(marker)
		marker = null
		return

	__updateGroupsPolylines: ->
		for _, group of @__groups
			group.reduce((elementOne, elementTwo) =>
				if not elementTwo
					return

				if elementOne.polyline
					return elementTwo

				elementOne.polyline = L.polyline([elementOne.marker.getLatLng(), elementTwo.marker.getLatLng()],
					weight: 1.5
					color: elementOne.options.color
					dashArray: elementOne.options.polyline
				)
				elementOne.polyline.addTo(@__map)
				return elementTwo
			)
		return

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
				@__map.setView(@_centerPosition, @_zoom)

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
		for marker in @__markers
			@__removeMarker(marker)

		@__map?.remove()

		delete @__selectedMarker
		delete @__groups

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