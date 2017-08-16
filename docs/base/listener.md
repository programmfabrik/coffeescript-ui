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

## matchesFilter(filter) {#matchesFilter}

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
