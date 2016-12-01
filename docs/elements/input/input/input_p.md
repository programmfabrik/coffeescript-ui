## Parameter Input

|	Parameter	|	Format	|	Default	|	Mandatory	|	Description	| 
|	---	|	---	|	:---:	|	:---:	|	---	|
|	spellcheck	|	&lt;Object&gt; = Icon	|	false	|	no	|	Lorem	|
|	autocomplete	|	<dt>&lt;Boolean&gt;	| false	|	no	|	<dt>true<dd><dt>false<dd>	|
|	overwrite: | <dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd><dt>false<dd>	|
|	emptyHint	|	<dt>&lt;String&gt;<dt>&lt;Object&gt; = Label<dt>&lt;Object&gt; = PlainObject	|	-	|	no	|	Lorem	|
|	invalidHint	|	<dt>&lt;String&gt;<dt>&lt;Object&gt; = Label<dt>&lt;Object&gt; = PlainObject	|	-	|	no	|	Lorem	|
|	validHint	|	<dt>&lt;String&gt;<dt>&lt;Object&gt; = Label<dt>&lt;Object&gt; = PlainObject	|	-	|	no	|	Lorem	|
|	incNumbers	|	<dt>&lt;Boolean&gt;	|	true	|	no	|	<dt>true<dd><dt>false<dd>	|
|	regexp	|	<dt>&lt;String&gt;	|	-	|	no	|	Lorem	|
|	regexp_flags	|	<dt>&lt;String&gt;	|	*empty string*	|	no	|	Lorem	|
|	placeholder	|	<dt>&lt;String&gt;	|	-	|	no	|	Lorem	|
|	readonly	|	<dt>&lt;Boolean&gt;	|	-	|	no	|	<dt>true<dd><dt>false<dd>	|
|	readonly_select_all	 |	<dt>&lt;Boolean&gt;	|	true	|	no	|	<dt>true<dd><dt>false<dd>	|
|	textarea	|	<dt>&lt;Boolean&gt;	|	-	|	no	|	<dt>true<dd><dt>false<dd>	|
|	content_size	|	<dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd><dt>false<dd>	|
|	prevent_invalid_input	|	<dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd><dt>false<dd>	|
|	required	|	<dt>&lt;Boolean&gt;	|	false	|	no	|	<dt>true<dd><dt>false<dd>	&nbsp;	|


## Callbacks Input

|	Callback	|	Format	|	Default	|	Mandatory	|	Description	| 
|	---	|	---	|	:---:	|	:---:	|	---	|
|	checkInput | <dt>function()	|	-	|	no	|	Lorem	|
|	getValueForDisplay	|	<dt>function()	|	-	|	no	|	Lorem	|
|	getValueForInput	|	<dt>function()	|	-	|	no	|	Lorem	|
|	correctValueForInput	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onFocus	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onClick	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onKeyup	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onSelectionchange	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onBlur	|	<dt>function()	|	-	|	no	|	Lorem	|
|	getInputBlocks	|	<dt>function()	|	-	|	no	|	Lorem	|
|	getCursorBlocks	|	<dt>function()() and not @_overwrite	|	-	|	no	|	Lorem	|


@@include(../../datafieldinput/datafieldinput_p.md)