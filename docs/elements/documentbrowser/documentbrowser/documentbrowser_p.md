## Parameter DocumentBrowser
|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	marked_opts	|	<dt>&lt;Object&gt; = PlainObject<dd>*Must not contain "image" or "link" as key.*	|	{}	|	true	|	Lorem	|
|	url	|	(v) -> !!CUI.parseLocation(v)  ??	|	-	|	no	|	Lorem	|


## Callbacks DocumentBrowser
|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|	gotoLocation	|	<dt>function()	|	(nodePath, search, nodeIdx) => @loadLocation(nodePath, search, nodeIdx)	|	no	|	Lorem	|
|	getMarkdown	|	<dt>function()	|	(v) -> v	|	no	|	Lorem	|
|	renderHref	|	<dt>function()	|	default: (href, nodePath) => href	|	no	|	Lorem	|


@@include(../../../core/element/element_p.md)