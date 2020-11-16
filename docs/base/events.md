# CUI.Events

## trigger(event)

This global function is used to trigger an [CUI.Event](event.md). The Event is created using **CUI.Event.require**, see the Options below.

Returns a [CUI.Promise](deferred.md), which resolves when all of the CUI.Listeners are done, and rejects if the first of the CUI.Listener is rejected.

If Listeners don't return Promises, the Listener is assumed to have resolved.

## listen(listener)

This global function is used to register a [CUI.Listener](listener.md). The Listener is created using **CUI.Listener.require**.

The newly created Listener is returned.

> Each Listener is linked to the DOM node it listens on. An attribute \[data-cui-listener\] is set on the node. Be careful to attached Listeners to document.documentElement \(the default\), this is a great source for memory leaks, as the garbage collector cannot remove those, if they are no longer needed by your application. Listeners attached to document or window, are kept in a separate list in Events.__listeners.

## ignore(filter, node)

Start at **node** and look for registered Listeners which match the given **filter**. See [CUI.Listener](listener.md#matchesFilter) for details.

## wait(options)

Wait for an event to happen on a node. This returns a [CUI.Promise](deferred.md#Promise). If the event does not happen before a timeout, the Promise is resolved, too.

### type

The Event _type_ to wait for.

### node

The **node** to listen for the event on.

### maxWait

The timeout in milliseconds. Defaults to **CUI.defaults.class.Events.defaults.maxWait**, which defaults to 1500.

```
CUI.wait
    type: "transitioned"
    node: my_done
.done =>
    # transition is done
```

## unregisterListener(listener)

Destroys the given listener. Its better to use Events.ignore, though.

## dump(filter)

Dumps all active Listeners.

## dumpTopLevel()

Dump all active Listeners on top level (window, document & document.documentElement).

## hasEventType(type)

Returns _true_ if the event of **type** is known.

## getEventType(type)

Returns the default option for the given registered event type **type**.

## getEventTypeAliases(type)

Return an Array of type aliases for the given event type **type**

## registerEvent(event)

Registers default options for an event. Besides the options for [CUI.Event](event.md), **eventClass* can be set to create the event using another function than CUI.Event to create the event.

