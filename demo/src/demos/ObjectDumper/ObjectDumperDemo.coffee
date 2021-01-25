###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2017 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.ObjectDumperDemo extends Demo
	getGroup: ->
		"Extra"

	display: ->
		div = CUI.dom.div("cui-object-dumper-demo")

		data = require('./example2.json');

		console.debug CUI.util.dump(data)
		od = new CUI.ObjectDumper
			header_left: new CUI.Label(text: 'example2.json')
			do_open: true
			object: data
		CUI.dom.append(div, od)

		div


Demo.register(new Demo.ObjectDumperDemo())
