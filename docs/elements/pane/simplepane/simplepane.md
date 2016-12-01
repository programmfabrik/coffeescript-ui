# SimplePane
<span class="inheritance">
<a href="#Documentation/core/dom">DOM</a>
<a class="inheritance" href="#Documentation/elements/layout/layout">Layout</a>
<a class="inheritance" href="#Documentation/elements/layout/verticallayout">VerticalLayout</a>
<a class="inheritance" href="#Documentation/elements/pane/pane">Pane</a>
<a class="inheritance" href="#Documentation/elements/pane/simplepane"><mark>SimplePane</mark></a>
</span>
***

## Description
Displaying Content vertically. Has always a header at the top, a content area in the middle and a footer at its bottom.

<div style="width: 50%;">	
	<div style="border: 1px solid #d1d1d1" class="cui-tmpl-vertical-layout-top-center-bottom cui-layout cui-padding-reset cui-dom-element cui-simple-pane cui-maximize cui-maximize-horizontal cui-maximize-vertical cui-vertical-layout cui-pane" cui-absolute-container="column" id="cui-dom-element-55">
		<div class="cui-vertical-layout-top cui-layout-cell"><div class="cui-tmpl-horizontal-layout-left-center-right cui-layout cui-padding-reset cui-dom-element cui-pane-header cui-maximize-horizontal cui-horizontal-layout cui-toolbar" cui-absolute-container="row" id="cui-dom-element-56">
		<div class="cui-horizontal-layout-left cui-layout-cell"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-centered cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-49">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span>Header</span></div>
	</div></div>
		<div class="cui-horizontal-layout-center cui-layout-cell" cui-absolute-set="left,right"></div>
		<div class="cui-horizontal-layout-right cui-layout-cell"></div>
	</div></div>
		<div class="cui-vertical-layout-center cui-layout-cell" cui-absolute-set="top,bottom"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-centered cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-51">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span><br><br>Content<br><br><br></span></div>
	</div></div>
		<div class="cui-vertical-layout-bottom cui-layout-cell"><div class="cui-tmpl-horizontal-layout-left-center-right cui-layout cui-padding-reset cui-dom-element cui-pane-footer cui-maximize-horizontal cui-horizontal-layout cui-toolbar" cui-absolute-container="row" id="cui-dom-element-58">
		<div class="cui-horizontal-layout-left cui-layout-cell"></div>
		<div class="cui-horizontal-layout-center cui-layout-cell" cui-absolute-set="left,right"></div>
		<div class="cui-horizontal-layout-right cui-layout-cell"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-centered cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-53">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span>Footer</span></div>
	</div></div>
	</div></div>
	</div>
</div>

<br><br>
In order to place the content and align it within the areas, you can use the *structure* of <mark>slots</mark> (colored red below) which every SimplePane uses in the background.

<div style="width: 50%;">	
	<div style="border: 1px solid #d1d1d1" class="cui-tmpl-vertical-layout-top-center-bottom cui-layout cui-padding-reset cui-dom-element cui-simple-pane cui-maximize cui-maximize-horizontal cui-maximize-vertical cui-vertical-layout cui-pane" cui-absolute-container="column" id="cui-dom-element-292">
	<div class="cui-vertical-layout-top cui-layout-cell"><div class="cui-tmpl-horizontal-layout-left-center-right cui-layout cui-padding-reset cui-dom-element cui-pane-header cui-maximize-horizontal cui-horizontal-layout cui-toolbar" cui-absolute-container="row" id="cui-dom-element-293">
	<div class="cui-horizontal-layout-left cui-layout-cell"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-280">
	<div class="cui-label-icon"></div>
	<div style="background-color: #ffcccc;" class="cui-label-content"><span>header_left</span></div>
	</div></div>
		<div class="cui-horizontal-layout-center cui-layout-cell" cui-absolute-set="left,right"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-282">
		<div class="cui-label-icon"></div>
		<div style="background-color: #ffcccc;" class="cui-label-content"><span>header_center</span></div>
	</div></div>
		<div class="cui-horizontal-layout-right cui-layout-cell"><div class="cui-tmpl-label cui-dom-element cui-label cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-284">
		<div class="cui-label-icon"></div>
		<div style="background-color: #ffcccc;" class="cui-label-content"><span>header_right</span></div>
	</div></div>
	</div></div>
		<div class="cui-vertical-layout-center cui-layout-cell" cui-absolute-set="top,bottom"><div style="background-color: #ffcccc;" class="cui-tmpl-label cui-dom-element cui-label cui-label-centered cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-286">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span><br><br>center<br><br><br></span></div>
	</div></div>
		<div class="cui-vertical-layout-bottom cui-layout-cell"><div class="cui-tmpl-horizontal-layout-left-center-right cui-layout cui-padding-reset cui-dom-element cui-pane-footer cui-maximize-horizontal cui-horizontal-layout cui-toolbar" cui-absolute-container="row" id="cui-dom-element-295">
		<div class="cui-horizontal-layout-left cui-layout-cell"><div style="background-color: #ffcccc;" class="cui-tmpl-label cui-dom-element cui-label cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-288">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span>footer_left</span></div>
	</div></div>
		<div class="cui-horizontal-layout-center cui-layout-cell" cui-absolute-set="left,right"></div>
		<div class="cui-horizontal-layout-right cui-layout-cell"><div style="background-color: #ffcccc;" class="cui-tmpl-label cui-dom-element cui-label cui-label-size-normal cui-label-size-auto cui-label-appearance-normal cui-label-appearance-auto" id="cui-dom-element-290">
		<div class="cui-label-icon"></div>
		<div class="cui-label-content"><span>footer_right</span></div>
	</div></div>
	</div></div>
	</div>
</div>



## Creating a SimplePane

##### instructions

1. 
	To build a new SimplePane you simply create a new object of the type *SimplePane*.
	```coffeescript
	mySimplePane = new SimplePane(<parameter-as-json-object>);
	```
2. 
	In order to define the visual appearance and functionality of your SimplePane, you can add a list of parameters with the structure of a JSON-Object.
	
	Here is the code for the SimplePane displayed above:

	```coffeescript
	mySimplePane = new SimplePane
		header_left:
			new Label
				text: "Header"
		content:
			new Label
				text: "Content"
				centered: true
		footer_right:
			new Label
				text: "Footer"
	```
 
	This is a very simple example but it gives you the overall structure of any SimplePane ovject. At the <a href="#parameter">bottom of this page</a> you can find the complete list of possible parameter as well as their formats, default values and so on. <br />
	
	Note that some parameters are mandatory.

3. 
	As we can not only fill up a SimplePane with text but also insert other CUI-elements into the header-, content- and footer-areas, way more complex structures are possible.
	
	See the section Elements/Examples for mor complex demonstrations.


## Modifying a SimplePane

After a SimplePane has been created, you can modify its header-, content- and footer-area.
Therefore use the introduced <mark>slots</mark> to place the wanted content.


1. 
	Append new content to the slot *footer_left*:

	```coffeescript
	mySimplePane.append("Copyright Information","footer_left")
	```
2. 
	Replace the content of the slot *footer_left*:
	```coffeescript
	mySimplePane.replace("More Information","footer_left")
	```
3. 
	Empty the whole content the slot *footer_left*:
	```coffeescript
	mySimplePane.empty("footer_left")
	```


```div-parameter
@@include(simplepane_p.md)
```