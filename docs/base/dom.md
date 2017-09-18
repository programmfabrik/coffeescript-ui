# CUI.dom

CUI.dom has functions to manage our dom elements.

### CUI.dom.data(node, key, value)

- node `HTMLElement`
- key `String` | `PlainObject`
- value `Object`

It sets a **value** inside the **node** referenced by the **key**, and returns the **node**

If **value** is undefined, it gets the value referenced by the **key** in the **node**.

If **key** is undefined, it gets an `Object` with all the values in the **node**  

If **key** is an `Object`, *CUI.dom.data* is called once for each *key-value* inside the object. 

#### Examples

```
CUI.dom.data(div, "id", "idValue")
> <div>​</div>​
 
CUI.dom.data(div, "id")
> "idValue"
 
CUI.dom.data(div, {keyOne: "valueOne", keyTwo: "valueTwo"})
> <div></div>​
 
CUI.dom.data(div)
> {id: "myId", keyOne: "valueOne", keyTwo: "valueTwo"}
```

### CUI.dom.setElement(node, element)

It invokes **CUI.dom.data** with *"element"* string as the key.

    CUI.dom.data(node, "element", element)

### CUI.dom.removeData(node, key)

- node `HTMLElement`
- key `String`

It removes the value referenced by the **key** inside the data of **node** and returns the **node**

#### Example

    CUI.dom.data(div, "id")
    > "myId"
     
    CUI.dom.removeData(div, "id")
    > <div>​</div>​
     
    CUI.dom.data(div, "id")
    > undefined

### CUI.dom.findElements(node, selector, nodeFilter, maxEls, forward, siblingOnly, elements)

- node `HTMLElement` (default value: *document.documentElement*)
- selector `String` (default value: *null*)
- nodeFilter `Function` (default value: *false*)
    - It receives **node** as parameter and returns a `Boolean`. **node** will be ignored in the output if it returns *false*
- maxEls `Number` (default value: *null*)
    - Maximum quantity of elements as output
- forward `Boolean` (default value: *true*)
    - If *true* the search will be performed in the node and its next siblings. 
    - If *false* the search will be performed in the node and its previous siblings
    - Also it indicates what order of children nodes will be in the output.
- siblingOnly `Boolean` (default value: *false*)
    - Flag to indicate that only siblings will be in the output and children nodes will be ignored.
- elements `Array` of `HTMLElement` (default value: *[ ]*)
    - Output array.

It gets all the elements inside the **node** (siblings and children) matched by the **selector**

#### Examples

HTML:

```html
    <div class="sibling previous-sibling">
    	<div class="child child-previous-sibling"></div>
    </div>
     
    <div id="div">
        <div class="child first-element">
        	<div class="child child-first-element"></div>
        </div>
        <div class="child second-element"></div>
        <div class="child last-element"></div>
    	<div class="child child-last-element"></div>
    </div>
    
    <div class="sibling next-sibling">
        <div class="child child-next-sibling"></div>    
    </div>
```

Usages:
       
    CUI.dom.findElements(div, ".child")
    > (6) [div.child.first-element, div.child.child-first-element, 
           div.child.second-element, div.child.last-element, 
           div.child.child-last-element, div.child.child-next-sibling]
     
    CUI.dom.findElements(div, ".child", false, 2)
    > (2) [div.child.first-element, div.child.child-first-element]
     
    CUI.dom.findElements(div, ".child", false, 10, false)
    > (6) [div.child.last-element, div.child.child-last-element, 
         div.child.second-element, div.child.first-element, 
         div.child.child-first-element, div.child.child-previous-sibling]
     
    CUI.dom.findElements(div, ".child", false, 10, true, true)
    > []

### CUI.dom.findElement(node, selector, nodeFilter, forward, siblingOnly)

It uses *CUI.dom.findElements* function and returns the first element found. It returns *null* if no element was found.

#### Example

    CUI.dom.findElement(div, ".child")
    > <div class=​"child first-element">​</div>​
     
    CUI.dom.findElement(div, ".no-exist")
    > null

### CUI.dom.findNextElement(node, selector, nodeFilter, forward, siblingOnly)

It uses **CUI.dom.findElement** function and returns the first element found. 
The difference between **CUI.dom.findElement** and this function is that this function also searches for the element inside his parent's siblings and so on.

#### Example
       
    CUI.dom.findNextElement(div, ".sibling", false, false)
    > <div class=​"sibling previous-sibling">​…​</div>​
     
    CUI.dom.findNextElement(div, ".sibling", false, true)
    > <div class=​"sibling next-sibling">​…​</div>​


### CUI.dom.findPreviousElement(node, selector, nodeFilter)

It uses **CUI.dom.findNextElement** with the **forward** parameter with *false* as value.

#### Example

    CUI.dom.findPreviousElement(div, ".sibling")
    > <div class=​"sibling previous-sibling">​…​</div>​

### CUI.dom.findNextVisibleElement(node, selector, forward)

It uses **CUI.dom.findNextElement** with a function as parameter to filter the output node. This node has to be visible. 

### CUI.dom.findPreviousVisibleElement(node, selector)

It uses **CUI.dom.findNextVisibleElement** with the **forward** parameter with *false* as value

### CUI.dom.findNextSiblings(node, selector, nodeFilter)

It uses **CUI.dom.findElements** with the **forward** parameter with *true* as value and the **siblingOnly** parameter with *true* as value

### CUI.dom.findPreviousSiblings(node, selector, nodeFilter)

It uses **CUI.dom.findElements** with the **forward** parameter with *false* as value and the **siblingOnly** parameter with *true* as value

### CUI.dom.children(node, filter)

- node `HTMLElement`
- filter `HTMLElement` | `Function` | `String`

It returns an array with all children of **node**

If **filter** is a `String`, it should be a selector.

If **filter** is a `Function`, it should receive **node** as parameter and returns a `Boolean`

#### Examples

    <div id="div">
        <span class="child"></span>
        <div class="child noFilter"></div>
    <div>
     
    CUI.dom.children(div)
    > (2) [span.child, div.child]
     
    CUI.dom.children(div, ".noFilter")
    > [div.child.noFilter]
     
    filterFunction = (node) -> CUI.dom.hasClass(node, "noFilter")
    CUI.dom.children(div, filterFunction)
    > [div.child.noFilter]
     
    CUI.dom.children(div, div.firstElementChild)
    > [span.child]
    

### CUI.dom.firstElementChild(node, filter)

It gets the first child of **node** which returns true in the **filter** function. The iteration will be from first child to last child.

Returns null if no child were found.

### CUI.dom.firstElementChild(node, filter)

It gets the first child of **node** which returns true in the **filter** function. The iteration will be from last child to first child.

Returns null if no child were found.

### CUI.dom.setAttribute(node, key, value)

- node `HTMLElement`
- key `String`
- value `String` | `Boolean`

It sets an attribute called **key** in the **node** with **value** and returns the **node**

If **value** is *null* or *false* it removes the value inside the **key** attribute.

If **value** is *true*, the value inside the **key** attribute will be **key**

#### Example

    CUI.dom.setAttribute(div, "id", "idValue")
    > <div id=​"idValue">​</div>​
     
    CUI.dom.setAttribute(div, "enabled", true)
    > <div id=​"idValue" enabled=​"enabled">​</div>​
     
    CUI.dom.setAttribute(div, "enabled", false)
    > <div id=​"idValue">​</div>​

### CUI.dom.removeAttribute(node, key)

- node `HTMLElement`
- key `String`

It removes the attribute **key** in the **node** and returns the **node**

#### Example

    CUI.dom.setAttribute(div, "id", "idValue")
    > <div id=​"idValue">​</div>​
     
    CUI.dom.removeAttribute(div, "id")
    > <div>​</div>​

### CUI.dom.getAttribute(node, key)

- node `HTMLElement`
- key `String`

It returns the *value* stored inside **key** attribute of **node**

    CUI.dom.setAttribute(div, "id", "idValue")
    > <div id=​"idValue">​</div>​
     
    CUI.dom.getAttribute(div, "id")
    > "idValue"

### CUI.dom.hasAttribute(node, key)

Returns *false* or *true* if **node** has an attribute called **key**

    CUI.dom.setAttribute(div, "id", "idValue")
    > <div id=​"idValue">​</div>​
        
    CUI.dom.hasAttribute(div, "id")
    > true
    CUI.dom.hasAttribute(div, "no-exists")
    > false

### CUI.dom.setAttributeMap(node, map)

- node `HTMLElement`
- map `PlainObject`
    - key `String`
    - value `String` | `Boolean`
    
It invokes **CUI.dom.setAttribute** once for each **key-value** inside **map**


### CUI.dom.width(element, value)

- element `HTMLElement`| `window` | `document`
- value `Number`

It sets the width of the **element** with **value** or it returns the width of **element** if value is not passed as argument.

If element is `window` or `document` it returns the width of the `window`. It's necessary not to pass **value** as argument in this case.

#### Example

    CUI.dom.width(div, 10)
    > {width: 10}
    CUI.dom.width(div)
    > 10
    div
    > <div id=​"div" style=​"width:​ 10px;​">​</div>​
     
    CUI.dom.width(window)
    > 1100
    
### CUI.dom.height(element, value)

- element `HTMLElement`| `window` | `document`
- value `Number`

It sets the height of the **element** with **value** or it returns the height of **element** if value is not passed as argument.

If element is `window` or `document` it returns the height of the `window`. It's necessary not to pass **value** as argument in this case.

#### Example

    CUI.dom.height(div, 10)
    > {height: 10}
    CUI.dom.height(div)
    > 10
    div
    > <div id=​"div" style=​"height:​ 10px;​">​</div>​
     
    CUI.dom.height(window)
    > 800


### CUI.dom.replace(node, content)

- node `HTMLElement`
- content `HTMLElement` | `String`

It removes the current content inside **node** and appends the **content** in the **node**

#### Example

    div
    > <div id="div">
        <p></p>
      </div>
     
    CUI.dom.replace(div, span)
    > <div id="div">
        <span></span>
      </div>

### CUI.dom.append(node, content)

- node `HTMLElement`
- content `HTMLElement` | `Node` | `Number` | `Boolean` | `String` | `HTMLCollection` | `NodeList`

It is a extended version of *HTML DOM appendChild()*. It accepts different types of *content* which will be appended in the node.

#### Examples

    div
    > <div>
        <span class="existing-span"></span>
      </div>
    CUI.dom.append(div, span)
    > <div>
        <span class="existing-span"></span>
        <span></span>
      </div>​
       
    spans
    > (3) [span, span, span]
    CUI.dom.append(div, spans)
    > <div>
        <span></span>
        <span></span>​
        <span></span>​
      </div>​
            
    texts
    > (2) ["Hello", "World"]
    CUI.dom.append(div, texts)
    > <div>
        "Hello"
        "World"
      </div>​
      
    nodes
    > (2) [text, text]
    CUI.dom.append(div, nodes)
    > <div>
        "node"
        "nodeTwo"
      </div>​

### CUI.dom.prepend(node, content)

- node `HTMLElement`
- content `HTMLElement` | `Node` | `Number` | `Boolean` | `String` | `HTMLCollection` | `NodeList`

It is a extended version of *HTML DOM insertBefore()*. It accepts different types of **content** which will be inserted before the **node**.

#### Examples

    div
    > <div>
        <span class="existing-span"></span>
      </div>
    CUI.dom.prepend(div, span)
    > <div>
        <span></span>
        <span class="existing-span"></span>
      </div>​
      
*See CUI.dom.append examples, are very similar*

### CUI.dom.remove(element)

- element `HTMLElement`

It removes the **element** and returns it.

#### Example

    div
    > <div>
        ​<span></span>
      ​</div>​
    CUI.dom.remove(span)
    > <span></span>​
    div
    > <div></div>​

### CUI.dom.empty(element)

- element `HTMLElement`

It removes all child elements inside the **element**

    div
    > <div>
        ​<span></span>​
      </div>​
    CUI.dom.empty(div)
    > <div></div>​
    
### CUI.dom.hasClass(element, class)

- element `HTMLElement`
- class `String`

It returns a `Boolean` depending if the *class* is present in the *classList* of the **element**.
By sending a `String` with the **classes** separated by spaces, it returns *true* if any of those **classes** is present.

#### Examples

    div
    > <div class=​"a-class"></div>​
     
    CUI.dom.hasClass(div, "a-class")
    > true
     
    CUI.dom.hasClass(div, "b-class")
    > false
     
    CUI.dom.hasClass(div, "a-class b-class")
    > true

### CUI.dom.addClass(element, class)

- element `HTMLElement`
- class `String`

It adds the **class** to the *classList* of the **element**. 
It is possible to add a list of classes, by sending a `String` with the **classes** separated by spaces.

#### Examples

    CUI.dom.addClass(div, "a-class")
    > <div class=​a-class"></div>​
     
    CUI.dom.addClass(div, "b-class c-class")
    > <div class="a-class b-class c-class"></div>​

### CUI.dom.removeClass(element, class)

- element `HTMLElement`
- class `String`

It removes the **class** from the *classList* of the **element**. 
It is possible to remove a list of classes, by sending a `String` with the **classes** separated by spaces.

#### Examples

    div
    > <div class="a-class b-class c-class d-class"></div>​
     
    CUI.dom.removeClass(div, "a-class")
    > <div class="b-class c-class d-class"></div>​
     
    CUI.dom.removeClass(div, "b-class c-class")
    > <div class="d-class"></div>​

### CUI.dom.setClass(element, class, on_off)

- element `HTMLElement`
- class `String`
- on_off `Boolean`

It adds or removes a **class** of the *classList* of the **element** depending the **on_off** argument.

If **on_off** argument is *true*, it adds the **class**

If **on_off** argument is *false*, it removes the **class**

#### Examples

    div
    > <div class=​"a-class b-class">​</div>​
     
    CUI.dom.setClass(div, "c-class", true)
    > true
    div
    > <div class=​"a-class b-class c-class">​</div>​
     
    CUI.dom.setClass(div, "c-class", false)
    > false
    div
    > <div class=​"a-class b-class">​</div>​


### CUI.dom.toggleClass(element, cls)

- element `HTMLElement`
- class `String`

It adds or removes a **class** of the *classList* of the **element** depending in its current presence.

#### Example

    div
    > <div class=​"a-class"></div>​
     
    CUI.dom.toggleClass(div, "b-class")
    > true
    div
    > <div class=​"a-class b-class">​</div>​
     
    CUI.dom.toggleClass(div, "b-class")
    > false
    div
    > <div class=​"a-class">​</div>​

### CUI.dom.setAria(element, key, value)

- element `HTMLElement`
- key `String`
- value `String` | `Boolean`

It invokes **CUI.dom.setAttribute** appending the string "*aria-*" to the **key**

#### Example

    CUI.dom.setAria(div, "attributekey", "attributeValue")
    > <div aria-attributekey=​"attributeValue">​</div>​  

### CUI.dom.getRelativeOffset(element, untilElement, ignore_margin)

- element `HTMLElement`
- untilElement `HTMLElement` (default value: *null*)
- ignore_margin `Boolean` (default value: *false*)

It returns the relative offset of the **element** until the **untilElement**.

If **untilElement** is *null*, the offset will be until the *body*.

If **ignore_margin** is *true*, the offset will includes the margin of the **element**.

#### Examples

```html
<div id="parent">
    <div id="child" style="height: 20px;"></div>
    <div id="child_parent" style="padding-top:10px;">
        <p style="margin-top:5px;">Hello world</p>
    </div>
</div>
```

    CUI.dom.getRelativeOffset(p)
    > {parent: body, top: 30, left: 0}
     
    CUI.dom.getRelativeOffset(p, parent)
    > {parent: div#parent, top: 30, left: 0}
     
    CUI.dom.getRelativeOffset(p, child_parent)
    > {parent: div#child_parent, top: 10, left: 0}
     
    CUI.dom.getRelativeOffset(p, child_parent, true)
    > {parent: div#child_parent, top: 15, left: 0}

### CUI.dom.getRelativePosition(element)

- element `HTMLElement`

It returns the relative position of the **element**

#### Examples

```html
<div id="div" style="margin-left: 50px; margin-top: 100px;">
    <p style="margin-top:50px;">Hello world</p>
</div>
```

    CUI.dom.getRelativePosition(p)
    > {top: 150, left: 50}

### CUI.dom.hasAnimatedClone(node)
### CUI.dom.initAnimatedClone(node, selector)
### CUI.dom.syncAnimatedClone(node)
### CUI.dom.removeAnimatedClone(node)
### CUI.dom.setAbsolutePosition(element, offset)
### CUI.dom.waitForDOMRemove(options)
### CUI.dom.waitForDOMInsert(options)
### CUI.dom.getNode(node)
### CUI.dom.isNode(node)
### CUI.dom.insertChildAtPosition(node, node_insert, position)
### CUI.dom.insertBefore(node, node_before)
### CUI.dom.insertAfter(node, node_after)
### CUI.dom.is(node, selector)
### CUI.dom.matches(node, selector)
### CUI.dom.matchSelector(element, selector, trySelf)
### CUI.dom.find(selector)
### CUI.dom.elementsUntil(element, selector, untilElement)
### CUI.dom.parent(element)
### CUI.dom.closestUntil(element, selector, untilElement)
### CUI.dom.closest(element, selector)
### CUI.dom.parentsUntil(element, selector, untilElement)
### CUI.dom.parents(element, selector, untilElement)
### CUI.dom.isInDom(element)
### CUI.dom.replaceWith(node, new_node)
### CUI.dom.getRect(element)
### CUI.dom.getComputedStyle(element)
### CUI.dom.setStyle(element, style, append)
### CUI.dom.setStyleOne(element, key, value)
### CUI.dom.getDimensions(element)
### CUI.dom.parentsScrollable(node)
### CUI.dom.setDimension(element, key, value)
### CUI.dom.getDimension(element, key)
### CUI.dom.prepareSetDimensions(element)
### CUI.dom.setDimensions(element, dimension)
### CUI.dom.htmlToNodes(html)
### CUI.dom.findTextInNodes(nodes, callback, texts)
### CUI.dom.getCSSFloatValue(value)
### CUI.dom.isPositioned(element)
### CUI.dom.isVisible(element)
### CUI.dom.getBoxSizing(element)
### CUI.dom.isBorderBox(element)
### CUI.dom.isContentBox(element)
### CUI.dom.hideElement(element)
### CUI.dom.removeChildren(element, filter)
### CUI.dom.showElement(element)
### CUI.dom.space(style)
### CUI.dom.element(tagName, attributes)
### CUI.dom.scrollIntoView(element)
### CUI.dom.setClassOnMousemove(options)
### CUI.dom.requestFullscreen(element)
### CUI.dom.exitFullscreen()
### CUI.dom.fullscreenElement()
### CUI.dom.fullscreenEnabled()
### CUI.dom.isFullscreen()
### CUI.dom.$element(tagName, class, attributes, no_tables)
### CUI.dom.div(class, attributes)
### CUI.dom.video(class, attributes)
### CUI.dom.audio(class, attributes)
### CUI.dom.source(class, attributes)
### CUI.dom.span(class, attributes)
### CUI.dom.table(class, attributes)
### CUI.dom.img(class, attributes)
### CUI.dom.tr(class, attributes)
### CUI.dom.th(class, attributes)
### CUI.dom.td(class, attributes)
### CUI.dom.i(class, attributes)
### CUI.dom.p(class, attributes)
### CUI.dom.pre(class, attributes)
### CUI.dom.ul(class, attributes)
### CUI.dom.a(class, attributes)
### CUI.dom.b(class, attributes)
### CUI.dom.li(class, attributes)
### CUI.dom.label(class, attributes)
### CUI.dom.h1(class, attributes)
### CUI.dom.h2(class, attributes)
### CUI.dom.h3(class, attributes)
### CUI.dom.h4(class, attributes)
### CUI.dom.h5(class, attributes)
### CUI.dom.h6(class, attributes)
### CUI.dom.text(text, class, attributes)
### CUI.dom.textEmpty(text)
### CUI.dom.table_one_row()
### CUI.dom.tr_one_row()
### CUI.dom.
### CUI.dom.
### CUI.dom.

*Note: All the examples above were made in the browser's console.*