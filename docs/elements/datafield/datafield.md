# DataField
<span class="inheritance">CUI.DOM
<a href="#Documentation/elements/datafield"><mark>Datafield</mark></a>
</span>
***

## Description
Lorem Ipsum

## Creating a DataField

##### instructions

1. 
	To build a new button you simply create a new object of the type *Button*.
	```coffeescript
	myDatafield = new DataField
		<parameter-as-json-object>
	```
2. 
	In order to put data as an array into a <DataField>-element you would take this structure:
	```coffeescript
	myDataField = new DataField
		data:
			myData: []
	```
	Take into account that the data-parameter's value requires an object with at least one key which stores an array as its value.


@@include(datafield_p.md)