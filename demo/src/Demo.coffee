###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo extends CUI.DOMElement

	display: ->
		"#{@__cls}.display: needs implementation."

	getRootCls: ->
		"cui-demo-#{CUI.util.toDash(@__cls)}"

	setConsole: (console) ->
		CUI.util.assert(console instanceof Demo.DemoConsole, "Demo.setConsole", "console needs to be instance of DemoConsole.")
		@__console = console

	log: (txt...) ->
		@__console.log(txt.join(" "))

	logTxt: (txt...) ->
		# no markdown
		@__console.log(txt.join(" "), false)

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
		s = CUI.util.getObjectClass(@)
		if s.endsWith("Demo")
			s.substring(0, s.length-4)
		else
			s

	@themeNames: ["ng", "debug", "fylr"]

	@cssLoader = new CUI.CSSLoader()

	@dividerLabel: (txt) ->
		new CUI.Label
			class: "cui-demo-divider-label"
			text: txt


	@demos: []

	@register: (demo) ->
		CUI.util.assert(demo instanceof Demo, "Demo.register", "demo must be instanceof Demo", demo: demo)
		@demos.push(demo)

class Demo.DemoConsole extends CUI.SimplePane
	constructor: (@opts = {}) ->
		super(@opts)

		@__console = new CUI.Console()

		btn1 = new CUI.Button
				icon: "east"
				onClick: =>
					@__getPaneFlexHandle().close()

		@append(btn1, "header_left")

		btn2 = new CUI.Button
				icon: "trash"
				onClick: =>
					@__console.clear()

		@append(btn2, "header_right")

		@append(new CUI.Label(text: "Console"), "header_center")

		@append(@__console, "content")

	forceHeader: ->
		true

	__getPaneFlexHandle: ->
		CUI.dom.data(CUI.dom.closest(@DOM, "[flex-handled-pane]"), "flexHandle")

	log: (txt, markdown) ->
		@__console.log(txt, markdown)


class Demo.RunDemo extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)
		@demos = []
		@__console = new Demo.DemoConsole()
		@registerDemos()

		CUI.Events.listen
			type: "hashchange"
			node: window
			call: (ev) =>
				console.debug "hashchange on window..", document.location.hash
				@displayDemo()

		groups = ["Core", "Base", "Extra", "Demo", "Test"].reverse()

		@menuBtn = new CUI.Button
			class: "cui-demo-menu-button"
			menu:
				active_item_idx: null
				items: =>
					items = []
					demos = @demos.slice(0)

					demos.sort (a, b) ->

						a_group_id = 1000-(CUI.util.idxInArray(a.getGroup(), groups)+1)
						b_group_id = 1000-(CUI.util.idxInArray(b.getGroup(), groups)+1)

						CUI.util.compareIndex(a_group_id+"_"+a.getName(), b_group_id+"_"+b.getName())

					old_group = null

					for demo in demos
						if old_group != demo.getGroup()
							old_group = demo.getGroup()

							if not CUI.util.isEmpty(old_group)
								items.push(label: old_group)

						# group_sort = (1000-(CUI.util.idxInArray(demo.getGroup(), groups)+1))+"_"+demo.getName()

						do (demo) =>
							items.push
								active: demo == @current_demo
								# text: demo.getGroup() + group_sort
								text: demo.getName()
								_demo: demo
								onClick: =>
									document.location.hash = "#"+demo.getName()
					items

			icon: new CUI.Icon
				icon: "menu"
			icon_right: false

#		@themeSwitch = new CUI.Button
#			class: "theme-switch"
#			text: "Theme"
#			tooltip:
#				text: "Pick a theme!"
#			menu:
#				onClick: (ev, btn, item) ->
#					old_theme = @cssLoader.getActiveTheme()?.name
#
#					if CUI.util.xor(old_theme.startsWith("ng"), item.value.startsWith("ng"))
#						reload = true
#					else
#						reload = false
#
#					@cssLoader.loadTheme(item.value)
#					.done =>
#						console.debug "load theme done, setting item", item.value
#						window.localStorage.setItem("theme", item.value)
#						# FIXME: once "ng" is finished, we can remove the reload
#						if reload
#							CUI.toaster(text: "Reloading...", show_ms: null)
#							document.location.reload()
#					.fail =>
#						CUI.alert
#							title: "Error"
#							text: "There was an error loading the \""+item.value+"\". Use 'make css_other' to produce the necessary files."
#
#				active_item_idx: null
#				items: ->
#					theme_items = []
#					for theme in Demo.themeNames
#						theme_items.push
#							text: theme
#							value: theme
#							active: theme == @cssLoader.getActiveTheme()?.name
#
#					theme_items

		@menu_title_label = new CUI.Label
			class: "cui-demo-title"
			text: "CUI"

		@menu_sub_title_label = new CUI.Label
			class: "cui-demo-sub-title"
			text: ""

		@center_layout = new CUI.HorizontalLayout
			center:
				class: "cui-demo-pane-center"
				content:
					new CUI.EmptyLabel
						centered: true
						text: "Choose a demo."
			right:
				class: "cui-demo-pane-right"
				content:
					@__console
				flexHandle:
					state_name: "cui-demo-right"
					label:
						text: "Console"
					hidden: false
					closed: false



		@main_menu_pane = new CUI.VerticalLayout
			class: "cui-root-layout"
			top:
				content:
					[
						new CUI.PaneHeader
							class: "cui-demo-header"
							left:
								content:
									[
										@menuBtn
										@menu_title_label
										@menu_sub_title_label
									]
#							right:
#								content:
#										[
#											@themeSwitch
#										]
					]
			center:
				class: "cui-demo-root-center"
				content: @center_layout

		CUI.dom.prepend(document.body, @main_menu_pane.DOM)

		@displayDemo()

	displayDemo: ->
		demo_name = decodeURIComponent(document.location.hash).match('^#([a-zA-Z &]+)')?[1]

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
			CUI.dom.removeClass(document.body, @current_demo.getRootCls())
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
			demo_content = new CUI.Pane
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
		CUI.dom.addClass(document.body, @current_demo.getRootCls())
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
class Demo.DemoTable
	constructor: (css_class="")->
		@table = CUI.dom.table("cui-demo-table "+css_class)
		@example_counter = 0

	addDivider: (text) ->

		td = CUI.dom.td("", colspan: 3)
		CUI.dom.append(td, Demo.dividerLabel(text).DOM)
		CUI.dom.append(@table, CUI.dom.append(CUI.dom.tr("cui-demo-divider"), td))


	# Adds an example row
	#
	# @param [String] description
	# @param [Element] example
	# @param [Element] buttons or other controls for controlling the example
	addExample: (description, div, controls=null, tr_class="") ->
		@example_counter+=1
		label = new CUI.Label
			text: description # @example_counter+". "+description
			multiline: true

		row_elements = [label,div]
		if controls
			row_elements.push(controls)
		tr = CUI.dom.tr_one_row( row_elements )
		CUI.dom.addClass(tr, tr_class)
		CUI.dom.addClass(tr.children[0], "cui-demo-example-label")
		CUI.dom.addClass(tr.children[1], "cui-demo-example-content")
		CUI.dom.append(@table, tr)

	addRow: ->
		td = CUI.dom.td("", colspan: 3)
		for arg in arguments
			CUI.dom.append(td, arg)
		CUI.dom.append(@table, CUI.dom.append(CUI.dom.tr("cui-demo-full-row"), td))

CUI.ready ->

# FIX ME: Using the CSS of CUI.
#	for k in Demo.themeNames
#		if not theme
#			theme = k

#	Demo.cssLoader.registerTheme(name: k, url: CUI.getPathToScript()+"../css/cui_demo_#{k}.css")
#		if k == window.localStorage.getItem("theme")
#			theme = k

#	Demo.cssLoader.loadTheme(theme)
#	.done =>
	splash_node = document.getElementById("cui-demo-splash")

	CUI.Events.wait
		type: "transitionend"
		node: splash_node
		maxWait: 2000
	.done =>
		console.warn "transitionend..."
		CUI.dom.remove(splash_node)
		splash_node = null
	.fail =>
		console.warn "rejected..."


	CUI.dom.setStyle(splash_node,
		opacity: 0
		pointerEvents: "none"
	)

	CUI.Events.listen
		type: [
			"mousedown"
			"mouseup"
			"touchstart"
			"touchend"
			"touchmove"
			"touchcancel"
			"touchforchange"
			"gesturestart"
			"gestureend"
			"gesturechange"
			"click"
		]
		capture: true
		call: (ev) =>
			ne = ev.getNativeEvent()
			if ev.getType().startsWith("touch")
				touches_print = []
				for touch in ne.touches
					touches_print.push(touch.pageX+"x"+touch.pageY)
				console.debug ev.getType(), ev.getNativeEvent(), touches_print.join(",") # ne, ne.touches, ne.touchTargets
			if ev.getType().startsWith("gesture")
				console.debug ev.getType(), ev.getNativeEvent(), ne.scale, ne.rotation
				ev.stopPropagation()
				ev.preventDefault()
			else
				; #console.debug "ev:", ev.getType(), ev.getTarget()

	new Demo.RunDemo()


CUI.DataField.defaults.undo_and_changed_support = true

Object.values = (obj) =>
	Object.keys(obj).map((key) => obj[key])

module.exports = Demo