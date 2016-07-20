CUI.when = =>
	promises = []
	add_promise = (promise, idx) =>
		assert(isPromise(promise) or isDeferred(promise), "CUI.when", "arg[#{idx}] needs to be instanceof CUI.Promise or CUI.Deferred.", arg: promise)
		promises.push(promise)
		return

	for arg, idx in arguments
		if arg instanceof Array
			for _arg,_idx in arg
				add_promise(_arg, idx+"["+_idx+"]")
		else
			add_promise(arg, idx)

	if promises.length == 0
		return CUI.resolvedPromise()

	dfr = new CUI.Deferred()
	done_values = []
	done_count = 0

	for promise, idx in promises
		do (idx) =>
			promise.done =>
				# CUI.debug "promise done", done_count, promises.length
				done_count++
				switch arguments.length
					when 0
						done_values[idx] = undefined
					when 1
						done_values[idx] = arguments[0]
					else
						done_values[idx] = []
						for arg in arguments
							done_values[idx].push(arg)

				if done_count == promises.length
					# all done
					dfr.resolve.apply(dfr, done_values)
				return

			promise.fail =>
				# pass this through
				dfr.reject.apply(dfr, arguments)
				return

			promise.progress =>
				# pass this through
				dfr.notify.apply(dfr, arguments)
				return

	dfr.promise()
