# new CUI.Deferred

Deferred collects callbacks for **process**, **resolve **and **reject**. When any of these methods is called on an instance of an Deferred, all registered function are called.

All applicable callback functions are called in the order of their registration.

Callback functions can be registered after a Deferred has been resolved or rejected. They will be called back immediately using the same arguments as were used when the Defeered was resolved or rejected.

## done\(func\)

Register a callback function **func** to be called when **resolve **is called on the Deferred.

## fail\(func\)

Register a callback function **func** to be called when **fail **is called on the Deferred.

## progress\(func\)

Register a callback function **func** to be called when **notify **is called on the Deferred.

## always\(func\)

Register a callback Function **func** to be called when **resolve **or **fail **is called on the Deferred.

## resolve\(args...\)

Resolves the Deferred, all registered **done** and **always** callbacks are called. The state is set to _resolved_. All arguments passed to this method are passed on to the callback functions.

## reject\(args...\)

Rejects the Deferred, all registered **done** and **always** callbacks are called. The state is set to _rejected_.

## notify\(args...\)

Notify all registered **process** callbacks. The state is unchanged.

## promise\(\)

Returns a [CUI.Promise](promise.md). This is like a Deferred, but with limited abilities. 

## state\(\)

Returns the state of the Deferred:

* _pending_ This is the initial state when the Deferred is created.
* _resolved_ State after the Deferred has been resolved by calling the **resolve** method.
* _rejected_ State after the Deferred has been rejected by calling the **reject** method.

## getUniqueId\(\)

Each Deferred gets assigned a unique id. This can be useful for debugging purposes.

# CUI.resolvedDeferred\(args...\)

Returns an already resolved Deferred, using the given arguments.

# CUI.rejectedDeferred\(args...\)

Returns an already rejected Deferred, using the given arguments.

# new CUI.Promise(deferred)

The Promise is a proxy for the methods **done**, **fail**, **always**, **state**, and **getUniqueId** of the passed CUI.Deferred. A Promise is not to be designed to be created directly but to be retrieved by calling **promise** on an existing CUI.Deferred.

# CUI.when(args...)

Returns a Promise which calls **done**, **fail**, or **process** when any of the passed CUI.Deferred receive a **resolve**, **reject**, or **notify** call. The arguments can be instances of CUI.Deferred, CUI.Promise or Array of such instances. The Promise waits before all underlying CUI.Deferred or CUI.Promise are resolved, but fails immediately when the first CUI.Deferred or CUI.Promise is rejected. In the case of resolve, the done callback of the CUI.Promise returned by CUI.when, receives an Array of all arguments passed to the indivual underlying CUI.Deferred or CUI.Promise.

# CUI.decide(decide)

Returns a CUI.Promise which resolves if the passed **decide** is a CUI.Promise and is being resolved (passing on all the arguments).

If the passed CUI.Promise is rejcted the returned CUI.Promise is also rejected (passing on all the arguments).

If the passed **decide** is Boolean **false** the CUI.Promise is rejected with **decide** as argument.

If the passed **decide** is not **false** and not a CUI.Promise the returned CUI.Promise is resolved with **decide** as argument.

