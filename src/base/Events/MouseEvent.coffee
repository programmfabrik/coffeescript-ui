###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.MouseEvent extends CUI.Event
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


	getTarget: ->
		if CUI.browser.firefox and @getType() in ["mousemove", "mouseup"]
			# ok, in firefox the target of the mousemove
			# event is WRONG while dragging. we need to overwrite
			# this with elementFromPoint, true story :(
			return @getPointTarget()
		return super()