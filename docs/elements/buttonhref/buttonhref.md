# ButtonHref
<span class="inheritance">
<a href="#Documentation/core/dom">DOM</a>
<a class="inheritance" href="#Documentation/elements/button">Button</a>
<a class="inheritance" href="#Documentation/elements/buttonhref"><mark>ButtonHref</mark></a>
</span>
***

## Description
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

## Creating a ButtonHref

##### instructions

1. 
	To build a new ButtonHref you simply create a new object of the type *ButtonHref*.
	```coffeescript
	new ButtonHref
		text: "Search the web"
		appearance: "auto"
		href: "https://duckduckgo.com/"
		target: "_blank"
	```
2. In order to define the functionality of your ButtonHref, you can add a list of parameters with the structure of a JSON-Object.
 
 At the <a href="#parameter">bottom of this page</a> you can find the complete list of possible parameter as well as their formats, default values and so on. <br />
 Note that some parameters are mandatory.
 


@@include(buttonhref_p.md)
