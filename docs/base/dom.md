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

### CUI.dom.removeData(node, key) : `Object`

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

### CUI.dom.findElements(node, selector, nodeFilter, maxEls, forward, siblingOnly, elements) : `[HTMLElement]`

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

### CUI.dom.findElement(node, selector, nodeFilter, forward, siblingOnly) : `HTMLElement`

It uses *CUI.dom.findElements* function and returns the first element found. It returns *null* if no element was found.

#### Example

    CUI.dom.findElement(div, ".child")
    > <div class=​"child first-element">​</div>​
     
    CUI.dom.findElement(div, ".no-exist")
    > null

### CUI.dom.findNextElement(node, selector, nodeFilter, forward, siblingOnly) : `HTMLElement`

It uses **CUI.dom.findElement** function and returns the first element found. 
The difference between **CUI.dom.findElement** and this function is that this function also searches for the element inside his parent's siblings and so on.

#### Example
       
    CUI.dom.findNextElement(div, ".sibling", false, false)
    > <div class=​"sibling previous-sibling">​…​</div>​
     
    CUI.dom.findNextElement(div, ".sibling", false, true)
    > <div class="sibling next-sibling">…</div>​

### CUI.dom.findPreviousElement(node, selector, nodeFilter) : `HTMLElement`

It uses **CUI.dom.findNextElement** with the **forward** parameter with *false* as value.

#### Example

    CUI.dom.findPreviousElement(div, ".sibling")
    > <div class="sibling previous-sibling">…</div>​
    
### CUI.dom.findNextVisibleElement(node, selector, forward) : `HTMLElement`

It uses **CUI.dom.findNextElement** with a function as parameter to filter the output node. This node has to be visible. 

### CUI.dom.findPreviousVisibleElement(node, selector : `HTMLElement`

It uses **CUI.dom.findNextVisibleElement** with the **forward** parameter with *false* as value

### CUI.dom.findNextSiblings(node, selector, nodeFilter) : `[HTMLElement]`

It uses **CUI.dom.findElements** with the **forward** parameter with *true* as value and the **siblingOnly** parameter with *true* as value

### CUI.dom.findPreviousSiblings(node, selector, nodeFilter) : `[HTMLElement]`

It uses **CUI.dom.findElements** with the **forward** parameter with *false* as value and the **siblingOnly** parameter with *true* as value

### CUI.dom.children(node, filter) : `[HTMLElement]`

- node `HTMLElement`
- filter `HTMLElement` | `Function` | `String`

It returns an array with all children of **node**

If **filter** is a `String`, it should be a selector.

If **filter** is a `Function`, it should receive **node** as parameter and returns a `Boolean`

#### Examples

    <div id="div">
        <span class="child"></span>
        <div class="child noFilter"></div>
    </div>
     
    CUI.dom.children(div)
    > (2) [span.child, div.child]
     
    CUI.dom.children(div, ".noFilter")
    > [div.child.noFilter]
     
    filterFunction = (node) -> CUI.dom.hasClass(node, "noFilter")
    CUI.dom.children(div, filterFunction)
    > [div.child.noFilter]
     
    CUI.dom.children(div, div.firstElementChild)
    > [span.child]
    

### CUI.dom.firstElementChild(node, selector) : `HTMLElement`

- node `HTMLElement`
- selector `HTMLElement` | `Function` | `String` | *null*

It gets the first child of **node** that returns *true* to **CUI.dom.is** invocation with **node** and **selector** as parameters.

The iteration will be from first child to last child.

Returns the first child if **selector** is null.
Returns *null* if no child were found.

### CUI.dom.lastElementChild(node, selector) : `HTMLElement`

- node `HTMLElement`
- selector `HTMLElement` | `Function` | `String` | *null*

It gets the first child of **node** that returns *true* to **CUI.dom.is** invocation with **node** and **selector** as parameters. 

The iteration will be from last child to first child.

Returns the last child if **selector** is null.
Returns *null* if no child were found.

### CUI.dom.nextElementSibling(node, selector) : `HTMLElement`

- node `HTMLElement`
- selector `HTMLElement` | `Function` | `String` | *null*

It gets the first next sibling of **node** that returns *true* to **CUI.dom.is** invocation with **node** and **selector** as parameters.

Returns *null* if no sibling were found.

### CUI.dom.previousElementSibling(node, selector) : `HTMLElement` 

- node `HTMLElement`
- selector `HTMLElement` | `Function` | `String` | *null*

It gets the first previous sibling of **node** that returns *true* to **CUI.dom.is** invocation with **node** and **selector** as parameters.

Returns *null* if no sibling were found.

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

### CUI.dom.getAttribute(node, key) : `String` | `Number` | `PlainObject`

- node `HTMLElement`
- key `String`

It returns the *value* stored inside **key** attribute of **node**

    CUI.dom.setAttribute(div, "id", "idValue")
    > <div id=​"idValue">​</div>​
     
    CUI.dom.getAttribute(div, "id")
    > "idValue"

### CUI.dom.hasAttribute(node, key) : `Boolean`

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

### CUI.dom.width(element, value) : `Number`

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
    
### CUI.dom.height(element, value) : `Number`

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


### CUI.dom.replace(node, content) : `HTMLElement`

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

### CUI.dom.append(node, content) : `HTMLElement`

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

### CUI.dom.prepend(node, content) : `HTMLElement`

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

### CUI.dom.remove(element) : `HTMLElement`

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

### CUI.dom.empty(element) : `HTMLElement`

- element `HTMLElement`

It removes all child elements inside the **element** and returns **element**

    div
    > <div>
        ​<span></span>​
      </div>​
    CUI.dom.empty(div)
    > <div></div>​
    
### CUI.dom.hasClass(element, class) : `Boolean`

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

### CUI.dom.addClass(element, class) : `HTMLElement`

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

### CUI.dom.setClass(element, class, on_off) : `Boolean`

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


### CUI.dom.toggleClass(element, cls) : `Boolean`

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

### CUI.dom.setAria(element, key, value) : `[HTMLElement]`

- element `HTMLElement`
- key `String`
- value `String` | `Boolean`

It invokes **CUI.dom.setAttribute** appending the string "*aria-*" to the **key**. Returns **element**

#### Example

    CUI.dom.setAria(div, "attributekey", "attributeValue")
    > <div aria-attributekey=​"attributeValue">​</div>​  

### CUI.dom.getRelativeOffset(element, untilElement, ignore_margin) : `{parent: [HTMLElement], top: [Number], left: [Number]}`

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

### CUI.dom.getRelativePosition(element) : `{top: [Number], left: [Number]}`

- element `HTMLElement`

It returns the relative position of the **element**

#### Examples

```html
<div style="margin-left: 50px; margin-top: 100px;">
    <p style="margin-top:50px;">Hello world</p>
</div>
```

    CUI.dom.getRelativePosition(p)
    > {top: 150, left: 50}

### CUI.dom.setAbsolutePosition(element, offset) : `HTMLElement`

- element `HTMLElement`
- offset `Object`
    - left `Number`
    - top `Number`

It sets the absolute position of the **element** with **offset.left** and **offset.top** values. Returns **element**

#### Example

```html
<div style="position: absolute;">
    <span style="position: relative;">Hello world</span>
</div>
```
```
CUI.dom.setAbsolutePosition(div, {top: 10, left: 10})
> <div style="position: absolute; top: 10px; left: 10px;">
      <span style="position: relative;">Hello world</span>
  </div>
 
CUI.dom.setAbsolutePosition(span, {top: 50, left: 30})
> <span style="position: relative; top: 40px; left: 20px;">Hello world</span>
```     
     
### CUI.dom.getNode(node) : `HTMLElement`

- node `Object` | `HTMLElement`

It returns the attribute *DOM* of **node** if it exists and **node** is not *window*, otherwise returns **node**.

### CUI.dom.isNode(node) : `Boolean`

- node `Object` | `HTMLElement`

It returns *true* if **node** is one of the following: `document.documentElement` | `document` | `window` or if **node** has the attribute `nodeType` | `DOM`, otherwise returns *false*

### CUI.dom.waitForDOMRemove(options) : `CUI.Promise`

- options `Object`
    - node `Object` | `HTMLElement` (Checked with *CUI.dom.isNode*)
    - ms `Number` (default 200)
    
It returns a promise, which will be resolved when **node** was removed from the DOM tree.
Parameter **ms** is the quantity of milliseconds to be waited until repeat the recursive function to check if the element was removed.

### CUI.dom.waitForDOMInsert(options) : `CUI.Promise`

- options `Object`
    - node `Object` | `HTMLElement` (Checked with *CUI.dom.isNode*)
    
It returns a promise, which will be resolved when **node** was inserted in the DOM tree.

### CUI.dom.insertChildAtPosition(node, nodeInsert, position)

- node `Object` | `HTMLElement`
- nodeInsert `Object` | `HTMLElement`
- position `Number`

Inserts **nodeInsert** as a child of **node** in the **position**.

#### Example

```
<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-3"></div>
</div>

newDiv
> <div class="child-new"></div>​

CUI.dom.insertChildAtPosition(div, newDiv, 2)

<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-new"></div>
    <div class="child-3"></div>
</div>
```

### CUI.dom.insertBefore(node, nodeBefore)

- node `Object` | `HTMLElement`
- nodeBefore `Object` | `HTMLElement`

Inserts **nodeBefore** before **node**

#### Example

```
<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-3"></div>
</div>

CUI.dom.insertBefore(divChild2, newDiv)

<div class="node">
    <div class="child-1"></div>
    <div class="child-new"></div>
    <div class="child-2"></div>
    <div class="child-3"></div>
</div>
```


### CUI.dom.insertAfter(node, nodeAfter)

- node `Object` | `HTMLElement`
- nodeAfter `Object` | `HTMLElement`

Inserts **nodeAfter** after **node**

#### Example

```
<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-3"></div>
</div>

CUI.dom.insertAfter(divChild2, newDiv)

<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-new"></div>
    <div class="child-3"></div>
</div>
```

### CUI.dom.matches(node, selector) : `Boolean`

- node `HTMLElement`
- selector `String`

Returns *true* if **node** matches with **selector**, otherwise returns *false*

### CUI.dom.is(node, selector) : `Boolean`

- node `HTMLElement`
- selector `HTMLElement` | `Function` | `String`

Evaluates **node** depending of **selector** type. 
If **selector** is:
- `HTMLElement`: Returns *true* if **node** is equals to **selector** 
- `Function`: Returns the result of invoke **selector** function with **node** as parameter.
- `String`: Returns the result of invoke the function *CUI.dom.matches* with **node** and **selector** as parameters. 

Returns *false* if **node** is not a `HTMLElement`

#### Examples

```
aFunction: (node) -> return true

div
> <div class="node"></div>

CUI.dom.is(div, aFunction)
> true

CUI.dom.is(div, div)
> true

CUI.dom.is(div, anotherDiv)
> false

CUI.dom.is(div, ".node")
> true

CUI.dom.is(div, ".anotherClass")
> false
```

### CUI.dom.matchSelector(element, selector, trySelf) : `[Node]`

- element `HTMLElement` | *document*
- selector `String`
- trySelf `Boolean` (default *false*)

Returns an array of all the children elements of **element** which matches with **selector**.
If **trySelf** is *true*, it will check if **element** matches as well. 

#### Examples

```
<div class="node">
    <div class="child-1"></div>
    <div class="child-2"></div>
    <div class="child-find"></div>
    <div class="child-3"></div>
</div>

CUI.dom.matchSelector(div, ".child-find")
> [div.child-find]

CUI.dom.matchSelector(div, ".node", false)
> []

CUI.dom.matchSelector(div, ".node", true)
> [div.node]
    
```

### CUI.dom.find(selector) : `[Node]`

- selector `String`

Invokes *CUI.dom.matchSelector* with *document.documentElement* as **element** parameter.

### CUI.dom.elementsUntil(element, selector, untilElement) : `[Node]`

- element `Node` | *window*
- selector `String`
- untilElement `Node` | *window*

Returns an array of elements collected starting from **element** until matches **selector**.
The collection is upwards, and ends at **untilElement**.

#### Examples

```
divNode
> <div class="node">
    <div></div>
    <div></div>
    <div class="parent-3">
        <div class="child-3"></div>
    </div>
</div>
  
CUI.dom.elementsUntil(divChild3, ".parent-3", divNode)
> (2) [div.child-3, div.parent-3]

CUI.dom.elementsUntil(divChild3, ".child-3", divNode)
> [div.child-3]

CUI.dom.elementsUntil(divChild3, ".node", divNode)
> (3) [div.child-3, div.parent-3, div.node]

CUI.dom.elementsUntil(divParent3, ".node", divNode)
> (2) [div.parent-3, div.node]
```

### CUI.dom.parent(element) : `HTMLElement`

- element `HTMLElement` | *document* | *window*

Returns parent's node of **element**.
 
If **element** is *document*, returns *window*

If **element** is *window*, returns *null*

#### Example
```
CUI.dom.parent(divChild)
> <div class="parent">
      <div class="child"></div>
  </div>
```

### CUI.dom.closest(element, selector) : `Node`

- element `Node` | *window*
- selector `String`

Returns the first node which matches the **selector**, starting from **element**.
As *CUI.dom.elementsUntil*, it goes upwards, and ends at *window*.

### CUI.dom.closestUntil(element, selector, untilElement) : `Node`

- element `Node` | *window*
- selector `String`
- untilElement `Node` | *window*

It does the same as *CUI.dom.closest*, with the difference that it ends at **untilElement** instead of *window*.

### CUI.dom.parentsUntil(element, selector, untilElement) : `[Node]`

- element `Node` | *window*
- selector `String`
- untilElement `Node` | *window*

It invokes *CUI.dom.elementsUntil* using parent's node of **element** as first parameter.

### CUI.dom.parents(element, selector, untilElement) : `[Node]`

- element `Node` | *window*
- selector `String`
- untilElement `Node` | *window*

Returns an array of nodes that are the parents of **element** which matches with **selector**, until reach **untilElement**.
The parameter **selector** can be *null*.

### CUI.dom.isInDom(element) : `Boolean`

- element `Node`

Returns *true* if **element** is in the DOM tree, otherwise *false*.

### CUI.dom.replaceWith(node, newNode) : `Node`

- node `Node`
- newNode `Node` | `NodeList`

Replaces **node** with **newNode**. It returns the **node** replaced.

#### Example

```
<div class="container">
    <div class="node"></div>
</div>
 
CUI.dom.replaceWith(divNode, divNewNode)
> <div class="node"></div>
 
<div class="container">
    <div class="newNode"></div>
</div>
```

### CUI.dom.getRect(element) : `DOMRect`

- element `HTMLElement`

Invokes native function **getBoundingClientRect()**

#### Example

```
CUI.dom.getRect(div)
> DOMRect {x: 10, y: 10, width: 100, height: 100, top: 0, …}
```

### CUI.dom.getComputedStyle(element) : `CSSStyleDeclaration `

- element `HTMLElement`

Invokes native function **getComputedStyle**

#### Example

```
CUI.dom.getComputedStyle(div)
> CSSStyleDeclaration {alignContent: "", alignItems: "", alignSelf: "", alignmentBaseline: "", all: "", …}
```

### CUI.dom.setStyle(element, style, append) : `HTMLElement`

- element `HTMLElement`
- style `PlainObject`
    - styleName `String`
    - styleValue `String` | `Number`
- append `String` (optional, default *"px"*)

It sets style **styleName** to the **element** with value **styleValue** for all keys in **style**.
If **styleValue** is a `Number`, **append** will be appended to **styleValue**.

#### Example

```
style = 
  width: 100,
  display: "inline"
  
CUI.dom.setStyle(div, style)
> <div style="width: 100px; display: inline;"></div>
```

### CUI.dom.setStyleOne(element, styleName, styleValue) : `HTMLElement`

- element `HTMLElement`
- styleName `String`
- styleValue `String` | `Number`

It sets style **styleName** to the **element** with value **styleValue**

#### Example

```
CUI.dom.setStyleOne(div, "height", 100)
> <div style="height: 100px;"></div>
```

### CUI.dom.getDimensions(element) : `PlainObject`

- element `HTMLElement`

It returns a very big object with dimensions related attributes. It has 89 keys to be exactly.

#### Example

```
CUI.dom.getDimensions(div)
> {computedStyle: CSSStyleDeclaration, clientBoundingRect: DOMRect, marginTop: 0, marginRight: 0, marginBottom: 0, …}
```

### CUI.dom.getDimension(element, key)

- element `HTMLElement`
- key `String`

It returns the *value* of the attribute **key** inside the object returned by **CUI.dom.getDimensions**.

### CUI.dom.setDimensions(element, dimensions) : `PlainObject`

- element `HTMLElement`
- dimensions `PlainObject`
    - dimensionKey `String`
    - dimensionValue `Number`
    
Sets the style of **element** for different type of **dimensions**.

Available dimensions: *"width"*, *"height"*, *"left"*, *"top"*, *"contentBoxWidth"*, *"contentBoxHeight"*, 
*"borderBoxWidth"*, *"borderBoxHeight"*, *"marginBoxWidth"*, *"marginBoxHeight"*

It's not possible to use two or more Height or Width types.

#### Examples
```
CUI.dom.setDimensions(div, {height: 100, width: 100})
> {width: 100, height: 100}
div
> <div style="width: 100px; height: 100px;"></div>
  
div
> <div style="width: 100px; height: 100px; padding-top: 100px; padding-right: 150px;"></div> 
CUI.dom.setDimensions(div, {contentBoxHeight: 100, contentBoxWidth: 100})
> {width: 250, height: 200}
div
> <div style="width: 250px; height: 200px; padding-top: 100px; padding-right: 150px;"></div>
 
CUI.dom.setDimensions(div, {contentBoxHeight: 100, height: 100})
> Uncaught Error: CUI.dom.setDimensions(docElem,dim): Unable to set contradicting values for height.

```

### CUI.dom.setDimension(element, dimensionKey, dimensionValue) : `PlainObject`

- element `HTMLElement`
- dimensionKey `String`
- dimensionValue `Number`

It's an extension of **CUI.dom.setDimensions** to set only one dimension.

### CUI.dom.parentsScrollable(element) : `[HTMLElement]`

- element `HTMLElement`

It returns all parents of **element** that can have a scroll bar.

### CUI.dom.htmlToNodes(html) : `[Node]`

- html `String`

It returns a node array, generated by **html** string.

#### Examples
```
nodes = CUI.dom.htmlToNodes("<div><h1>Hello!</h1></div><div><h2>Welcome!</h2></div>")
> (2) [div, div]
 
nodes[0]
> <div>
    <h1>Hello!</h1>
  </div>
  
nodes[1]
> <div>
    <h2>Welcome!</h2>
  </div>
```

### CUI.dom.findTextInNodes(nodes, callback, texts) : `[String]`

- nodes `[Node]`
- callback `Function` (optional)
- texts `[String]` (optional, default *[]*)

It returns a `String` array of texts which were found in text nodes inside **nodes** array and its children. It's recursive until reach last children.
The parameter **callback** is a function invoked for each text node found, with two parameters: *textNodeFound* and *textContent* of that node.

#### Examples
```
<div>
    <span>Text node 1</span>
    <div>
        <div>
            <h1>Text node 2</h1>
        </div>
        <div>Text node 3</div>
    </div>
</div>
 
CUI.dom.findTextInNodes([div])
> (3) ["Text node 1", "Text node 2", "Text node 3"]
 

callback = (textNode, textContent) => 
    console.log("TextNode:", textNode, " - TextContent:", textContent)
    
CUI.dom.findTextInNodes([div], callback)
> TextNode: "Text node 1"  - TextContent: Text node 1
> TextNode: "Text node 2"  - TextContent: Text node 2
> TextNode: "Text node 3"  - TextContent: Text node 3
> (3) ["Text node 1", "Text node 2", "Text node 3"]
```

### CUI.dom.getCSSFloatValue(value) : `Number`

- value `String`

It converts **value** into a **Number**, and **value** must have "px" at the end of the string.

#### Examples
```
CUI.dom.getCSSFloatValue("20px")
> 20

CUI.dom.getCSSFloatValue("20")
> 0
```

### CUI.dom.isPositioned(element) : `Boolean`

- element `HTMLElement`

It returns *true* if **element** has the style *position* already set and it's one of these: *"relative"*, *"absolute"*, *"fixed"*
Also, it returns *true* if **element** is *document.body* or *document.documentElement*.

#### Examples
```
CUI.dom.isPositioned(div)
> false
 
CUI.dom.setStyleOne(div, "position", "relative")
> <div style="position: relative;"></div>
CUI.dom.isPositioned(div)
> true
 
CUI.dom.isPositioned(document.body)
> true
```

### CUI.dom.isVisible(element) : `Boolean`

- element `HTMLElement`

It returns *true* if **element** is visible. It's done by checking *visibility* or *display* styles.

#### Example
```
CUI.dom.isVisible(div)
> true

CUI.dom.setStyleOne(div, "display", "none")
> <div style="display:none;"></div>

CUI.dom.isVisible(div)
> false 
```

### CUI.dom.getBoxSizing(element) : `String`

- element `HTMLElement`

It returns the style attribute *boxSizing* of **element**.

#### Example
```
CUI.dom.getBoxSizing(div)
> "border-box"
```

### CUI.dom.isBorderBox(element) : `Boolean`

- element `HTMLElement`

It returns *true* if *boxSizing* style attribute is *"border-box"*

#### Example
```
CUI.dom.getBoxSizing(div)
> "border-box"

CUI.dom.isBorderBox(div)
> true
```

### CUI.dom.isContentBox(element) : `Boolean`

- element `HTMLElement`

It returns *true* if *boxSizing* style attribute is *"content-box"*

#### Example
```
CUI.dom.getBoxSizing(div)
> "border-box"

CUI.dom.isContentBox(div)
> false
```

### CUI.dom.hideElement(element) : `HTMLElement`

- element `HTMLElement`

It hides **element** setting its *display* style attribute to *"none"*.
It returns **element**

#### Example
```
CUI.dom.isVisible(div)
> true
CUI.dom.hideElement(div)
> <div style="display: none;"></div>
CUI.dom.isVisible(div)
> false
```

### CUI.dom.showElement(element) : `HTMLElement`

- element `HTMLElement`

It hides **element** setting its *display* style attribute to *""*.
It returns **element**

#### Example
```
CUI.dom.isVisible(div)
> false
CUI.dom.showElement(div)
> <div style="display: none;"></div>
CUI.dom.isVisible(div)
> true
```

### CUI.dom.removeChildren(element, filter) : `HTMLElement`

- element `HTMLElement`
- filter `HTMLElement` | `Function` | `String`

It removes all children of **element** using **filter** as condition. Refer **CUI.dom.children** for more detail about filter.
It returns **element**


#### Example
```
<div id="div">
    <span class="child"></span>
    <div class="child noFilter"></div>
    <div></div>
</div>

CUI.dom.removeChildren(div4, ".noFilter")
> <div id="div">
    <span class="child"></span>
    <div></div>
  </div>
```

### CUI.dom.space(style) : `HTMLElement`

- style `String` (default *null*)

It creates and returns a new element which is a div with a specific class, and it is used to create empty spaces between elements.
The parameter **style** defines what type of space will be created. Available **style** values: *"small"*, *"large"*, *"flexible"* and *null*

#### Example
```
CUI.dom.space()
> <div class="cui-space"></div>
 
CUI.dom.space("small")
> <div class="cui-small-space"></div>

CUI.dom.space("large")
> <div class="cui-large-space"></div>
 
CUI.dom.space("flexible")
> <div class="cui-flexible-space"></div>
```

### CUI.dom.scrollIntoView(element) : `HTMLElement`

This function is similar to *scrollIntoView* native function, but it has improvements.
It returns **element**

### CUI.dom.setClassOnMousemove(options)

- options `Object`
    - element `HTMLElement`
    - class `String`
    - ms `Number` > 0 (default 3000)
    - delayRemove `Function` (optional)
    
It adds a **class** to the **element** when the mouse is hovering over it.
As well after **ms** milliseconds passed of mouse hovering, **delayRemove** is triggered.
Also **delayRemove** is triggered once when the mouse is no longer hovering over the **element**.

### CUI.dom.requestFullscreen(element) : `CUI.Promise`

- element `HTMLElement` | `CUI.DOMElement`

It requests a fullscreen for the **element** via using the *native function* of the browser.
The difference between using this method and the *native function* is that this method will use one of these *native function*s 
available in the browser: *requestFullscreen*, *webkitRequestFullscreen*, *mozRequestFullScreen* and *msRequestFullscreen*.
It returns a promise and it's fulfilled when fullscreen is activated.

### CUI.dom.exitFullscreen() : `CUI.Promise`

It closes fullscreen if it's enabled.
It returns a promise and it's fulfilled when fullscreen is closed.

### CUI.dom.isFullscreen() : `Boolean`

It returns *true* if fullscreen is activated.

### CUI.dom.fullscreenEnabled() : `Boolean`

It returns *true* if fullscreen is enabled.

### CUI.dom.fullscreenElement() : `HTMLElement`

It returns fullscreen element or *undefined* if fullscreen is not activated. 

### CUI.dom.element(tagName, attributes) : `HTMLElement`

- tagName `String`
- attributes `PlainObject`
    - key `String`
    - value `String` | `Boolean`
    
It creates and returns a new **tagName** element, it also invokes **CUI.dom.setAttributeMap** with the new element 
and **attributes** as parameters.

#### Examples
```
CUI.dom.element("div")
> <div></div>
 
attributes = 
    id: "myDiv" 
    enable: true
 
CUI.dom.element("div", attributes)
> <div id="myDiv" enable="enable"></div>
 
CUI.dom.element("h1")
> <h1></h1>
```

### CUI.dom.$element(tagName, className, attributes, noTables) : `HTMLElement`

- tagName `String`
- className `String` (optional)
- attributes `PlainObject` (default: *{}*)
    - key `String`
    - value `String` | `Boolean`
- noTables `Boolean` (default: *false*)

It invokes **CUI.dom.element** to create a new element, but before that it sets the attribute *class* with **className** value if it's defined.
Also, if **noTables** is *true*, it adds a new *class* called "cui-**tagName**" 

#### Examples
```
attributes = 
    id: "myDiv" 
    enable: true
 
CUI.dom.$element("div", "newClass", attributes)
> <div id="myDiv" enable="enable" class="newClass"></div>
 
CUI.dom.$element("div", "newClass", attributes, true)
> <div id="myDiv" enable="enable" class="cui-div newClass"></div>
```

If it's necessary to create elements, it's recommendable to use the following methods instead of this method. 

These methods are wrappers of **CUI.dom.$element** for create common elements.

- CUI.dom.div(className, attributes) : `HTMLElement`
- CUI.dom.video(className, attributes) : `HTMLElement`
- CUI.dom.audio(className, attributes) : `HTMLElement`
- CUI.dom.source(className, attributes) : `HTMLElement`
- CUI.dom.span(className, attributes) : `HTMLElement`
- CUI.dom.table(className, attributes) : `HTMLElement`
- CUI.dom.img(className, attributes) : `HTMLElement`
- CUI.dom.tr(className, attributes) : `HTMLElement`
- CUI.dom.th(className, attributes) : `HTMLElement`
- CUI.dom.td(className, attributes) : `HTMLElement`
- CUI.dom.i(className, attributes) : `HTMLElement`
- CUI.dom.p(className, attributes) : `HTMLElement`
- CUI.dom.pre(className, attributes) : `HTMLElement`
- CUI.dom.ul(className, attributes) : `HTMLElement`
- CUI.dom.a(className, attributes) : `HTMLElement`
- CUI.dom.b(className, attributes) : `HTMLElement`
- CUI.dom.li(className, attributes) : `HTMLElement`
- CUI.dom.label(className, attributes) : `HTMLElement`
- CUI.dom.h1(className, attributes) : `HTMLElement`
- CUI.dom.h2(className, attributes) : `HTMLElement`
- CUI.dom.h3(className, attributes) : `HTMLElement`
- CUI.dom.h4(className, attributes) : `HTMLElement`
- CUI.dom.h5(className, attributes) : `HTMLElement`
- CUI.dom.h6(className, attributes) : `HTMLElement`

#### Examples
```
attributes = 
    id: "myDiv" 
    enable: true
 
CUI.dom.div("aClass", attributes)
> <div id="myDiv" enable="enable" class="aClass"></div>
 
CUI.dom.h1("title")
> <h1 class="title"></h1>
 
CUI.dom.span()
> <span></span>
```

### CUI.dom.text(text, className, attributes) : `HTMLElement`

- text `String`
- className `String`
- attributes `PlainObject`
    - key `String`
    - value `String` | `Boolean`

It invokes **CUI.dom.span** to create a new *span* element using **className** and **attributes** as parameters.
Afterwards it sets the value **text** into *textContent* of the new element.

#### Example
```
CUI.dom.text("This is the content of the span", "newClass")
> <span class="newClass">This is the content of the span</span>
```

### CUI.dom.textEmpty(text)

- text `String`

It invokes **CUI.dom.span** to create a new *span* element using *"italic"* as className parameter.
Afterwards it sets the value **text** into *textContent* of the new element.

#### Example
```
CUI.dom.textEmpty("This is the content of the span")
> <span class="italic">This is the content of the span</span>
```

### CUI.dom.table_one_row()
### CUI.dom.tr_one_row()
### CUI.dom.prepareSetDimensions(element)
### CUI.dom.hasAnimatedClone(node)
### CUI.dom.initAnimatedClone(node, selector)
### CUI.dom.syncAnimatedClone(node)
### CUI.dom.removeAnimatedClone(node)

*Note: All the examples above were made in the browser's console.*