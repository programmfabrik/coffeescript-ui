class Demo extends CUI.DOM

	display: ->
		"#{@__cls}.display: needs implementation."

	getRootCls: ->
		"cui-demo-#{toDash(@__cls)}"

	setConsole: (console) ->
		assert(console instanceof DemoConsole, "Demo.setConsole", "console needs to be instance of DemoConsole.")
		@__console = console

	log: (txt...) ->
		@__console.log(txt.join(" "))

	logTxt: (txt...) ->
		@log(txt.join(" "), false)

	undisplay: ->

	getBlindText: (repeat=1) ->
		r = """Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. """
		rs = []
		for i in [0...repeat]
			rs.push(r)
		rs.join(" ")

	getGroup: ->
		"Base"

	getName: ->
		s = getObjectClass(@)
		if s.endsWith("Demo")
			s.substring(0, s.length-4)
		else
			s

	@dividerLabel: (txt) ->
		new Label
			class: "cui-demo-divider-label"
			text: txt


	@demos: []

	@register: (demo) ->
		assert(demo instanceof Demo, "Demo.register", "demo must be instanceof Demo", demo: demo)
		@demos.push(demo)

class DemoConsole extends CUI.SimplePane
	constructor: (@opts = {}) ->
		super(@opts)

		@__console = new CUI.Console()

		btn1 = new Button
				icon: "east"
				onClick: =>
					@__getPaneFlexHandle().close()

		@append(btn1, "header_left")

		btn2 = new Button
				icon: "trash"
				onClick: =>
					@__console.clear()

		@append(btn2, "header_right")

		@append(new Label(text: "Console"), "header_center")

		@append(@__console, "content")

	__getPaneFlexHandle: ->
		DOM.data(@DOM.closest("[flex-handled-pane]")[0], "flexHandle")

	log: (txt, markdown) ->
		@__console.log(txt, markdown)


class RunDemo extends CUI.Element
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

		groups = ["Core", "Base", "Extra", "Demo", "Test"].reverse()

		@menuBtn = new Button
			class: "cui-demo-menu-button"
			menu:
				active_item_idx: null
				items: =>
					items = []
					demos = @demos.slice(0)

					demos.sort (a, b) ->

						a_group_id = 1000-(idxInArray(a.getGroup(), groups)+1)
						b_group_id = 1000-(idxInArray(b.getGroup(), groups)+1)

						compareIndex(a_group_id+"_"+a.getName(), b_group_id+"_"+b.getName())

					old_group = null

					for demo in demos
						if old_group != demo.getGroup()
							old_group = demo.getGroup()

							if not isEmpty(old_group)
								items.push(label: old_group)

						# group_sort = (1000-(idxInArray(demo.getGroup(), groups)+1))+"_"+demo.getName()

						do (demo) =>
							items.push
								active: demo == @current_demo
								# text: demo.getGroup() + group_sort
								text: demo.getName()
								_demo: demo
								onClick: =>
									document.location.hash = "##{demo.getName()}"
					items

			icon: new Icon
				icon: "menu"
			icon_right: false

		@themeSwitch = new Button
			class: "theme-switch"
			text: "Theme"
			tooltip:
				text: "Pick a theme!"
			menu:
				onClick: (ev, btn, item) ->
					old_theme = CUI.getActiveTheme().getName()

					if xor(old_theme.startsWith("ng"), item.value.startsWith("ng"))
						reload = true
					else
						reload = false

					CUI.loadTheme(item.value)
					.done =>
						console.debug "load theme done, setting item", item.value
						window.localStorage.setItem("theme", item.value)
						# FIXME: once "ng" is finished, we can remove the reload
						if reload
							CUI.toaster(text: "Reloading...", show_ms: null)
							document.location.reload()
					.fail =>
						CUI.alert
							title: "Error"
							text: "There was an error loading the \""+item.value+"\". Use 'make css_other' to produce the necessary files."

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
			class: "cui-demo-sub-title"
			text: ""

		@center_layout = new HorizontalLayout
			center:
				class: "cui-demo-pane-center"
				content:
					new EmptyLabel
						centered: true
						text: "Choose a demo."
			right:
				class: "cui-demo-pane-right"
				content:
					@__console
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
							class: "cui-demo-header"
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
				class: "cui-demo-root-center"
				content: @center_layout

		CUI.DOM.prepend(document.body, @main_menu_pane.DOM)

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
			CUI.DOM.removeClass(document.body, @current_demo.getRootCls())
			@current_demo.undisplay()

		txt = "Demo.displayDemo #{demo_name}"
		console.time(txt)
		console.time("Wall:"+txt)
		@setTitle(demo)
		dfr = new CUI.Deferred()

		demo_content = demo.display()
		if demo_content.DOM
			demo_content = demo_content.DOM

		console.debug "received demo content", demo, demo_content

		if CUI.isArray(demo_content) or not demo_content.classList.contains("cui-pane")
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
		@current_demo = demo
		CUI.DOM.addClass(document.body, @current_demo.getRootCls())
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

		td = $td("", colspan: 3)
		td.append(Demo.dividerLabel(text).DOM)
		@table.append($tr("cui-demo-divider").append(td))


	# Adds an example row
	#
	# @param [String] description
	# @param [Element] example
	# @param [Element] buttons or other controls for controlling the example
	addExample: (description, div, controls=null, tr_class="") ->
		@example_counter+=1
		label = new Label
			text: description # @example_counter+". "+description
			multiline: true

		row_elements = [label,div]
		if controls
			row_elements.push(controls)
		tr = $tr_one_row( row_elements )
		tr.addClass(tr_class)
		tr.children[0].addClass("cui-demo-example-label")
		tr.children[1].addClass("cui-demo-example-content")
		@table.append(tr)

	addRow: ->
		td = $td("", colspan: 3)
		td.append.apply(td, arguments)
		@table.append($tr("cui-demo-full-row").append(td))

CUI.ready ->

	for k in ["light", "dark", "ng", "ng_debug"]
		if not theme
			theme = k

		CUI.registerTheme(k, CUI.pathToScript+"/demo/css/cui_demo_#{k}.css")
		if k == window.localStorage.getItem("theme")
			theme = k

	CUI.loadTheme(theme)
	.done =>
		splash_node = document.getElementById("cui-demo-splash")

		Events.wait
			type: "transitionend"
			node: splash_node
			maxWait: 2000
		.done =>
			console.warn "transitionend..."
			splash_node.remove()
			splash_node = null

		CUI.DOM.setStyle(splash_node,
			opacity: 0
			pointerEvents: "none"
		)

	mouse_pos = null

	Events.listen
		type: "mousemove"
		capture: true
		call: (ev) =>
			# store mouse position
			mouse_pos = x: ev.pageX(), y: ev.pageY()

	CUI.initNodeDebugCopy()

	new RunDemo()

Object.values = (obj) =>
	Object.keys(obj).map((key) => obj[key])
