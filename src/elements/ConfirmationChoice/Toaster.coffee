class CUI.Toaster extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		@removeOpt("choices")
		@removeOpt("backdrop")

	readOpts: ->
		super()
		@_backdrop = false
		@_choices = []

	open: ->
		# super sets a deferred
		super()
		CUI.setTimeout
			ms: @_show_ms
			call: =>
				@hide()
				@__deferred.resolve()
		return @__deferred.promise()

CUI.toaster = (opts=text: "CUI.toaster") ->
	new CUI.Toaster(opts).open()
