## Parameter Layer

|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	backdrop	|	<dt>&lt;Object&gt; = PlainObject<dt>&lt;Boolean&gt; = false	|	<dt>policy:<dd>"click-thru"<dt>add_bounce_class:<dd>true<dt>content:<dd>null	|	no	|	Set to *true* if a backdrop should be added to the DOM tree	|
|	add_bounce_class	|	-	|	-	|	no	|	If added, a bounce class will be added and after a css transition removed to the layer, if the user clicks on a modal backdrop the bounce class defaults to "cui-layer-bounce". <br> *Deprecated: Use backdrop.add_bounce_class instead*
|	handle_focus	|	<dt>&lt;Boolean&gt;	|	true	|	no	|	Handle focus on tab index. <br> <dt>true<dd><dt>false<dd>	|
|	pointer	|	<dt>&lt;String&gt; = "arrow"	|	-	|	no	|	A rectangle box to position the layer to a pointer is a helper to show the position of the layer.	|
|	placement	|	<dt>&lt;String&gt;	|	-	|	no	|	The preferred placement	|
|	placements	|	<dt>&lt;Array&gt;<dt>if CUI.Layer.knownPlacements.indexOf(a) == -1 return false	|	-	|	no	|	Lorem
|	element	|	<dt>isElement<dt>isElement(v?.DOM)	|	-	|	no	|	Element to position the layer to.	|
|	use_element_width_as_min_width	|	dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd><dt>false<dd>	|
|	show_at_position	|	<dt>&lt;Object&gt; = PlainObject<dd>*and* top >= 0 *and* left >= 0	|	-	|	no	|	Lorem	|
|	fill_space	|	<dt>&lt;String&gt; = <dd>"auto" &#124; "both" &#124; "horizontal" &#124; "vertical"	|	"auto"	|	yes	|	Fills the available space to the maximum. If used with "placement", the placement is not chosen <br> <dt>auto><dd>Check if width or height is already set, use the other.<dt>both<dd>Overwrite width and height, no matter what.<dt>horizontal<dd>Stretch width only.<dt>vertical<dd>Stretch height only.	|
|	check_for_element	|	<dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd>The layer when shown checks if the "element" is still in the DOM tree.<dt>false<dd>
|	show_ms	|	<dt>&lt;Integer&gt; > 0	|	700	|	no	|	Lorem	|
|	hide_ms	|	<dt>&lt;Integer&gt; > 0	|	100	|	no	|	Lorem	|
|	visible	|	<dt>&lt;Boolean&gt;	|	-	|	no	|	<dt>true<dd><dt>false<dd>	&nbsp;	|


## Callbacks Layer

|	Callback	|	Format	|	Default	|	Mandatory	|	Description	| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	onBeforeShow	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onShow	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onPosition	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onHide	|	<dt>function()	|	-	|	no	|	Lorem	|



@@include(../../core/dom/dom_p.md)

