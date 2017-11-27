CUI.Template.loadTemplateText(require('./map-input.html'));

class CUI.MapInput extends CUI.Input

	@defaults:
		buttonTooltip: "Show map"
		placeholder: "Insert or paste coordinates"
		displayFormat: "dms"
		mapClass: CUI.LeafletMap

	@displayFormats:
		dms: "FFf" # Degrees, minutes and seconds: 27° 43′ 31.796″ N 18° 1′ 27.484″ W
		ddm: "Ff" # Degrees and decimal minutes: 27° 43.529933333333′ N -18° 1.4580666666667′ W
		dd: "f"  # Decimal degrees: 27.725499° N 18.024301° W

	getTemplateKeyForRender: ->
		"center"

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
				default: CUI.MapInput.defaults.displayFormat

		@removeOpt("getValueForDisplay")
		@removeOpt("getValueForInput")
		@removeOpt("checkInput")

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	initValue: ->
		super()
		position = @getValue()
		if position and CUI.Map.isValidPosition(position)
			formattedPosition = @__getFormattedPosition(position)
			@setValue(formattedPosition)
		else
			@setValue("")

	getTemplate: ->
		new CUI.Template
			name: "map-input"
			map:
				center: true
				right: true

	getValueForDisplay: ->
		value = @getValue()
		parsedPosition = CUI.util.parseCoordinates(value)
		if not parsedPosition
			return ""
		return @__getFormattedPosition(parsedPosition)

	render: ->
		super()

		@__initMap()

		if CUI.util.isEmpty(@_placeholder)
			@__input.setAttribute("placeholder", CUI.MapInput.defaults.placeholder)

		openPopoverButton = new CUI.defaults.class.Button
			icon: "fa-map-o"
			tooltip:
				text: CUI.MapInput.defaults.buttonTooltip
			onClick: =>
				@__openPopover(openPopoverButton)

		@replace(openPopoverButton, "right")

	__openPopover: (button) ->
		if not @__popoverContent
			@__popoverContent = @__buildPopoverContent()

		popover = new CUI.Popover
			element: button
			handle_focus: false
			placement: "se"
			class: "cui-map-popover"
			pane:
				content: @__popoverContent
			onHide: =>
				popover.destroy()

		popover.show()

		currentPosition = CUI.util.parseCoordinates(@getValue())
		if currentPosition
			@__map.setSelectedMarkerPosition(currentPosition)
			@__map.setCenter(currentPosition)
		else
			@__map.removeSelectedMarkerPosition()

		popover

	__buildPopoverContent: ->
		popoverTemplate = new CUI.Template
			name: "map-popover"
			map:
				header: true
				center: true

		popoverTemplate.append(@__map, "center")
		popoverTemplate

	__initMap: ->
		@_mapOptions.onMarkerSelected = (marker) =>
			formattedPosition = @__getFormattedPosition(
				lat: marker.lat
				lng: marker.lng
			)
			@setValue(formattedPosition)
			@triggerDataChanged()

		value = @getValue()
		if value
			currentPosition = CUI.util.parseCoordinates(value)
			if currentPosition
				@_mapOptions.selectedMarkerPosition = currentPosition
				@_mapOptions.center = currentPosition

		@__map = new CUI.MapInput.defaults.mapClass(@_mapOptions)

	__getFormattedPosition: (position) ->
		displayFormat = CUI.MapInput.displayFormats[@_displayFormat]
		return CUI.util.formatCoordinates(position, displayFormat)

	__checkInput: (value) ->
		parsedCoordinates = CUI.util.parseCoordinates(value)
		if not parsedCoordinates
			return false
		return true

	@getDefaultDisplayFormat: ->
		CUI.MapInput.displayFormats[CUI.MapInput.defaults.displayFormat]

#CUI.ready =>
#	mapInput = new CUI.MapInput
#		displayFormat: "ddm"
#		mapOptions:
#			zoom: 5
#		name: "map"
#		data:
#			map:
#				lat: 32.20
#				lng: 30.30
#
#
#	mapInput.render()
#	CUI.dom.prepend(document.body, mapInput)
