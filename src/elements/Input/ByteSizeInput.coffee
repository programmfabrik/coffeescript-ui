class CUI.ByteSizeInput extends CUI.Input

	render: ->
		super()

		selectData = {}
		select = new CUI.Select
			data: selectData
			onDataChanged: ->
				console.log(selectData)
			options: [
				text: "Bytes"
				value: "bytes"
			,
				text: "MB"
				value: "mb"
			,
				text: "GB"
				value: "gb"
			]
		select.start()

		parent = @__input.parentElement
		horizontalLayout = new CUI.HorizontalLayout
			center:
				content: [@__input, select]
		CUI.dom.replace(parent, horizontalLayout)
		return @

	storeValue: (value) ->
		console.log(value)
		super(value, flags)
		@
