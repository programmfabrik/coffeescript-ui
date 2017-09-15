# Button
<span class="inheritance">
<a href="#Documentation/core/dom">DOM</a>
<a class="inheritance" href="#Documentation/elements/button"><mark>Button</mark></a>
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


<svg width="35px" height="985px" viewBox="0 0 35 985" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <!-- Generator: Sketch 41.2 (35397) - http://www.bohemiancoding.com/sketch -->
    <desc>Created with Sketch.</desc>
    <defs></defs>
    <g id="Group" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" transform="translate(4.000000, 0.000000)">
        <rect id="Rectangle-2" fill="#5FDCC7" x="12" y="19.7987928" width="11" height="964.201207"></rect>
        <polygon id="Triangle" fill="#5FDBC6" points="17.5 0 35 20.7887324 0 20.7887324"></polygon>
        <rect id="Rectangle-3" fill="#5FDBC6" x="0" y="973.110664" width="35" height="10.889336"></rect>
    </g>
</svg>

@@include(button_p.md)



