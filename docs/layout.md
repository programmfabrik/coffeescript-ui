= Layout > DOM

  * general class to handle space offering DIVs
  * needs to be subclassed
  * maximize: sets cui-maximize
  * absolute: sets cui-absolute

= HorizontalLayout > Layout

  * left: adds a left pane
  * right: adds a right pane

  * depending on parameters this layout has four different markups
   * with flexHandles: DIV > DIV.left + DIV.flexHandle + DIV.center + DIV.flexHandle + DIV.right
   * left + right: DIV > DIV.left + DIV.center + DIV.right
   * right: DIV > DIV.center + DIV.right
   * left: DIV > DIV.left + DIV.center

  * no padding!
  * center DIV is always there

  * in maximize mode, center grows & shrinks, left & right don't shrink and don't grow
  * in non maximize mode, all cells don't grow and don't shrink
  * in maximize mode all cells have scrollbars
  * all cells have vertical layout for their content

= VerticalLayout > Layout

like HorizontalLayout

* no padding!

= BorderLayout > Layout

* is always maximized
* combines vertical and horizontal layout
* parameters: north, west, east, south, center
* no padding

= Pane > VerticalLayout

* is always "maximized"
* padding in center
* no padding in top, bottom

= Toolbar > HorizontalLayout

* always maxmized
* is like PaneHeader and Footer but looks different and can be stacked below PaneHeader and above PaneFooter
* Toolbar can only be subclasses, not used directly

= PaneToolbar > Toolbar

* Toolbar can only be inside Panes in top or bottom

= PaneHeader > Toolbar

* adds a class "cui-pane-header"
* always maximized
* has always left, center, right, never flexHandles
* adds padding in left, center, right

= PaneFooter > Toolbar

* adds a class "cui-pane-header"
* like pane header

= SimplePane > Pane

convenience class to create a Pane with header and footer

parameter: header_left, header_center, header_right
parameter: center
parameter: footer_left, footer_right

* looks exactly like Pane, PaneHeader, PaneFooter


= VerticalList > VerticalLayout

* maximize is always false
* allows only cui-dom-element inside

= ItemList > VerticalLayout

* vertical stack of items
* looks exactly like vertical list
* maximize is always false

= Layer > DOM

* floats atop, is just a rectangle
* no padding, no decoration, nothing
* is there for positioning and z-layer management

= LayerPane > Layer

* adds SimplePane to the Layer, or another Pane

= Menu > Layer

* gets an itemList
* has special positioning

= Modal > LayerPane

* looks like a Pane, but might have slightly bigger paddings

= ConfirmationDialog > Modal

* looks like Modal but has a distinct property so that the user
  recognizes the dialog box

= Tooltip > LayerPane

* looks like a tooltip (with little arrows)

= ConfirmationChoice > ConfirmationDialog

* looks exactly like dialog, but has convenience methods
  to create buttons

= Popover > Modal

* is often a smaller version of a Modal dialog

= ListView > Pane

* is a pane but has no padding and is not always maximized


