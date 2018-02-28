###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.TooltipDemo extends Demo
	display: ->

		demo_table = new Demo.DemoTable('cui-tooltip-demo-table')

		text = CUI.dom.div('text-block')
		for _t, idx in @getBlindText(5).split(/(,\s+|\s+)/)
			t = _t.trim()
			if CUI.util.isEmpty(t)
				continue

			s = CUI.dom.span()
			s.textContent = t + " "
			CUI.dom.append(text, s)

			#every fifth word gets a tooltip

			if (idx % 5) != 0 or t == ","
				continue

			CUI.dom.addClass(s, "tooltip")
			hover = idx % 20 == 0
			if hover
				CUI.dom.addClass(s, "tooltip-on-hover")

			new CUI.Tooltip
				element: s
				show_ms: 1000
				hide_ms: 200
				on_hover: hover
				on_click: not hover
				text: @getBlindText()

		s = CUI.dom.span()
		s.textContent = " small Tooltip "
		CUI.dom.append(text, s)
		CUI.dom.addClass(s, "tooltip tooltip-on-hover")

		new CUI.Tooltip
			element: s
			show_ms: 1000
			hide_ms: 200
			on_hover: hover
			on_click: not hover
			text: "little Text"

		demo_table.addDivider("showing Tooltips on hover and on click.")

		demo_table.addRow(text)


Demo.register(new Demo.TooltipDemo())