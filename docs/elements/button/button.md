# Button
<span class="inheritance">CUI.DOM
<a href="#Documentation/elements/button"><mark>Button</mark></a>
</span>
***

## Description
A button indicates possible user actions and responses depending on its functional description.

## Creating a Button
##### instructions
1. 
	To build a new button you simply create a new object of the type *&lt;Button&gt;*.
	```coffeescript
	myButton = new Button
		<parameter-as-json-object>
	```
	In order to define the visual appearance and functionality of your button, you can add a list of parameters with the structure of a JSON-Object.
 
 	At the <a href="#parameter">bottom of this page</a> you can find the complete list of possible parameter as well as their formats, default values and so on. <br />
 	Note that some parameters are mandatory.
2. 
	For example, this code will create a simple button which is causing an *alert* when clicked.
	 ```coffeescript
	@@include(button_exmpl1.coffee)
	```

@@include(button_p.md)


