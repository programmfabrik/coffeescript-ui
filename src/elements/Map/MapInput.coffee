CUI.Template.loadTemplateText(require('./map-input.html'));

class CUI.MapInput extends CUI.Input

	@defaults:
		labels:
			mapButtonTooltip: "Show map"
			iconButtonTooltip: "Show icon"
			placeholder: "Insert or paste coordinates"
			iconLabel: "Icon"
			colorLabel: "Color"
		displayFormat: "ll"
		mapClass: CUI.LeafletMap
		iconColors: ["#b8bfc4", "#80d76a", "#f95b53", "#ffaf0f", "#57a8ff"]
		icons: ["fa-map-marker", "fa-envelope", "fa-automobile", "fa-home", "fa-bicycle", "fa-graduation-cap"]

	@displayFormats:
		dms: "FFf" # Degrees, minutes and seconds: 27° 43′ 31.796″ N 18° 1′ 27.484″ W
		ddm: "Ff" # Degrees and decimal minutes: 27° 43.529933333333′ N -18° 1.4580666666667′ W
		dd: "f"  # Decimal degrees: 27.725499° N 18.024301° W
		ll: (position) -> "#{position.lat.toFixed(5)}, #{position.lng.toFixed(5)}" # Latitude and Longitude comma separated: 27.19234, 28.48822

	getTemplateKeyForRender: ->
		"center"

	constructor: (@opts = {}) ->
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
		@removeOpt("getValueForStore")
		@removeOpt("checkInput")

	readOpts: ->
		super()
		@_checkInput = @__checkInput
		@__selectedMarkerOptions = {}

	initValue: ->
		super()

		currentValue = @getValue()
		@__selectedMarkerOptions.iconName = currentValue.iconName or CUI.MapInput.defaults.icons[0]
		@__selectedMarkerOptions.iconColor = currentValue.iconColor or CUI.MapInput.defaults.iconColors[0]

		position = @__getPosition()
		if position and CUI.Map.isValidPosition(position)
			formattedPosition = @__getFormattedPosition(position)
			@setValue(formattedPosition)
		else
			@setValue("")

	getTemplate: ->
		new CUI.Template
			name: "map-input"
			map:
				left: true
				center: true
				right: true

	getValueForDisplay: ->
		@__getPositionForDisplay()

	getValueForInput: ->
		@__getPositionForDisplay()

	__getPositionForDisplay: ->
		position = @__getPosition()
		if not position
			return ""
		return @__getFormattedPosition(position)

	getValueForStore: (value) ->
		objectValue =
			iconName: @__selectedMarkerOptions.iconName
			iconColor: @__selectedMarkerOptions.iconColor

		parsedPosition = CUI.util.parseCoordinates(value)
		objectValue.position = if parsedPosition then parsedPosition else ""
		return objectValue

	render: ->
		super()

		@addClass("cui-data-field--with-button")

		@__initMap()

		if CUI.util.isEmpty(@_placeholder)
			@__input.setAttribute("placeholder", CUI.MapInput.defaults.labels.placeholder)

		openMapPopoverButton = new CUI.defaults.class.Button
			icon: "fa-map-o"
			tooltip:
				text: CUI.MapInput.defaults.labels.mapButtonTooltip
			onClick: =>
				@__openMapPopover(openMapPopoverButton)

		@__openIconPopoverButton = new CUI.defaults.class.Button
			class: "cui-map-icon-popover-button"
			icon: @__selectedMarkerOptions.iconName
			tooltip:
				text: CUI.MapInput.defaults.labels.iconButtonTooltip
			onClick: =>
				@__openIconPopover(@__openIconPopoverButton)

		@replace(openMapPopoverButton, "right")
		@replace(@__openIconPopoverButton, "left")

		@__updateIconOptions()

	__openMapPopover: (button) ->
		mapPopover = new CUI.Popover
			element: button
			handle_focus: false
			placement: "se"
			class: "cui-map-popover"
			pane: @__buildMap()
			onHide: ->
				mapPopover.destroy()

		mapPopover.show()
		return

	__updateIconOptions: ->
		@__openIconPopoverButton.setIcon(@__selectedMarkerOptions.iconName)
		CUI.dom.setStyleOne(@__openIconPopoverButton.getIcon(), "color", @__selectedMarkerOptions.iconColor)

	__openIconPopover: (button) ->
		iconPopover = new CUI.Popover
			element: button
			handle_focus: false
			placement: "se"
			pane:
				content: @__buildIconPopoverContent()
			onHide: ->
				iconPopover.destroy()

		iconPopover.show()
		return

	__buildIconPopoverContent: ->
		iconColorSelect = new CUI.Select(
			data: @__selectedMarkerOptions
			name: "iconColor"
			form:
				label: CUI.MapInput.defaults.labels.colorLabel
			onDataChanged: =>
				@__updateIconOptions()
			options: =>
				options = []
				for color in CUI.MapInput.defaults.iconColors
					icon = new CUI.Icon(class: "css-swatch")
					CUI.dom.setStyle(icon, background: color)
					options.push(icon: icon, value: color)
				options
		)

		iconSelect = new CUI.Select(
			data: @__selectedMarkerOptions
			name: "iconName"
			form:
				label: CUI.MapInput.defaults.labels.iconLabel
			onDataChanged: =>
				@__updateIconOptions()
			options: =>
				options = []
				for icon in CUI.MapInput.defaults.icons
					options.push(icon: icon, value: icon)
				options
		)

		form = new CUI.Form(
			fields: [iconSelect, iconColorSelect]
		)
		form.start()
		form

	__initMap: ->
		@_mapOptions.showPolylines = false

		onMarkerSelected = @_mapOptions.onMarkerSelected
		@_mapOptions.onMarkerSelected = (marker) =>
			formattedPosition = @__getFormattedPosition(
				lat: marker.lat
				lng: marker.lng
			)
			@setValue(formattedPosition)
			@triggerDataChanged()
			onMarkerSelected?()

		return

	__buildMap: ->
		@_mapOptions.selectedMarkerOptions = @__selectedMarkerOptions

		currentPosition = @__getPosition()
		if currentPosition
			@_mapOptions.selectedMarkerPosition = currentPosition
			@_mapOptions.centerPosition = currentPosition

		return new CUI.MapInput.defaults.mapClass(@_mapOptions)

	__getPosition: ->
		@getValue().position

	__getFormattedPosition: (position) ->
		displayFormat = CUI.MapInput.displayFormats[@_displayFormat]
		if not CUI.Map.isValidPosition(position)
			return ""
		return CUI.util.formatCoordinates(position, displayFormat)

	__checkInput: (value) ->
		parsedCoordinates = CUI.util.parseCoordinates(value)
		if not parsedCoordinates
			return false
		return true

	@getDefaultDisplayFormat: ->
		CUI.MapInput.displayFormats[CUI.MapInput.defaults.displayFormat]

