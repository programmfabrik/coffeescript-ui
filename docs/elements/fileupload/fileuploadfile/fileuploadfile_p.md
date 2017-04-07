```div-parameter
## Parameter FileUploadFile
|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	file	|	<dt>Instance of &lt;Object&gt; = File	|	-	|	yes	|	Lorem	|
|	fileUpload	|	<dt>&lt;Object&gt; = FileUpload	|	-	|	yes	|	Lorem	|
|	batch	|	<dt>&lt;Integer&gt; >= 0	|	-	|	no	|	Lorem	|


## Callbacks FileUploadFile
|	Parameter			|			Format			|	Default					|	Mandatory	|	Description				| 
|		---				|			---				|	:---:					|	:---:		|		---					|
|	onRemove	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onDequeue	|	<dt>function()	|	-	|	no	|	Lorem	|
|	onBeforeDone	|	<dt>function()	|	-	|	no	|	Callback which can be used to let the file reject or resolve.	|
```

@@include(../../../core/element/element_p.md)