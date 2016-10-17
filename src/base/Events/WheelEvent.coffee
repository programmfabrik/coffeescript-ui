class CUI.WheelEvent extends CUI.MouseEvent
	dump: ->
		super()+" wheelY: **"+@wheelDeltaY()+"**"

	wheelDeltaY: ->
		ne = @getNativeEvent()
		if not ne
			return 0
		ne.deltaY or 0

