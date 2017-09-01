###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# returns a deferred which resolves if the
# decision was positive or rejects if otherwise
CUI.decide = (decision) =>
	dfr = new CUI.Deferred()
	if CUI.util.isPromise(decision)
		decision.done(dfr.resolve)
		decision.fail(dfr.reject)
	else if decision == false
		dfr.reject(false)
	else
		dfr.resolve(decision)
	dfr.promise()
