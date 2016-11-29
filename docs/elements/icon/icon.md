# Icon
<span class="inheritance">CUI-Element
<a href="#Documentation/elements/icon"><mark>Icon</mark></a>
</span>
***

## Description
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.



## Creating a Icon

##### instructions

1. 
	To build a new Icon you simply create a new object of the type *Icon*.
	
	```coffeescript
	myIcon = new Icon
		class: "fa-angle-double-down"
	```

2. 
	In order to define the visual appearance and functionality of your Icon, you can add a list of parameters with the structure of a JSON-Object.<br />
	At the <a href="#parameter">bottom of this page</a> you can find the complete list of possible parameter as well as their formats, default values and so on.

	Note that some parameters are mandatory.

3. 
	We can use icons inside of labels. Therefor we could either create an object of the type as a value of the label's icon property:

	```coffeescript
	myLabel = new Label
		text: "Some text"
		icon: new Icon(class: "fa-lightbulb-o")
	```

	Or, as the label's parameter icon also accepts values of the type String, we can name the wanted icon directly without creating an object:
	
	```coffeescript
	myLabel = new Label
		text: "Kalender"
		icon: "calendar"
	```

	At the bottom of this page you find an overview of all possible icons.


## Icon Styles

<img src="css/icons.svg" alt>
<picture>
    <source srcset="css/icons.svg" type="image/svg+xml">
</picture>


@@include(icon_p.md)






