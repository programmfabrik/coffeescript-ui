# CUI.Map

This is an 'abstract' class which can be used to render a map with one of its two implementations: 
- **GoogleMap** uses [Google Maps API](https://developers.google.com/maps/) 
- **LeafletMap** uses [LeafletJS](http://leafletjs.com)

Both can be used almost in the same way, they are only differentiated by some particularities of their libraries.

## Methods
### new CUI.Map
```
map = new CUI.LeafletMap(options)
# ...or...
map = new CUI.GoogleMap(options)
```

**Options:**
- center `PlainObject` (default: { lat: 0, lng: 0 })
    - lat: `Number`
    - lng: `Number`
- zoom `Number` (default 10)
- markersOptions `[PlainObject]` (see options in *.addMarker* method)
- clickable `Boolean` (default: *true*)
- selectedMarkerLabel `String`
- selectedMarkerPosition `PlainObject`
    - lat: `Number`
    - lng: `Number`
- onMarkerSelected `Function`
- zoomToFitAllMarkersOnInit `Boolean` (default: *false*)
- zoomControl `Boolean` (default: *true*)
- onClick `Function`
- onZoomEnd `Function`
- onMoveEnd `Function`
- onReady `Function`

If **zoomToFitAllMarkersOnInit** is *true* and map has markers, **zoom** and **center** will be ignored. 

### .addMarker(options)

- options `PlainObject`
    - position `PlainObject`
        - lat: `Number`
        - lng: `Number`

**position** is the only one mandatory, the rest are optional. The rest of the options depends in each library.

### .addMarkers(optionsArray)

- optionsArray `[PlainObject]`
    - position `PlainObject`
        - lat: `Number`
        - lng: `Number`

Invoke *.addMaker* for each *options* inside **optionsArray** array.

### .removeMarker(marker)

- marker `Marker`

It removes a marker. `Marker` is the class of the Library, for example **google.maps.Marker** for google maps.

### .getSelectedMarkerPosition() : position

- position `PlainObject`
    - lat: `Number`
    - lng: `Number`

Get an object with the latitude and longitude of the selected marker. If there is not a marker selected returns undefined.

### .setSelectedMarkerPosition(position)

- position `PlainObject`
    - lat: `Number`
    - lng: `Number`
    
Set the latitude and longitude for the selected marker.

### .hideMarkers()

Hide all the markers registered.

### .showMarkers()

Show all the markers registered.

### .zoomIn()

Increases zoom

### .zoomOut()

Decreases zoom

### .getZoom() : `Number`

It returns the current zoom value.

### .setZoom(zoom) : 

- zoom `Number`

It changes the current zoom value.

### .setCenter(position)

Set the latitude and longitude of the center.
The parameter **position** may vary between a `PlainObject` or a specify class, depending *setCenter* implementation.
Leaflet implementation accepts a second parameter, which is the **zoom**.

### .getCenter()

Returns the latitude and longitude of the center.

## New map implementation

In order to create a new map implementation, it's necessary to override the following methods.

- .getSelectedMarkerPosition() : position
- .setSelectedMarkerPosition(position)
- .hideMarkers()
- .showMarkers()

Also, it's needed to override the following private methods:

### .__buildMap() : newMapClass

This method must create and return the new map instance.

**newMapClass** is the class of the new map implementation.

For example: For Google Maps the class is **google.maps.Map**

You can access to this map instance with **@__map** 

### .__buildMarker(options) : newMarkerClass

This method must create and return the new marker instance.

**newMarkerClass** is the class of the new marker implementation.

**options** is a `PlainObject` with all the options passed when a marker is added with *.addMarker(options)*

For example: For Google Maps the class is **google.maps.Marker**

### .__getMapClassName() : className

**className** is the map container class.

### .__addMarkerToMap(newMarkerClass)

This method must add the **newMarkerClass** inside the **@__map**

### .__bindOnClickMapEvent()

This method should bind a click event in **@__map** to handle it, but it's optional.

### .__addCustomOption(markerOptions, key, value)

If there is options with the prefix 'cui_' when a marker is added, those options will not be mapped and this method is called instead, so you can add a different behaviour instead of plain mapping.

### .__afterMarkerCreated(marker, options)

It's called after a marker is instantiated. 

## Current implementations
### GoogleMap

```
CUI.GoogleMap.defaults.google_api.key = "<GOOGLE_API_KEY>"
CUI.GoogleMap.defaults.google_api.language = 'en' # (optional, default: 'en')
``` 

#### Custom options

**cui_content** `HTMLDOMElement` | `String`

It's used to show an infoWindow when the marker is clicked.


### LeafletMap

Leaflet is an open-source JavaScript library, so you don't need an api key as GoogleMap.
However, It's possible to use different Tile layers.

As default, It's using OpenStreetMap, but you can change it easily.

For example, if you want to use Mapbox:

```
CUI.LeafletMap.defaults.tileLayerUrl: 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}'
CUI.LeafletMap.defaults.tileLayerOptions:
    accessToken: "<MAPBOX_TOKEN>",
    attribution: "<ATTRIBUTION_HTML_HERE>",
    maxZoom: 20,
    id: 'mapbox.streets',
```

#### Custom options

**cui_onClick** `Function`

This function is called when the marker is clicked. It receives the *event* as parameter. It's possible to access to the marker options with *event.target.position*