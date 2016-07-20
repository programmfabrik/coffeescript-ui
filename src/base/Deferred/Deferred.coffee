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
		@__runningCallbacks = true
		idx = 0
		while idx < @__callbacks.length
			cb = @__callbacks[idx]
			if cb.type in types
				cb.func.apply(@, args)
			idx++
		@__runningCallbacks = false
		@

	__register: (type, func) ->
		# CUI.error("register:", @getUniqueId(), type, @__runningCallbacks, @__state)
		if not @__runningCallbacks and @__state != "pending"
			# console.debug "Deferred.__register", @getUniqueId(), type, func, @__state, @__finished_args
			switch @__state
				when "resolved"
					if type in ["done", "always"]
						func.apply(@, @__finished_args)
				when "rejected"
					if type in ["fail", "always"]
						func.apply(@, @__finished_args)
		else
			@__callbacks.push(type: type, func: func)
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
		# console.error "deferred.resolve", @getUniqueId(), @__finished_args
		@__state = "resolved"
		# CUI.error("Deferred.resolve: calling done")
		@__callback(["done", "always"], arguments)
		@

	__reject: ->
		assert(@__state == "pending", "CUI.Deferred.reject", "Cannot reject state #{@__state}.")
		@__finished_args = arguments
		@__state = "rejected"
		@__callback(["fail", "always"], arguments)
		@

	state: ->
		@__state

	promise: ->
		new CUI.Promise(@)


	@uniqueId: 0