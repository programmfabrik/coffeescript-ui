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

### onDestroy\(obj\)

Callback executed when the destroy method is called on the CUI.Element. **obj **is the instance of the created CUI.Element.

## Methods

### getElementClass\(\)

Returns a string representation of the class name. This uses [**getObjectClass**](common.md).

### getUniqueId\(\)

Each instance of CUI.Element gets assigned a unique id. This is simply an Integer which is stored in the instance when constructed.

### getOpts\(\)

Returns the passed Options.

### getOpt\(key\)

Returns **key **of the passed Options Map.

### hasOpt\(key\)

Returns _true_, if the passed Options Map contains **key **as property.

### getSetOpt\(key\)

Return the **key **of the set option. This can differ from the passed option, as **readOpts **could have set a default value for an option.

### hasSetOpt\(key\)

Returns true if the key is a set option.

### initOpts\(\)

Initialized the options. This is called at construction time and adds all available options for the check in **readOpts**. Subclasses of CUI.Element should overwrite **initOpts **to initialize their own options.

### readOpts\(\)

Read the passed options. The checks are performed, default data is set and values are copied into the property **"\_"+key**.

### readOptsFromAttr\(str\)

Returns a map suitable for creating a new **CUI.Element**. The **str** is interpreted in CSS syntax

```
key = value; key2 = true; key3 = value;
```

This result is:

```
{
    key: "value",
    key2: true,
    key3: 5
}
```

The method has support for Boolean \("true", "false"\) and Integer values \(parseInt\), otherwise it uses a string. The  opts are simply returned, no further operations are performed.

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
| deprectaed | Boolean | If set to _true_, a console warning is given about the deprecated option. |

### addOpts\(map\)

Gets a map with key -&gt; check\_map. Adds an option per key.

### removeOpt\(key\)

Removes the given option from the available options. Use in subclasses to remove an available option.

### mergeOpt\(key, check\_map\)

Overwrites the check **map **for given **key**. The overwrite is performed as merge, that is, existing keys will be overwritten if an update is provided. Keys which are not mentioned in **check\_map **are left untouched.

### mergeOpts\(map\)

Overwrites the available options using the map with key -&gt; check\_map.

### proxy\(element, methods\)

This method registers all methods given in **methods** \(Array of Strings\) to the given **element** \(CUI.Element\).

### destroy\(\)

This destroys the **CUI.Element**. It sets the destroyed flag internally, the method **isDestroyed\(\)** returns \_true \_after the call. All mapped values are deleted and the **onDestroy** callback is called.

### isDestroyed\(\)

Returns \_false \_before **destroy\(\)** was called, \_true \_afterwards.

### @getOptKeys\(\)

Returns the map of options available for the given **CUI.Element** class.

### @readOpts\(opts, cls, check\_map, map\_values\)

Perform a **readOpts **on the given options Map **opts**. **cls** is used for the error output when the given options don't pass the check defined by **check\_map**. If **map\_values** is set to _true_, the read values are mapped to the callers instance as properties. This is the same function the methods **readOpts** used on the **CUI.Element** instance.

The function returns the parsed options (including set defaults).

**CUI.Element.readOpts** can be used to check options for a method outside the "new CUI.Element" construct.


