###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class TooltipDemo extends Demo
	display: ->

		demo_table = new DemoTable('cui-tooltip-demo-table')

		text = $div('text-block')
		for _t, idx in @getBlindText(5).split(/(,\s+|\s+)/)
			t = _t.trim()
			if isEmpty(t)
				continue

			s = $span().text(t+" ")
			text.append(s)

			#every fifth word gets a tooltip

			if (idx % 5) != 0 or t == ","
				continue

			s.addClass("tooltip")
			hover = idx % 20 == 0
			if hover
				s.addClass("tooltip-on-hover")

			new Tooltip
				element: s
				show_ms: 1000
				hide_ms: 200
				on_hover: hover
				on_click: not hover
				text: @getBlindText()

		s = $span().text(" small Tooltip ")
		text.append(s)
		s.addClass("tooltip tooltip-on-hover")

		new Tooltip
			element: s
			show_ms: 1000
			hide_ms: 200
			on_hover: hover
			on_click: not hover
			text: "little Text"

		demo_table.addDivider("showing Tooltips on hover and on click.")

		demo_table.addRow(text)


Demo.register(new TooltipDemo())