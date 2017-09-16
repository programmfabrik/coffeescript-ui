# Utils

## CUI.util.assert\(condition, caller, description, debug\)

| Parameter | Type | Comment |
| :--- | :--- | :--- |
| condition | Boolean | Condition to evaluate |
| caller | String | The caller |
| description | String | Additional information |
| debug | Map | Debug Output |

**CUI.defaults.asserts** determines whether an assert check is performed or not. Default is _true_.

**CUI.defaults.asserts\_alert** determines, what happens in case of an assert:

* _debugger_: Starts the debugger
* _js_: Uses Javascript window.alert to display the assert.
* _cui_: Uses CUI.problem to display
* _off_: Surpresses the assert

In all cases, an **window.Error** is thrown. Default is _off_.

### Example

```
assert(typeof(myvar) == "string", "new MyClass", "myvar needs to be string", myvar: myvar)
```

## CUI.util.isUndef\(obj\)

Returns true if obj is undefined.

## CUI.util.isNull\(obj\)

Returns true if obj is null. An object is null if it is undefined or null.

## CUI.util.isString\(obj\)

Returns true if obj is String.

## CUI.util.isEmpty\(obj\)

Returns true if obj is empty. An object is empty, if it is null, "", false, [], or {}.

## CUI.util.isTrue\(obj\)

Returns true if obj is true. True is 1, true, "1" or "true".

## CUI.util.isFalse\(obj\)

Returns true if obj is false. False is 0, false, "0" or "false".

## CUI.util.isBoolean\(obj\)

Returns true if obj is true or false.

## CUI.util.isElement\(obj\)

Returns true if obj is instance of HTMLElement.

## CUI.util.isInteger\(obj\)

Returns true if obj is a number and and Integer.

## CUI.util.isPosInt\(obj\)

Returns true if obj is a positive Integer.

## CUI.util.isFloat\(obj\)

Returns true if obj is a number and Float.

## CUI.util.isPromise\(obj\)

Returns true if obj is a CUI.Promise or CUI.Deferred.

## CUI.util.isContent\(obj\)

Returns true if obj is considered a CUI-Content, that is HTMLElement, HTMLCollection, NodeList, Array, Function, or an object with a DOM-property which is an HTMLElement.

## CUI.util.isDeferred\(obj\)

Returns true if obj is a CUI.Deferred.

## CUI.util.escapeRegExp\(str\)

Returns **str **escaped for use inside a RegExp.

## CUI.util.getObjectClass\(obj\)

Returns the name of the Function used to create **obj**.

## CUI.util.getInt\(str\)

Returns the parsed Integer or null if no Integer is received.

## CUI.util.getIntOrString\(str\)

Checks str, if it is parses as Integer, returns the Integer, str otherwise.

## CUI.util.getFloat\(str\)

Returns the str parsed as Float, or null if otherwise.

## CUI.util.xor\(a, b\)

Returns a XOR b. Returns true if a or b are considered true, false if a and b are both true or false.

## CUI.util.toHtml\(str, space2nbsp\)

Returns str HTML-escaped, replaces space chars with   if second parameter is given.

## CUI.util.toDash\(str\)

Returns str converted from CamelCase to a dash-notation.

## CUI.util.toCamel\(str, include\_first\)

Returns str converted from dash-notation to CamelCase. include\_first can be set to true, to also camel-case the first character.

## CUI.util.toClass\(str\)

Returns str suitable to be used as class name. Replaces \_ to - and spaces to -.

## CUI.util.toDot\(str\)

Returns str suitable to be used in CSS, replaces - to .

## CUI.util.removeFromArray\(value, array, compFunc\)

Removes **value **from **array**. Returns number of items removed.

A **compFunc** can be used to return \_true \_or \_false \_for each item in array. If **compFunc **is set, **value **is ignored.

## CUI.util.pushOntoArray\(value, array, compFunc\)

Appends **value **to the given **array**, if is not already in **array**.

A **compFunc** can be used to return \_true \_or \_false \_on each item in array.

Returns the idx of the pushed or existing **value**.

## CUI.util.idxInArray\(value, array, compFunc\)

Returns the index of the given **value **in **array**. -1 if not found.

A **compFunc** can be used to return \_true \_or \_false \_for each item in array. If **compFunc **is set, **value **is ignored.

## CUI.util.findInArray\(value, array, compFunc\)

Returns the item in **array **either matching **value **or using the **compFunc**. This is a handy function for searching thru an Array of Maps, where you want to match a certain property of the Map values.

## CUI.util.compareIndex\(a, b\)

Returns _-1_ if a &lt; b, _1_ if a &gt; b  and _0_ otherwise.

## CUI.util.copyObject\(obj, deep\)

Returns a copy of the obj. With deep set to true, a deep copy is created. For instances of CUI.Element the "copy" method is called.

Types which are copied:

* string
* number
* boolean
* function \(as reference\)
* null
* undefined
* CUI.Element \(copy method is called\)
* CUI.Dummy \(as reference\)
* HTMLElement \(as reference\)
* Map
* Array

## CUI.util.dump\(obj, space\)

Returns a String suitable for output in console.debug. This replaces all undefined and null values by "&lt;undefined&gt;" and "&lt;null&gt;" resp., and then calls **JSON.stringify** to obtain a printable String of **obj**.

**space **is passed to JSON.stringify to format the JSON, defaults to _\t_.

## CUI.util.alert\_dump\(obj\)

Uses window.alert to dump obj to a Javascript-Alert.

## CUI.util.utoa\(str\)

Returns Base64 encoded ASCII representation of the passed UCS-2 String.

## CUI.util.atou\(str\)

Returns UCS-2 String representation from passed Base64 encoded ASCII.

## String.prototype.startsWith\(str\)

Implements **startsWith **for Strings.

## String.prototype.endsWith\(str\)

Implements **endsWith **for Strings.

## RegExp.escape\(str\)

Returns **str **escaped for use inside a RegExp.

