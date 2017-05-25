###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Deferred
	constructor: ->
		@__state = "pending"
		@__callbacks = []

		# let's not use the coffeescript binding here,
		# so that the stack traces are more readable
		@notify = => @__notify.apply(@, arguments)
		@resolve = => @__resolve.apply(@, arguments)
		@reject = => @__reject.apply(@, arguments)
		@__uniqueId = CUI.Deferred.uniqueId++
		@__runningCallbacks = null
		@__finished_args = null

	getUniqueId: ->
		@__uniqueId

	__callback: (types, args) ->
		# CUI.error("callback:", @getUniqueId(), types, @__callbacks.length)
		@__runningCallbacks = true
		idx = 0
		while idx < @__callbacks.length
			cb = @__callbacks[idx]
			if cb.type in types
				# console.info @getUniqueId(), idx, cb.type, @__callbacks.length
				#
				cb.func.apply(@, args)

				if cb.type in ["done", "always", "fail"]
					# remove from callback queue
					@__callbacks.splice(idx, 1)
					continue

			idx++

		@__runningCallbacks = false
		# CUI.error("callback DONE:", @getUniqueId(), types, @__callbacks.length)
		@

	__register: (type, func) ->
		# CUI.error("register:", @getUniqueId(), type, @__runningCallbacks, @__state)
		#
		assert(CUI.isFunction(func), "Deferred."+type+": Callback needs to be Function.", callback: func)
		if @__state == "rejected" and type == "done"
			# nothing to do
			return

		if @__state == "resolved" and type == "fail"
			# nothing to do
			return

		@__callbacks.push(type: type, func: func)

		if @__state != "pending" and not @__runningCallbacks
			switch @__state
				when "resolved"
					@__callback(["done", "always"], @__finished_args)
				when "rejected"
					@__callback(["fail", "always"], @__finished_args)
		@

	done: (func) ->
		@__register("done", func)
		@

	fail: (func) ->
		@__register("fail", func)
		@

	always: (func) ->
		@__register("always", func)
		@

	progress: (func) ->
		@__register("progress", func)
		@

	__notify: ->
		assert(@__state == "pending", "CUI.Deferred.notify", "Cannot notify state #{@__state}.")
		@__callback(["progress"], arguments)
		@

	__resolve: ->
		assert(@__state == "pending", "CUI.Deferred.resolve", "Cannot resolve state #{@__state}.")
		@__finished_args = arguments
		# console.error "Deferred.resolve", @getUniqueId(), @__finished_args
		@__state = "resolved"
		# CUI.error("Deferred.resolve: calling done")
		@__callback(["done", "always"], arguments)
		@

	__reject: ->
		assert(@__state == "pending", "CUI.Deferred.reject", "Cannot reject state #{@__state}.")
		@__finished_args = arguments
		# console.error "Deferred.reject", @getUniqueId(), @__finished_args
		@__state = "rejected"
		@__callback(["fail", "always"], arguments)
		@

	state: ->
		@__state

	promise: ->
		new CUI.Promise(@)


	@uniqueId: 0