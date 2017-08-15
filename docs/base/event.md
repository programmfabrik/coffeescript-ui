# CUI.Events.trigger(event)

This global function is used to trigger an **CUI.Event**. The Event is created using **CUI.Event.require**, see the Options below.

Returns a [CUI.Promise](promise.md), which resolves when all of the CUI.Listeners are done, and rejects if the first of the CUI.Listener is rejected.

If Listeners don't return Promises, the Listener is assumed to have resolved.

# CUI.Events.listen
....



# new CUI.Listener(Options)

## Options

### type

Listens to the **type** of Event. **type** can be a String, or an Array of Strings.

### node

The listener will be bound to the given **node**, defaults to _document.documentElement_.

### call(event, info)

The callback function of the Listener. This will be called if an Event happens the Listener listens to.

### only_once

The listener will destroy itself after the first Event was received.

### selector

The listener will filter the Event's target with the given **selector**. This can be a CSS selector a Function.

If this is a CSS selector, the Event is only accepted, if any element matches the selector between the target of the event and the **node** this Listener is listening on.

If a Function is provided, the Function needs to return _true_ or _false_, whether to accept the Event or not. The Function receives the Event's target as first parameter and the Listener's **node** as second parameter.

The element matched by the **selector** will be available using the method **getCurrentTarget()** of the CUI.Event.

The **selector** only works for native browser events.

### instance

This takes any object, it can be used to destroy the registered Listener, using **Events.ignore**.

### capture

If set to _true_, the Listener listens during the capture phase of the Event.

## isCapture()

Returns _true_, if this Listener listens during the capture phase of the Event.

## isOnlyOnce()

Returns _true_, if the **only_once** option is set.

## destroy()

Removes the Listener and stops listening.

## getNode()

Returns the **node**, this Listener is listening on.

## getTypes()

Returns the **types**, this Listener is listening for. This returns an Array of Strings.

## getnstance()

Returns the **instance** set at create time.

## matchesFilter(filter)

The **filter** is checked against the Listener. If **filter** is an instance of Listener, it returns _true_, if Listener is the same instance as **filter**.

If the filter is a PlainObject, the Object is matched against the Listeners options. **instance**, **node**, **type**, **call**, and **node** are supported. The **node** matches if it the same or below the **filter.node**.

## matchesEvent(event)

Returns the _distance_ of the Listener node to the Event node, if the provided **event** matches the Listener. This method is used internally and provide if need for debugging purposes.

Returns _null_, if the **event** does not match the Listener.

## getDepthFromLastMatchedEvent()

Returns the depth of the last match event. This method is used internally and provide if need for debugging purposes.

## handleEvent(event, phase)

Handles the event during the given phase. This method is used internally and provide if need for debugging purposes.

# CUI.Listener.require(listener, debug_name)

Returns CUI.Listener, using the provided **listener**. If **event** is a PlainObject, a new CUI.Event is created, using **event** as the options.

If a CUI.Event is provided, that event is returned, no further action is performed.

**debug_name** is used to show inside the assert for identification if the CUI.Event could not be created.

The Listener function is retrieved from the Events registry.


# new CUI.Event\(Options\)

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

### exclude_self

If set, the Event propagation starts one above (bubble) or one below (sink) the start **node**.

### info

This PlainObject is passed along with the Event itself. It can be retrieved using the **getInfo** method.

### prevent_default

If set, the Event is created with default action prevented.


## isExcludeSelf()

Returns _true_ if the event has the **exclude_self** option set to _true_.

## getPhase()

Returns the **phase** the Event is in. Returns _capture_ or _bubble_. The phase is available only if the CUI.Listener is used to listen to the Event.

## getType()

Returns the **type** of the Event.

## getDebug()

Returns a String useful for debugging describing the Event.

## getInfo()

Returns the **info** which is passed along with the Event.

## getNode()

Returns the **node** of the Event.

## getElement()

Returns the **CUI.Element** attached to the **node** of the Event.

## isBubble()

Returns _true_, if this Event has the **bubble** option set to _true_.

## isSink()

Returns _true_, if this Event has the **sink** option set to _true_.

## isInDOM()

Returns _true_, if the **node** is in the active DOM tree.

## setNativeEvent(NativeEvent)

This sets the underlying native browser event. CUI sets this automatically if an Event is caught by a CUI.Listener.

## getNativeEvent()

Returns the underlying native browser event.

## getPointTarget()

Returns the element at the point of the Event.

## getTarget()

Returns the Event's target element.

## setTarget(element)

Sets the Event's target element.

## getCurrentTarget()

Returns the Event's current target. This can differ from the actual target, if the CUI.Listener was initialized with a **selector**.

## setCurrentTarget(element)

Sets the Event's current Target.

## getModifiers()

Returns an Array of set modifiers. Possible values are: _Meta_, _Control_, _Alt_, _Shift_.

## hasModifierKey(include_shift)

Returns _true_, if any of the modifier keys was pressed. With **include_shift** set, Shift is also considered a modifier. Default to _false_.

## getButton()

Returns the NativeEvent's **button** property.

## keyCode()

Returns the NativeEvent's **which** property.

## metaKey()

Returns the NativeEvent's **metaKey** property.

## ctrlKey()

Returns the NativeEvent's **ctrlKey** property.

## altKey()

Returns the NativeEvent's **altKey** property.

## shiftKey()

Returns the NativeEvent's **shiftKey** property.

## clientX()

Returns the NativeEvent's **clientX** property.

## clientY()

Returns the NativeEvent's **clientY** property.

## pageX()

Returns the NativeEvent's **pageX** property.

## pageY()

Returns the NativeEvent's **pageY** property.

## stopImmediatePropagation()

Stops propagation immediately. That includes calling Listeners which listen on the same **node**.

## stopPropagation()

Stop propagation on the next node above or below.

## preventDefault()

Prevents default action for this Event.

## stop()

This prevents default, stops immediate and regular propagation. Returns _false_.

## isImmediatePropagationStopped()

Returns _true_, if the propagation was stopped immediately.

## isPropagationStopped()

Returns _true_, if the propagation was stopped.

## isDefaultPrevented()

Returns _true_, if default is prevented on this Event.

## dispatch()

The CUI.Event is dispatched, that is, brought to life. The Event starts bubbling and/or sinking thru the DOM tree, calling the Listeners on the way.

## dump()

Returns a String with extended debugging info for the Event.

# Event.require(event, debug_name)

Returns CUI.Event, using the provided **event**. If **event** is a PlainObject, a new CUI.Event is created, using **event** as the options.

If a CUI.Event is provided, that event is returned, no further action is performed.

**debug_name** is used to show inside the assert for identification if the CUI.Event could not be created.

Default options are retrieved from the Events registry.

# Event.createFromDOMEvent(event, eventClass)

Returns a CUI.Event created from the native **event**. This function is used by CUI.Listener to wrap native Events. **eventClass** is the function used to create the CUI.Event. It default to the registered Events.

