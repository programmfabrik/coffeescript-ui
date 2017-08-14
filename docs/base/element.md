# CUI.Element

**CUI.Element** is the main class for all our CUI-Elements. It manages parameters which are used to construct an instance of any CUI-Element.

The constructor calls

* **initOpts**
* **readOpts**
* **onConstruct **\(if given\)

**initOpts **and **readOpts **are the function which should be extended when CUI.Element is subclassed.

**readOpts **checks all Options against the required types and values. Each option which passed the test, is then copied into the objects namespace, prefixed by a single underscore \(\_\).

## Options

### debug

Can be passed and used to switch code based debugging on or off. **CUI **does nothing with this information, but you can use this in your code.

### onConstruct\(obj\)

**Callback **executed on construction time. **obj **is the instance of the created CUI.Element.

### onDestroy

Callback executed when the destroy method is called on the CUI.Element.

## Methods

### getElementClass

Returns a string representation of the class name. This uses [**getObjectClass**](common.md).

### getUniqueId

Each instance of CUI.Element gets assigned a unique id. This is simply an Integer which is stored in the instance when constructed.

### getOpts

Returns the passed Options.

### getOpt\(key\)

Returns **key **of the passed Options Map. 

### hasOpt\(key\)

Returns _true_, if the passed Options Map contains **key **as property.

### getSetOpt\(key\)

Return the **key **of the set option. This can differ from the passed option, as **readOpts **could have set a default value for an option.

### hasSetOpt\(key\)

Returns true if the key is a set option.

### initOpts

Initialized the options. This is called at construction time and adds all available options for the check in **readOpts**. Subclasses of CUI.Element should overwrite **initOpts **to initialize their own options.

### copy

This creates a new instance of the CUI.Element, using the same options. The options are passed by reference.

### addOpt\(key, check\_map\) 

This adds an option to the list of available options. The check\_map is a Map with the following properties:

| Property | Type | Description |
| :--- | :--- | :--- |
| default | Anything | Default value for the option. |
| mandatory | Boolean | If a value is null or undefined it is considered to be not set an assert will be raised. |
| check | Value | If set to _String_, _Function_, _Array_ the instance of the passed value is checked. |
|  | "PlainObject" | CUI.PlainObject is used to check if the value is a plain object. |
|  | Map | The value is checked against the given check\_map, that is, the value needs to be a PlainObject. |
|  | Function | If a Function is given, the value is passed to the function for checking. The Function should return _true_ if the value is acceptable_._ It can return a String as an error message. |
| deprectaed | Boolean | If set to _true_, a console warning is given about the deprecated option.  |



