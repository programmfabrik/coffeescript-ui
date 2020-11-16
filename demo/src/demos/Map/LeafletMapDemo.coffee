CUI.LeafletMap.defaults.mapboxToken = "pk.eyJ1Ijoicm9tYW4tcHJvZ3JhbW1mYWJyaWsiLCJhIjoiY2o4azVmb2duMDhwNTJ4bzNsMG9iMDN5diJ9.SfqU1rxrf5to9-ggCM6V9g" # Key for testing purposes

class Demo.LeafletMapDemo extends Demo
	display: ->
		mapsWithDetails = []
		markers = [
			position:
				lat: 52.520645
				lng: 13.409779
			icon: L.icon(iconUrl: 'https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png')
			cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
		,
			position:
				lat: 52.534078
				lng: 13.410464
			title: 'A'
			cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
		,
			position:
				lat: 52.515691
				lng: 13.387249
			title: 'B'
			cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
		]

		optionsOne =
			class: "cui-map-first"
			selectedMarkerLabel: "X"
			zoomToFitAllMarkersOnInit: true
			onMarkerSelected: (position) ->
				CUI.dom.replace(currentPositionDiv, "position: Lat: " + position.lat + " Lng: " + position.lng)

		mapOne = new CUI.LeafletMap(optionsOne)
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

		mapTwo = new CUI.LeafletMap(optionsTwo)
		mapTwo.addMarkers(markersTwo)
		mapsWithDetails.push(
			map: mapTwo,
			options: optionsTwo,
			markers: markersTwo
		)

		buttonbar = new CUI.Buttonbar(
			buttons: [
				text: "View marked position (Map 1)"
				onClick: =>
					position = mapOne.getSelectedMarkerPosition()
					position = if position then {lat: position.lat, lng: position.lng} else 'Click in the map to add a marker.'
					alert(CUI.util.dump(position))
			,
				text: "Show markers (Both maps)"
				group: "showhide"
				onClick: =>
					mapOne.showMarkers()
					mapTwo.showMarkers()
			,
				text: "Hide markers (Both maps)"
				group: "showhide"
				onClick: =>
					mapOne.hideMarkers()
					mapTwo.hideMarkers()
			,
				text: "Zoom to fit all markers (map 1)"
				onClick: =>
					mapOne.zoomToFitAllMarkers()
			]
		)

		zoomButtonBar = new CUI.Buttonbar
			buttons: [
				icon: "plus"
				group: "zoom"
				onClick: =>
					mapOne.zoomIn()
			,
				icon: "minus"
				group: "zoom"
				onClick: =>
					mapOne.zoomOut()
			]

		currentPositionDiv = CUI.dom.div()

		div = CUI.dom.div()
		CUI.dom.append(div, buttonbar)
		CUI.dom.append(div, zoomButtonBar)
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


Demo.register(new Demo.LeafletMapDemo())