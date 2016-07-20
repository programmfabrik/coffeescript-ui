class OutputContent extends DataFieldInput
	initOpts: ->
		super()
		@addOpts
			placeholder:
				default: ""
				check: String
			content:
				check: (v) ->
					isElement(v) or isElement(v.DOM)
			getValue:
				check: Function

	# disable: ->
	# 	@addClass("cui-data-field-disabled")

	# enable: ->
	# 	@removeClass("cui-data-field-disabled")

	setContent: (content=null) ->
		CUI.debug "setContent", @DOM, content
		if not content
			@DOM.addClass("cui-output-empty")
			@empty()
		else
			@DOM.removeClass("cui-output-empty")
			@replace(content)

	displayValue: ->
		super()
		if @getName()
			@setContent(@getValue())
		@

	getValue: ->
		value = super()
		if @_getValue
			@_getValue.call(@, value)
		else
			value

	render: ->
		super()
		@setContent(@_content)
