###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# this is like when, only that it not stops on failure
CUI.whenAll = =>
	args = [false]
	args.push.apply(args, arguments)
	CUI.__when.apply(@, args)

CUI.when = =>
	args = [true]
	args.push.apply(args, arguments)
	CUI.__when.apply(@, args)

CUI.__when = =>
	promises = []
	add_promise = (promise, idx) =>
		if not promise
			return
		CUI.util.assert(CUI.util.isPromise(promise) or CUI.util.isDeferred(promise), "CUI.when", "arg[#{idx}] needs to be instanceof CUI.Promise or CUI.Deferred.", arg: promise)
		promises.push(promise)
		return

	stop_on_failure = null

	for arg, idx in arguments
		if idx == 0
			stop_on_failure = arg
			continue

		if arg instanceof Array
			for _arg,_idx in arg
				add_promise(_arg, idx+"["+_idx+"]")
		else
			add_promise(arg, idx)

	if promises.length == 0
		return CUI.resolvedPromise()

	dfr = new CUI.Deferred()
	finished_values = []
	finished_count = 0

	if stop_on_failure
		finished_func = 'done'
	else
		finished_func = 'always'

	for promise, idx in promises
		do (promise, idx) =>
			promise[finished_func] =>
				# console.error "CUI.when, resolve...", dfr.getUniqueId(), done_count, promises.length
				# console.debug "promise done", done_count, promises.length
				finished_count++

				if stop_on_failure and arguments.length <= 1
					switch arguments.length
						when 0
							finished_values[idx] = undefined
						when 1
							finished_values[idx] = arguments[0]
				else
					args = []
					for arg in arguments
						args.push(arg)

					if stop_on_failure
						finished_values[idx] = args
					else
						finished_values[idx] = state: promise.state(), args: args

				if finished_count == promises.length
					# all finished
					dfr.resolve.apply(dfr, finished_values)
				return

			if stop_on_failure
				promise.fail =>
					# console.error "CUI.when, reject...", dfr.getUniqueId()
					if dfr.state() != "rejected"
						# pass this through
						dfr.reject.apply(dfr, arguments)
					return

			promise.progress =>
				if dfr.state() == "pending"
					# pass this through
					dfr.notify.apply(dfr, arguments)
				return

	dfr.promise()
