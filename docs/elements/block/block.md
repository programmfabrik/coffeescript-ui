# Block
<span class="inheritance">CUI.DOM
<a href="#Documentation/elements/block"><mark>Block</mark></a>
</span>
***

## Description
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

```div-hallo
@@include(block_p.md)
<dt>titel
<dd>descr.
```

## Creating a Block

##### instructions

1. 
	To build a new Block you simply create a new object of the type *Block*.
	```coffeescript
	myBlock = new Block
		text: "Title of block"
		content: ...
	```
2. 
	A more complete block could look like this.
	```coffeescript
	myBlock = new Block
		text: "Recipe"
		content: [
			new Label
				text: "Cookies"
		,
			new Block
				text: "Ingredients"
				level: 2
				content:
					new Label
						text: "Flour, Sugar, Butter, Chocolate"
		,
			new Block
				text: "Instructions"
				level: 2
				content:
					new Label
						text: "Mix, Bake, Taste :)"
		]
	```
3. 
	In order to define the functionality of your Block, you can add a list of parameters with the structure of a JSON-Object.
 
 	At the <a href="#parameter">bottom of this page</a> you can find the complete list of possible parameter as well as their formats, default values and so on. <br />
 	Note that some parameters are mandatory.
 
 
 @@include(block_p.md)