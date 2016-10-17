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

