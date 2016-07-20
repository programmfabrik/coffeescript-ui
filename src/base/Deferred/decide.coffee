# returns a deferred which resolves if the
# decision was positive or rejects if otherwise
CUI.decide = (decision) =>
	dfr = new CUI.Deferred()
	if isPromise(decision)
		decision.done(dfr.resolve)
		decision.fail(dfr.reject)
	else if decision == false
		dfr.reject(false)
	else
		dfr.resolve(decision)
	dfr.promise()
