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
> <div>​</div>​
 
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

### CUI.dom
### CUI.dom
### CUI.dom
### CUI.dom