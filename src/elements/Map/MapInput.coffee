CUI.Template.loadTemplateText(require('./map-input.html'));

class CUI.MapInput extends CUI.Input

	@defaults:
		buttonTooltip: "Show map"
		mapClass: CUI.LeafletMap

	initOpts: ->
		super()
		@addOpts
			mapOptions:
				check: "PlainObject"
				default: {}
			location:
				check:
					lat:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 90 and value >= -90
					lng:
						check: (value) =>
							CUI.util.isNumber(value) and value <= 180 and value >= -180

	getTemplate: ->
		new CUI.Template
			name: "map-input"
			map:
				center: true
				right: true

	getTemplateKeyForRender: ->
		"center"

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
			@_location =
				lat: marker.lat
				lng: marker.lng
			@setValue(@__getFormatedLocation())

	__getFormatedLocation: ->
		return JSON.stringify(@_location)