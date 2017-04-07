###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.WheelEvent extends CUI.MouseEvent
	dump: ->
		super()+" wheelY: **"+@wheelDeltaY()+"**"

	wheelDeltaY: ->
		ne = @getNativeEvent()
		if not ne
			return 0
		ne.deltaY or 0

