class Demo extends DOM

	display: ->
		"#{@__cls}.display: needs implementation."

	getRootCls: ->
		"ez-demo-#{toDash(@__cls)}"

	setConsole: (console) ->
		assert(console instanceof DemoConsole, "Demo.setConsole", "console needs to be instance of DemoConsole.")
		@__console = console

	log: (txt...) ->
		@__console.log(txt.join(" "))

	logTxt: (txt...) ->
		@log(toHtml(txt.join(" ")))

	undisplay: ->

	getBlindText: (repeat=1) ->
		r = """Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. """
		rs = []
		for i in [0...repeat]
			rs.push(r)
		rs.join(" ")

	getName: ->
		s = getObjectClass(@)
		if s.endsWith("Demo")
			s.substring(0, s.length-4)
		else
			s

Demo.demos = []

Demo.register = (demo) ->
	assert(demo instanceof Demo, "Demo.register", "demo must be instanceof Demo", demo: demo)
	Demo.demos.push(demo)

class DemoConsole extends DOM
	readOpts: ->
		super()
		@__logDiv = $div("cui-demo-console-log")[0]

	render: ->
		pane = new Pane
			top:
				content: new PaneHeader
					left:
						content: [
							new Button
								icon: "east"
								onClick: =>
									@__getPaneFlexHandle().close()
						,
							new Label(text: "Console")
						]
					right:
						content:
							icon: "trash"
							onClick: =>
								@__logDiv.innerHTML = ""

			center:
				content: @__logDiv

		@registerDOMElement(pane.DOM)
		pane

	__getPaneFlexHandle: ->
		DOM.data(@DOM.closest("[flex-handled-pane]")[0], "flexHandle")


	log: (txt) ->
		@__logDiv.appendChild($div().html(txt)[0])
		@__logDiv.scrollTop = @__logDiv.scrollHeight

class RunDemo extends Element
	constructor: (@opts={}) ->
		super(@opts)
		@demos = []
		@__console = new DemoConsole()
		@registerDemos()

		Events.listen
			type: "hashchange"
			node: window
			call: (ev) =>
				@displayDemo()

		@root = new Template
			name: "demo-root"
			map:
				body: true

		items = []
		for demo in @demos
			do (demo) =>
				items.push
					text: demo.getName()
					onClick: =>
						document.location.hash = "##{demo.getName()}"

		items.sort (a,b) ->
			if a.text < b.text
				-1
			else if a.text > b.text
				1
			else
				0

		@menuBtn = new Button
			menu:
				active_item_idx: null
				items: items
			icon: new Icon
				icon: "menu"
			icon_right: false

		@themeSwitch = new Button
			class: "theme-switch"
			text: "Theme"
			menu:
				onClick: (ev, btn, item) ->
					CUI.loadTheme(item.value)
					.done =>
						window.localStorage.setItem("theme", item.value)

				active_item_idx: null
				items: ->
					theme_items = []
					for theme in CUI.getThemeNames()
						theme_items.push
							text: theme
							value: theme
							active: theme == CUI.getActiveTheme().getName()
					theme_items

		@menu_title_label = new Label
			class: "cui-demo-title"
			text: "CUI"

		@menu_sub_title_label = new Label
			#class: "title title-2"
			text: ""

		@center_layout = new HorizontalLayout
			absolute: true
			center:
				class: "cui-demo-pane-center"
				content:
					new EmptyLabel
						centered: true
						text: "Choose a demo."
			right:
				class: "cui-demo-console"
				content:
					@__console.render()
				flexHandle:
					label:
						text: "Console"
					hidden: false
					closed: false



		@main_menu_pane = new VerticalLayout
			class: "cui-root-layout"
			top:
				content:
					[
						new PaneHeader
							left:
								content:
									[
										@menuBtn
										@menu_title_label
										@menu_sub_title_label
									]
							right:
								content:
										[
											@themeSwitch
										]
					]
			center:
				content: @center_layout

		@root.DOM.prependTo(document.body)
		@root.append( @main_menu_pane )

		CUI.loadHTMLFile("demo/easydbui_demo.html")
		.done =>
			@displayDemo()

	displayDemo: ->
		demo_name = document.location.hash.split("#")[1]

		demo = null
		for _demo in @demos
			if _demo.getName() == demo_name
				demo = _demo
				break

		if not demo or demo == @current_demo
			return

		bd = @main_menu_pane.center()
		#bd = @root.map.body.empty()

		if @current_demo
			bd.removeClass(@current_demo.getRootCls())
			@current_demo.undisplay()

		txt = "Demo.displayDemo #{demo_name}"
		console.time(txt)
		console.time("Wall:"+txt)
		@setTitle(demo)
		dfr = new CUI.Deferred()

		demo_content = demo.display()
		if not $(demo_content).hasClass("cui-pane")
			demo_content = new Pane
				center:
					content:
						demo_content
			.DOM
		@center_layout.replace( demo_content, "center" )
		console.timeEnd(txt)
		window.block_end_wall_time = 0
		end_wall_time = ->
			if window.block_end_wall_time
				CUI.setTimeout(end_wall_time, 0)
			else
				CUI.setTimeout ->
					console.timeEnd("Wall:"+txt)
				,
					0

		CUI.setTimeout(end_wall_time, 0)

		#@root.append(, "body").addClass(demo.getRootCls())
		# @root.triggerDOMInsert()

		@current_demo = demo
		@


	setTitle: (demo) ->
		@menu_sub_title_label.setText(demo.getName())

	registerDemos: ->
		@demos.splice(0)
		for demo in Demo.demos
			demo.setConsole(@__console)
			@demos.push(demo)
		@

# helps layouting examples, left column the example description, right column the example
class DemoTable
	constructor: (css_class="")->
		@table = $table("cui-demo-table "+css_class)
		@example_counter = 0

	addDivider: (text) ->

		label = new Label
			appearance: "title"
			size: "big"
			text: text
		tr = $tr_one_row(label.DOM).addClass("cui-demo-divider")

		tr.append($td())
		tr.append($td())

		@table.append( tr )


	# Adds an example row
	#
	# @param [String] description
	# @param [Element] example
	# @param [Element] buttons or other controls for controlling the example
	addExample: (description, div, controls=null) ->
		@example_counter+=1
		label = new Label
			text: @example_counter+". "+description
			multiline: true

		row_elements = [label,div]
		if controls
			row_elements.push(controls)
		@table.append($tr_one_row( row_elements ))


CUI.ready ->
	CUI.debug "this:", @
	for k in ["light", "dark", "ng"]
		CUI.registerTheme(k, CUI.pathToScript+"/demo/css/cui_demo_#{k}.css")

	CUI.loadTheme(window.localStorage.getItem("theme") or "light")

	new RunDemo()

Object.values = (obj) =>
	Object.keys(obj).map((key) => obj[key])
