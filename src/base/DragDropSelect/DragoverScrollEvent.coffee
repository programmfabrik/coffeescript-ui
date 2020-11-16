class CUI.DragoverScrollEvent extends CUI.Event
	initOpts: ->
		super()
		@addOpts
			count:
				mandatory: true
				check: (v) =>
					CUI.util.isPosInt(v)
			originalEvent:
				mandatory: true
				check: CUI.Event

	getCount: ->
		@_count

	getOriginalEvent: ->
		@_originalEvent
