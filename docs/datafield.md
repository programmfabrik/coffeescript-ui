= DataField > DOM



= DataFieldInput > DataField

* lives in a context (e.g. Form, FieldsRenderer)
* context sets the width of the data field input
* the input sets the height



= Input > DataFieldInput

* html input element or html textarea element
* textarea sets a height or is as height as its content requires



= Ouptut > DataFieldInput

= MultiOutput > Output

= Checkbox > DataFieldInput

= MultiInput > DataFieldInput

* has a DIV holding multiple inputs
* inputs are specialized "Inputs" with a right side (like DateTime)

= Options > DataField

* uses a Form with Checkboxes
* can be rendered as horizontal form
* can have "sortable" set (vertical only)

= DataTable > DataFieldInput

* is a ListView


= DateTime > Input

* specialized Input with right side for calendar icon

= NumberInput > Input

* like Input only different format

= EmailInput > Input

* like Input only different format

= Password > Input

* like Input only different format and hidden characters



= Form > DataField

* html TABLE with three column (label, field, right)
* when rendered in horizontal mode: tr.labels, tr.fields, tr.rights
* adds padding to its cells
* for FORM inside FORM cells, the padding is 0


