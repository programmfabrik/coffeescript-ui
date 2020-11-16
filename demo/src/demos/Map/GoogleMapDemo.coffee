CUI.GoogleMap.defaults =
	google_api:
		key: null # "google-api-key-here",

class Demo.GoogleMapDemo extends Demo
	display: ->
		mapsWithDetails = []
		markers = [
			position:
				lat: 52.520645
				lng: 13.409779
			icon: 'https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png'
		,
			position:
				lat: 52.534078
				lng: 13.410464
			label: 'Click me'
			cui_content: "Hello!"
		,
			position:
				lat: 52.515691
				lng: 13.387249
			label: 'B'
		]

		optionsOne =
			center: {lat: 52.520645, lng: 13.409779}
			zoom: 13
			class: "cui-map-first"
			selectedMarkerLabel: "X"
			onMarkerSelected: (position) ->
				CUI.dom.replace(currentPositionDiv, "position: Lat: " + position.lat + " Lng: " + position.lng)

		mapOne = new CUI.GoogleMap(optionsOne)
		mapOne.addMarkers(markers)
		mapsWithDetails.push(
			map: mapOne
			options: optionsOne
			markers: markers
		)

		markersTwo = @__getMarkers()

		optionsTwo =
			center: {lat: 53.520645, lng: 13.409779}
			zoom: 2
			clickable: false
			class: "cui-map-second"

		mapTwo = new CUI.GoogleMap(optionsTwo)
		mapTwo.addMarkers(markersTwo)
		mapsWithDetails.push(
			map: mapTwo,
			options: optionsTwo,
			markers: markersTwo
		)

		currentPositionButton = new CUI.Button
			text: "View marked position (Map 1)"
			onClick: =>
				position = mapOne.getSelectedMarkerPosition()
				position = if position then {lat: position.lat, lng: position.lng} else 'Click in the map to add a marker.'
				alert(CUI.util.dump(position))

		showMarkersButton = new CUI.Button
			text: "Show markers (Both maps)"
			onClick: =>
				mapOne.showMarkers()
				mapTwo.showMarkers()

		hideMarkersButton = new CUI.Button
			text: "Hide markers (Both maps)"
			onClick: =>
				mapOne.hideMarkers()
				mapTwo.hideMarkers()

		buttonbar = new CUI.Buttonbar(
			buttons: [
				currentPositionButton
				showMarkersButton
				hideMarkersButton
			]
		)

		currentPositionDiv = CUI.dom.div()

		div = CUI.dom.div()
		CUI.dom.append(div, buttonbar)
		CUI.dom.append(div, currentPositionDiv)

		for index, mapDetails of mapsWithDetails
			index++;
			label = "Map number: " + index
			console.debug(label)
			console.debug(CUI.util.dump(mapDetails.options))
			console.debug(CUI.util.dump(mapDetails.markers))

			CUI.dom.append(div, label)
			CUI.dom.append(div, mapDetails.map)

		return div

	__getMarkers: () ->
		markersTwo = []
		for x in [1...50] by 1
			markersTwo.push(
				position:
					lat: parseFloat(Math.random() * 90) * (if Math.random() < 0.5 then -1 else 1),
					lng: parseFloat(Math.random() * 180) * (if Math.random() < 0.5 then -1 else 1)
			)
		return markersTwo


Demo.register(new Demo.GoogleMapDemo())