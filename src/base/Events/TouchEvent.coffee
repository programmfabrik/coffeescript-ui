###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.TouchEvent extends CUI.MouseEvent
	initOpts: ->
		super()
		@addOpts
			button:
				check: (v) ->
					v >= 0
			pageX:
				check: (v) ->
					v > 0
			pageY:
				check: (v) ->
					v > 0
			clientX:
				check: (v) ->
					v > 0
			clientY:
				check: (v) ->
					v > 0

	setNativeEvent: (ev) ->
		for k in [
			"button"
			"pageX"
			"pageY"
			"clientX"
			"clientY"
		]
			prop = "_"+k
			if @hasOwnProperty(prop)
				ev[k] = @[prop]

		super(ev)

CUI.windowCompat.protect.push("TouchEvent")
