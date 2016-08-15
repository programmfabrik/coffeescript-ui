class LayoutDemo extends Demo
	display: ->
		# create a table to show off the layout demo
		tb = new DemoTable()
		tb.addDivider("layout demo")

		@__data =
			parent_type: null
			child_type: null
			child_max: []
			parent_max: []

		number = parseInt(window.localStorage.getItem("cui-layout-demo-number")) or 0
		@setPlaygroundNumber(number)

		parent_type = new Options
			name: "parent_type"
			form:
				label: "Parent"
			undo_and_changed_support: false
			radio: true
			options: [
				text: "HorizontalLayout"
				value: "HorizontalLayout"
			,
				text: "VerticalLayout"
				value: "VerticalLayout"
			,
				text: "HorizontalList"
				value: "HorizontalList"
			,
				text: "VerticalList"
				value: "VerticalList"
			]

		parent_max = new Options
			form:
				label: "Parent Maximize"

			undo_and_changed_support: false
			name: "parent_max"
			options: [
				text: "horizontal"
			,
				text: "vertical"
			]

		child_type = new Options
			form:
				label: "Child"
			name: "child_type"

			undo_and_changed_support: false
			radio: true
			options: [
				text: "HorizontalLayout"
				value: "HorizontalLayout"
			,
				text: "VerticalLayout"
				value: "VerticalLayout"
			,
				text: "HorizontalList"
				value: "HorizontalList"
			,
				text: "VerticalList"
				value: "VerticalList"
			]

		child_max = new Options
			form:
				label: "Child Maximize"

			undo_and_changed_support: false
			name: "child_max"
			options: [
				text: "horizontal"
			,
				text: "vertical"
			]

		@__form = new Form
			undo_and_changed_support: false
			data: @__data
			onDataChanged: =>
				console.debug dump(@__data)
				@renderPlayground()
			fields: [
				parent_type
				parent_max
				child_type
				child_max
			]

		@__form.start()

		@hl = new VerticalLayout
			maximize: true
			top:
				content: @__form
			center:
				class: "cui-layout-demo-playground"
			bottom:
				content: @renderPlaygroundSwitcher()

		@renderPlayground()
		@hl

	# returns a number calculated
	# with bits from data
	getPlaygroundNumber: ->
		twoN = (exp) ->
			Math.pow(2, exp)

		number = 0
		switch @__data.parent_type
			when "VerticalList"
				number = number | twoN(0)
				number = number | twoN(1)
			when "HorizontalList"
				number = number | twoN(1)
			when "VerticalLayout"
				number = number | twoN(0)

		if "horizontal" in @__data.parent_max
			number = number | twoN(2)

		if "vertical" in @__data.parent_max
			number = number | twoN(3)


		switch @__data.child_type
			when "VerticalList"
				number = number | twoN(4)
				number = number | twoN(5)
			when "HorizontalList"
				number = number | twoN(5)
			when "VerticalLayout"
				number = number | twoN(4)


		if "horizontal" in @__data.child_max
			number = number | twoN(6)

		if "vertical" in @__data.child_max
			number = number | twoN(7)

		console.debug "@getPlaygroundNumber:", number

		number

	setPlaygroundNumber: (number) ->
		console.error "setPlaygroundNumber", number
		twoN = (exp) ->
			Math.pow(2, exp)

		@__data.parent_max.splice(0)
		@__data.child_max.splice(0)

		if number & twoN(0) && number & twoN(1)
			@__data.parent_type = "VerticalList"
		else if number & twoN(1)
			@__data.parent_type = "HorizontalList"
		else if number & twoN(0)
			@__data.parent_type = "VerticalLayout"
		else
			@__data.parent_type = "HorizontalLayout"

		if number & twoN(2)
			@__data.parent_max.push("horizontal")

		if number & twoN(3)
			@__data.parent_max.push("vertical")

		if number & twoN(4) && number & twoN(5)
			@__data.child_type = "VerticalList"
		else if number & twoN(5)
			@__data.child_type = "HorizontalList"
		else if number & twoN(4)
			@__data.child_type = "VerticalLayout"
		else
			@__data.child_type = "HorizontalLayout"

		if number & twoN(6)
			@__data.child_max.push("horizontal")

		if number & twoN(7)
			@__data.child_max.push("vertical")

		@

	renderPlayground: ->
		console.debug "drawing playground number:", number, dump(@__data)

		number = @getPlaygroundNumber()

		content = => [
			new Label(text: "Label #1")
		,
			new Label(text: "Label #2")
		,
			new Label(text: "Label #3")
		,
			new Button(text: "Button #1")
		,
			new Button(text: "Button #2")
		,
			new Button(text: "Button #3")
		]

		get_layout = (type, max) ->
			opts =
				maximize_horizontal: "horizontal" in max
				maximize_vertical: "vertical" in max
				auto_buttonbar: false

			switch type
				when "HorizontalLayout"
					opts.left =
						content: content()
					opts.right =
						content: content()
					opts.center =
						content: content()

				when "VerticalLayout"
					opts.top =
						content: content()
					opts.bottom =
						content: content()
					opts.center =
						content: content()

				when "HorizontalList", "VerticalList"
					opts.content = content()


			new CUI[type](opts)

		parent = get_layout(@__data.parent_type, @__data.parent_max)
		child = get_layout(@__data.child_type, @__data.child_max)

		child.addClass("cui-layout-demo-child")
		parent.addClass("cui-layout-demo-parent")

		if @__data.parent_type.endsWith("Layout")
			parent.replace(child, "center")
		else
			parent.append(child, "center")
		@hl.replace(parent, "center")

		@__playgroundNumberInput.setValue(number+1)
		window.localStorage.setItem("cui-layout-demo-number", number) or 0
		@

	updatePlaygroundNumber: (number) ->
		@setPlaygroundNumber(number)
		@__form.reload()
		@renderPlayground()
		@


	renderPlaygroundSwitcher: ->
		max_num_playgrounds = Math.pow(2, 7+1) - 1

		prev_btn =
			new Button
				icon: "left"
				onClick: =>
					number = @getPlaygroundNumber()
					if number == 0
						@updatePlaygroundNumber(max_num_playgrounds)
					else
						@updatePlaygroundNumber(number-1)


		next_btn =
			new Button
				icon: "right"
				onClick: =>
					number = @getPlaygroundNumber()
					if number == max_num_playgrounds
						@updatePlaygroundNumber(0)
					else
						@updatePlaygroundNumber(number+1)

		number = @getPlaygroundNumber()

		new Buttonbar buttons:
			[
				prev_btn
			,
				@__playgroundNumberInput = new NumberInput
					data:
						number: number+1
					name: "number"
					undo_and_changed_support: false
					min: 1
					max: max_num_playgrounds
					onDataChanged: (data) =>
						console.debug "data", dump(data)
						if data.number-1 != @getPlaygroundNumber()
							@updatePlaygroundNumber(data.number-1)

				.start()
			,
				next_btn
			]

Demo.register(new LayoutDemo())