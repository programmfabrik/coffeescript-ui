###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Spinner extends CUI.Toaster
	initOpts: ->
		super()
		@mergeOpt "text_icon",
			default: "spinner"
		@mergeOpt "show_ms",
			default: 0
		@mergeOpt "backdrop",
			default:
				policy: "modal"

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

CUI.spinner = (opts=text: "CUI.spinner") ->
	spinner = new CUI.Spinner(opts)
	spinner.open()
	spinner

