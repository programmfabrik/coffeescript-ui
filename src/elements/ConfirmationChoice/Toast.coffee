class CUI.Toast extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		@removeOpt("choices")


	readOpts: ->
		super()
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

CUI.toast = (opts=text: "CUI.toast") ->
	new CUI.Toast(opts).open()
