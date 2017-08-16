# new CUI.Event\(Options\)

Known events: beforeunload, unload, load, error, close, popstate, dragstart, dragover, dragleave, dragenter, drop, message, fullscreenchange, hashchange, change, focus, blur, paste, scroll, selectstart, animationstart, transitioned, resize

## Options

### type

The **type** of the CUI.Event. This is a required String.

### **node**

The DOM **node** where to start the Event from. If not set, it defaults to _document.documentElement_, that is the HTML node of the DOM tree.

### require\_node\_in\_dom

If set, the provided **node** has to be in the active DOM, if not, an assert is shown.

### bubble

If set, the Event bubbles up the DOM tree, starting from **node**.

### sink

If set, the Event sinks down the DOM tree, starting from **node**. This is a unique feature in CUI.

### exclude\_self

If set, the Event propagation starts one above \(bubble\) or one below \(sink\) the start **node**.

### info

This PlainObject is passed along with the Event itself. It can be retrieved using the **getInfo** method.

### prevent\_default

If set, the Event is created with default action prevented.

## isExcludeSelf\(\)

Returns _true_ if the event has the **exclude\_self** option set to _true_.

## getPhase\(\)

Returns the **phase** the Event is in. Returns _capture_ or _bubble_. The phase is available only if the CUI.Listener is used to listen to the Event.

## getType\(\)

Returns the **type** of the Event.

## getDebug\(\)

Returns a String useful for debugging describing the Event.

## getInfo\(\)

Returns the **info** which is passed along with the Event.

## getNode\(\)

Returns the **node** of the Event.

## getElement\(\)

Returns the **CUI.Element** attached to the **node** of the Event.

## isBubble\(\)

Returns _true_, if this Event has the **bubble** option set to _true_.

## isSink\(\)

Returns _true_, if this Event has the **sink** option set to _true_.

## isInDOM\(\)

Returns _true_, if the **node** is in the active DOM tree.

## setNativeEvent\(NativeEvent\)

This sets the underlying native browser event. CUI sets this automatically if an Event is caught by a CUI.Listener.

## getNativeEvent\(\)

Returns the underlying native browser event.

## getPointTarget\(\)

Returns the element at the point of the Event.

## getTarget\(\)

Returns the Event's target element.

## setTarget\(element\)

Sets the Event's target element.

## getCurrentTarget\(\)

Returns the Event's current target. This can differ from the actual target, if the CUI.Listener was initialized with a **selector**.

## setCurrentTarget\(element\)

Sets the Event's current Target.

## getModifiers\(\)

Returns an Array of set modifiers. Possible values are: _Meta_, _Control_, _Alt_, _Shift_.

## hasModifierKey\(include\_shift\)

Returns _true_, if any of the modifier keys was pressed. With **include\_shift** set, Shift is also considered a modifier. Default to _false_.

## getButton\(\)

Returns the NativeEvent's **button** property.

## keyCode\(\)

Returns the NativeEvent's **which** property.

## metaKey\(\)

Returns the NativeEvent's **metaKey** property.

## ctrlKey\(\)

Returns the NativeEvent's **ctrlKey** property.

## altKey\(\)

Returns the NativeEvent's **altKey** property.

## shiftKey\(\)

Returns the NativeEvent's **shiftKey** property.

## clientX\(\)

Returns the NativeEvent's **clientX** property.

## clientY\(\)

Returns the NativeEvent's **clientY** property.

## pageX\(\)

Returns the NativeEvent's **pageX** property.

## pageY\(\)

Returns the NativeEvent's **pageY** property.

## stopImmediatePropagation\(\)

Stops propagation immediately. That includes calling Listeners which listen on the same **node**.

## stopPropagation\(\)

Stop propagation on the next node above or below.

## preventDefault\(\)

Prevents default action for this Event.

## stop\(\)

This prevents default, stops immediate and regular propagation. Returns _false_.

## isImmediatePropagationStopped\(\)

Returns _true_, if the propagation was stopped immediately.

## isPropagationStopped\(\)

Returns _true_, if the propagation was stopped.

## isDefaultPrevented\(\)

Returns _true_, if default is prevented on this Event.

## dispatch\(\)

The CUI.Event is dispatched, that is, brought to life. The Event starts bubbling and/or sinking thru the DOM tree, calling the Listeners on the way.

## dump\(\)

Returns a String with extended debugging info for the Event.

# Event.require\(event, debug\_name\)

Returns CUI.Event, using the provided **event**. If **event** is a PlainObject, a new CUI.Event is created, using **event** as the options.

If a CUI.Event is provided, that event is returned, no further action is performed.

**debug\_name** is used to show inside the assert for identification if the CUI.Event could not be created.

Default options are retrieved from the Events registry.

# Event.createFromDOMEvent\(event, eventClass\)

Returns a CUI.Event created from the native **event**. This function is used by CUI.Listener to wrap native Events. **eventClass** is the function used to create the CUI.Event. It default to the registered Events.

# new CUI.CUIEvent\(\)

| type | aliases | propagation | description |
| :--- | :--- | :--- | :--- |
| **viewport-resize** | - | sink | Triggered by CUI when the viewport is changed. |
| **content-resize** | - | bubble | Triggered by CUI when content changes and resize needs to be propagated. |



# new CUI.KeyboardEvent\(\)

Known types: input, keyup, keydown, keypress.

## getKeyboard\(\)

Returns the currently pressed keys of the keyboard, starting with the modifiers, followed by the regular keys.

## key\(\)

Returns the **key** of the Event \(that is the last key pressed\).

## dump\(\)

Returns information about the event, useful for debugging.

# new CUI.MouseEvent\(\)

Known types: mousemove, mouseover, mouseout, mouseleave, mouseenter, mousedown, mouseup, click, dblclick, contextmenu.

# new CUI.WheelEvent\(\)

Known types: wheel.

## wheelDeltaY\(\)

Returns the value of the wheel delta.

## dump\(\)

Returns information about the event, useful for debugging.

# new CUI.TouchEvent\(\)

Known types: touchstart, touchend, touchmove, touchcancel, touchforcechange, gesturestart, gestureend, gesturechange.







