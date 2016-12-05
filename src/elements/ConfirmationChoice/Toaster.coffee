###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Toaster extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		@removeOpt("choices")
		@mergeOpt "backdrop",
			default: false
		@mergeOpt "show_ms",
			check: (v) ->
				v >= 0

	readOpts: ->
		super()
		@_choices = []

	open: ->
		# super sets a deferred
		super()
		if @_show_ms > 0
			CUI.setTimeout
				ms: @_show_ms
				call: =>
					@hide()
					@__deferred.resolve()
		return @__deferred.promise()

CUI.toaster = (opts=text: "CUI.toaster") ->
	toaster = new CUI.Toaster(opts)
	toaster.open()
	toaster
