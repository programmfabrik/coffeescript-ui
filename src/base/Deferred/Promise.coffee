
class CUI.Promise
	constructor: (@__deferred) ->
		assert(@__deferred instanceof CUI.Deferred,"new Promise","parameter needs to be instanceof CUI.Deferred", parameter: @__deferred)

	done: ->
		@__deferred.done.apply(@__deferred, arguments)
		@

	fail: ->
		@__deferred.fail.apply(@__deferred, arguments)
		@

	always: ->
		@__deferred.always.apply(@__deferred, arguments)
		@

	progress: ->
		@__deferred.progress.apply(@__deferred, arguments)
		@

	state: ->
		@__deferred.state.apply(@__deferred, arguments)

	getUniqueId: ->
		@__deferred.getUniqueId()