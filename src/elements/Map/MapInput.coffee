CUI.Template.loadTemplateText(require('./map-input.html'));

class CUI.MapInput extends CUI.Input

	@defaults:
		buttonTooltip: "Show map"
		mapClass: CUI.LeafletMap

	@displayFormats:
		dms: "FFf" # Degrees, minutes and seconds: 27° 43′ 31.796″ N 18° 1′ 27.484″ W
		ddm: "Ff" # Degrees and decimal minutes: 27° 43.529933333333′ N -18° 1.4580666666667′ W
		dd: "f"  # Decimal degrees: 27.725499° N 18.024301° W

	constructor: (@opts={}) ->
		super(@opts)

	initOpts: ->
		super()
		@addOpts
			mapOptions:
				check: "PlainObject"
				default: {}
			displayFormat:
				check: (value) =>
					not CUI.util.isNull(CUI.MapInput.displayFormats[value])
				default: "dms"
			location:
				check:
					lat:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 90 and value >= -90
					lng:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 180 and value >= -180

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	getTemplate: ->
		new CUI.Template
			name: "map-input"
			map:
				center: true
				right: true

	getTemplateKeyForRender: ->
		"center"

	getValueForDisplay: ->
		value = @getValue()
		parsedCoordinates = CUI.util.parseCoordinates(value)
		if not parsedCoordinates
			return ""
		return @__getFormattedCoordinates(parsedCoordinates)


	getValueForInput: (value = @getValue()) ->
		return value

	render: ->
		super()

		@__initMapOptions()

		openPopoverButton = new CUI.defaults.class.Button
			icon: "fa-map-o"
			tooltip:
				text: CUI.MapInput.defaults.buttonTooltip
			onClick: =>
				@__openPopover(openPopoverButton)

		@replace(openPopoverButton, "right")

	__openPopover: (button) ->
		popoverContent = @__buildPopoverContent()

		popover = new CUI.Popover
			element: button
			handle_focus: false
			placement: "se"
			class: "cui-map-popover"
			pane:
				content: popoverContent
			onHide: =>
				popover.destroy()
		popover.show()
		popover

	__buildPopoverContent: ->
		popoverTemplate = new CUI.Template
			name: "map-popover"
			map:
				header: true
				center: true

		if @_location
			@_mapOptions.center = @_location
			@_mapOptions.selectedMarkerPosition = @_location

		map = new CUI.MapInput.defaults.mapClass(@_mapOptions)

		popoverTemplate.append(map, "center")
		popoverTemplate

	__initMapOptions: ->
		@_mapOptions.onMarkerSelected = (marker) =>
			formattedCoordinates = @__getFormattedCoordinates(
				lat: marker.lat
				lng: marker.lng
			)
			@setValue(formattedCoordinates)

	__getFormatedLocation: ->
		return JSON.stringify(@_location)

	__getFormattedCoordinates: (coordinates) ->
		displayFormat = CUI.MapInput.displayFormats[@_displayFormat]
		return CUI.util.formatCoordinates(coordinates, displayFormat)

	__checkInput: (value) ->
		parsedCoordinates = CUI.util.parseCoordinates(value)
		if not parsedCoordinates
			return false
		return true
