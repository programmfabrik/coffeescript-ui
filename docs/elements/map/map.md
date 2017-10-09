# CUI.Map

This is an 'abstract' class which can be used to render a map with one of its two implementations: 
- **GoogleMap** uses [Google Maps API](https://developers.google.com/maps/) 
- **LeafletMap** uses [LeafletJS](http://leafletjs.com)

Both can be used almost in the same way, they are only differentiated by some particularities of their libraries.

## Usage
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
- markers `[PlainObject]` (see Marker Options)
- clickable `Boolean` (default: *true*)
- selectedMarkerLabel `String`
- onMarkerSelected `Function`

### .addMarker(marker)

- marker `PlainObject`
    - position `PlainObject`
        - lat: `Number`
        - lng: `Number`

**position** is the only one mandatory, the rest are optional. The rest of the options depends in each library.

## Initialization properties

Both implementations has some properties that need to be modified in order to use the map.

#### GoogleMap

```
CUI.GoogleMap.defaults.google_api.key = <GOOGLE_API_KEY>
CUI.GoogleMap.defaults.google_api.language = 'en' # (optional, default: 'en')
``` 

#### LeafletMap

```
CUI.LeafletMap.defaults.mapboxToken = <MAPBOX-TOKEN-HERE>
```
