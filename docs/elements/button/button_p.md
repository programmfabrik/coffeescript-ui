## Parameter Button

|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	size				|	<dt>&lt;String&gt; = <dd>"auto" &#124; "mini" &#124; "normal" &#124; "big" &#124; "bigger"	|	`auto`	|	yes	|		Describes the button's size.<dt>`auto`<dd>The button is automatically formatted. e.g. when a button is in the lower right corner of a ConfirmationDialog it shown as big button.<dt>`mini`<dd>Small button.<dt>`normal`<dd>Medium sized button.<dt>`big`<dd>Big sized button.<dt>`bigger`<dd>Even bigger sized button.		|
|	appearance			|	<dt>&lt;String&gt; = <dd>"auto" &#124; "link" &#124; "flat" &#124; "normal" &#124; "important"	|	`auto`	|	yes	|		Describes the button's visual appearance.<dt>`auto`<dd>The button is automatically formatted.<dt>`link`<dd>Standard button without border and a underlined text.<dt>`flat`<dd>Button has no border and inherits its background color from its parent div.<dt>`normal`<dd>Standard button with border and its own background color.<dt>`important`<dd>emphasized button to show the user that the button is important.	|
|	primary				|	<dt>&lt;Boolean&gt;	|	`false`	|	yes			|		<dt>true<dd><dt>false<dd>		|
|	click_type			|	<dt>&lt;String&gt; = <dd>"click" &#124; "mouseup" &#124; "dbclick" &#124; "touchstart" &#124; "touched"	|	`click`	|	yes	|	Required user's action to call *onclick*-function<dt>`click`<dd>Normal single click<dt>`mouseup`<dt>`dblclick`<dd>Doubleclick<dt>`touchstart`<dt>`touchend`	|
|	tabindex			|	<dt>&lt;Integer&gt;<dt>&lt;Boolean&gt;	|	`0`		|	no 	|	<dt>`false`<dt>`1`<dt>`2`<dt>`...`	|
|	role				|	<dt>&lt;String&gt;	|	button		|	no 	|		|
|	confirm_on_click	|	<dt>&lt;String&gt;	|	-	|	no 	|		|
|	text 				|	<dt>&lt;String&gt;	|	-	|	no 	|		|
|	tooltip				|	<dt>PlainObject`	|	-	|	no 	|		|
|	disabled			|	<dt>&lt;Boolean&gt;<dt>function()	|	`false`		|	no 	|	<dt>true<dd><dt>false<dd>	|
|	active_css_class	|	<dt>&lt;String&gt;	|	-	|	no	|		|
|	left 				|	<dt>true<dt>&lt;Object&gt; = CUI-Element<dt>&lt;String&gt;	|		-		|	no 	|	<dt>true<dt>Element<dt>String		<br>*Must not be one of the following elements: `icon`, `icon_left`, `icon_active`, `icon_inactive`*	|
|	right 				|	<dt>true<dt>Content	|	-	|	no 	|	<dt>true<dt>Content		<br>*Must not be one of the following elements: `icon_right`*	|
|	center 				|	<dt>`Element`<dt>`String`	|	-	|	no 	|		|
|	icon 				|	<dt>&lt;Object&gt; = Icon<dt>&lt;String&gt;	|	-	|	no 	|	<dt>Icon-Element<dd><dt>Name of Icon as String<dd>	|	
|	icon_left			|	<dt>&lt;Object&gt; = Icon<dt>&lt;String&gt;	|	-	|	no 	|	<dt>Icon-Element<dd><dt>Name of Icon as String<dd>	|	
|	icon_right			|	<dt>&lt;Object&gt; = Icon<dt>&lt;String&gt;<dt>&lt;Boolean&gt;	|	-	|	no 	|	<dt>Icon-Element<dd><dt>Name of Icon as String<dd><dt><true><dd><dt><false><dd>	|			
|	icon_active			|	<dt>&lt;Object&gt; = Icon<dt>&lt;String&gt;	|	-	|	no 	|	<dt>Icon-Element<dd><dt>Name of Icon as String<dd>	|	
|	icon_inactive		|	<dt>&lt;Object&gt; = Icon<dt>&lt;String&gt;	|	-	|	no 	|	<dt>Icon-Element<dd><dt>Name of Icon as String<dd>	|	
|	text_active			|	<dt>&lt;String&gt;	|	-	|	no 	|		|
|	text_inactive		|	<dt>&lt;String&gt;	|	-	|	no 	|		|
|	attr 				|	<dt>PlainObject	|	{}	|	no 	|		|
|	name 				|	<dt>&lt;String&gt;	|	-	|	no 	|		|
|	hidden				|	<dt>&lt;Boolean&gt;<dt>function()	|	-	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	menu				|	<dt>PlainObject	|	-	|	no 	|				|
|	menu_on_hover		|	<dt>&lt;Boolean&gt;	|	-	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	menu_parent			|	? Menu 	|	-	|	no 			|		|
|	menu				|	<dt>PlainObject	|	-	|	no 	|		|
|	radio 				|	<dt>&lt;String&gt;<dt>&lt;Boolean&gt;	|	-	|	no 			|	<dt>true<dd><dt>false<dd>	|
|	radio_allow_null	|	<dt>&lt;Boolean&gt;	|	-	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	switch				|	<dt>&lt;Boolean&gt;	|	-	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	active				|	<dt>&lt;Boolean&gt;	|	-	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	activate_initial	|	<dt>&lt;Boolean&gt;	|	true	|	no 	|	<dt>true<dd><dt>false<dd>	|
|	group				|	<dt>&lt;String&gt;	|	-	|	no 	|	&nbsp;	|			


## Callbacks Button

|	Callback	|	Format	|	Default	|	Mandatory	|	Description	| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	onClick 			|	<dt>function()	|	-	|	no 	|	Functional description of the button's response to the user's click.	|
|	onActivate 			|	<dt>function()	|	-	|	no 	|		|
|	onDeactivate 		|	<dt>function()	|	-	|	no 	|	&nbsp;	|


@@include(../../core/dom/dom_p.md)