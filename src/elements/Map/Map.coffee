CUI.Template.loadTemplateText(require('./map.html'));

class CUI.Map extends CUI.DOMElement

	@defaults =
		maxZoom: 18
		minZoom: 0
		zoomButtons:
			plus:
				icon: "zoom_in"
				tooltip: "Zoom in"
			reset:
				icon: "fa-dot-circle-o"
				tooltip: "Reset"
			minus:
				icon: "zoom_out"
				tooltip: "Zoom out"

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
			selectedMarkerPosition:
				check: CUI.Map.isValidPosition
			selectedMarkerOptions:
				check: "PlainObject"
			onMarkerSelected:
				check: Function
			zoomToFitAllMarkersOnInit:
				check: Boolean
				default: false
			onClick:
				check: Function
			onZoomEnd:
				check: Function
			onMoveEnd:
				check: Function
			onReady:
				check: Function
			buttonsUpperRight:
				check: Array
			buttonsBottomRight:
				check: Array
			buttonsBottomLeft:
				check: Array
			showPolylines:
				check: Boolean
				default: true

	constructor: (@opts = {}) ->
		super(@opts)

		template = new CUI.Template
			name: "map"
			map:
				center: true
				"buttons-upper-left": true
				"buttons-upper-right": true
				"buttons-bottom-left": true
				"buttons-bottom-right": true

		@registerTemplate(template)

		@__template.addClass(@__getMapClassName(), "center")

		@__zoomButtons = @__getZoomButtons()
		buttonBar = new CUI.Buttonbar(buttons: @__zoomButtons)
		@__template.append(buttonBar, "buttons-upper-left")

		if @_buttonsUpperRight
			buttonBar = new CUI.Buttonbar(buttons: @_buttonsUpperRight)
			@__template.append(buttonBar, "buttons-upper-right")

		if @_buttonsBottomRight
			buttonBar = new CUI.Buttonbar(buttons: @_buttonsBottomRight)
			@__template.append(buttonBar, "buttons-bottom-right")

		if @_buttonsBottomLeft
			buttonBar = new CUI.Buttonbar(buttons: @_buttonsBottomLeft)
			@__template.append(buttonBar, "buttons-bottom-left")

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

	updateSelectedMarkerOptions: (@_selectedMarkerOptions) ->
		position = @getSelectedMarkerPosition()
		if position
			@removeSelectedMarker()
			@setSelectedMarkerPosition(position)

	setButtonBar: (buttons, position) ->
		buttonBar = new CUI.Buttonbar(buttons: buttons)
		@__template.append(buttonBar, "buttons-#{position}")

	getSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".getSelectedMarkerPosition needs to be implemented.")

	setSelectedMarkerPosition: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".setSelectedMarkerPosition needs to be implemented.")

	removeSelectedMarker: ->
		CUI.util.assert(false, CUI.util.getObjectClass(@) + ".removeSelectedMarker needs to be implemented.")

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

	__onReady: ->
		@__initZoom = @__map.getZoom()
		@__initCenter = @__map.getCenter()
		@__disableEnableZoomButtons()

		@_onReady?()

	__onMoveEnd: ->
		@__disableEnableZoomButtons()
		@_onMoveEnd?(arguments)

	__disableEnableZoomButtons: ->
		zoomInButton = @__zoomButtons[0]
		centerButton = @__zoomButtons[1]
		zoomOutButton = @__zoomButtons[2]
		if @__map.getZoom() == CUI.Map.defaults.maxZoom
			zoomInButton.disable()
		else
			zoomInButton.enable()

		if @__map.getZoom() == CUI.Map.defaults.minZoom
			zoomOutButton.disable()
		else
			zoomOutButton.enable()

		currentCenter = @__map.getCenter()
		if @__map.getZoom() == @__initZoom and Math.round(currentCenter.lat) == Math.round(@__initCenter.lat) and Math.round(currentCenter.lng) == Math.round(@__initCenter.lng)
			centerButton.disable()
		else
			centerButton.enable()

	__getZoomButtons: ->
		return [
				new CUI.Button
					icon: CUI.Map.defaults.zoomButtons.plus.icon
					tooltip: text: CUI.Map.defaults.zoomButtons.plus.tooltip
					group: "zoom"
					onClick: =>
						@zoomIn()
			,
				new CUI.Button
					icon: CUI.Map.defaults.zoomButtons.reset.icon
					tooltip: text: CUI.Map.defaults.zoomButtons.reset.tooltip
					group: "zoom"
					onClick: =>
						@setCenter(@__initCenter, @__initZoom)
						@__disableEnableZoomButtons()
			,
				new CUI.Button
					icon: CUI.Map.defaults.zoomButtons.minus.icon
					tooltip: text: CUI.Map.defaults.zoomButtons.minus.tooltip
					group: "zoom"
					onClick: =>
						@zoomOut()
		]

	@isValidLatitude: (value) ->
		CUI.util.isNumber(value) and value <= 90 and value >= -90

	@isValidLongitude: (value) ->
		CUI.util.isNumber(value) and value <= 180 and value >= -180

	@isValidPosition: (position) ->
		CUI.Map.isValidLatitude(position.lat) and CUI.Map.isValidLongitude(position.lng)