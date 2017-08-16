# CUI.Events

## trigger(event)

This global function is used to trigger an [CUI.Event](event.md). The Event is created using **CUI.Event.require**, see the Options below.

Returns a [CUI.Promise](deferred.md), which resolves when all of the CUI.Listeners are done, and rejects if the first of the CUI.Listener is rejected.

If Listeners don't return Promises, the Listener is assumed to have resolved.

## listen(listener)

This global function is used to register a [CUI.Listener](listener.md). The Listener is created using **CUI.Listener.require**. 

The newly created Listener is returned.

## ignore(filter, node)

Start at **node** and look for registered Listeners which match the given **filter**. 
