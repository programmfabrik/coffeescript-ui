# DataTable
<span class="inheritance">
<a href="#Documentation/core/dom">DOM</a>
<a class="inheritance" href="#Documentation/elements/datafield">DataField</a>
<a class="inheritance" href="#Documentation/elements/datafieldinput">DataFieldInput</a>
<a class="inheritance" href="#Documentation/elements/datatable"><mark>DataTable</mark></a>
</span>
***

## Description
Lorem Ipsum

## Creating a DataTable

The table we build during the following steps consists of two colums and four rows (including the descriptive table head).

To achieve clear steps, all data structures are stored in single variables which are put together in the final step.
Of course, you can avoid these temporary variables and create the <DataTable>-object directly in one go.

##### instructions

1. 
	First we create the table's head:

	```coffeescript
	dataFields = [
			type: Output
			name: "column1"
		,
			type: Output
			name: "column2"
		]
	```
2. 
	In order to fill the table up with data we create an data-object whose <mark>key</mark> matches the <DataTable>'s name parameter and whose <mark>value</mark> is an array matching the following structure:

	```coffeescript
	data =
		myTable: [	# key must match <DataTable>'s name parameter
			column1: "This"
			column2: "is"
		,
			column1: "data"
			column2: "in"
		,
			column1: "a"
			column2: "table."
		]
	```

3. 
	As already suggested in step 2, we additionally need an object of the type <DataTable>.

	```coffeescript
	myDataTable = new DataTable
		name: "myTable"
		fields: dataFields
		data: data
	```

4. 
	Finally, we have to call the object's start-function.
	```coffeescript
	myDataTable.start()
	```

```div-parameter
@@include(datatable_p.md)
```




