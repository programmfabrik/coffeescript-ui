###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2017 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ObjectDumperDemo extends Demo
	getGroup: ->
		"Extra"

	display: ->
		div = $div("cui-object-dumper-demo")

		fn = "/demo/resources/example.json"

		xhr = new CUI.XHR
			url: CUI.getPathToScript()+fn

		xhr.start()
		.done (data) ->
			od = new CUI.ObjectDumper
				header_left: new Label(text: fn)
				# do_open: true
				object: data
			CUI.DOM.append(div, od)
		.fail ->
			CUI.problem(text: "Problem loading Demo data: "+fn)

		div


Demo.register(new ObjectDumperDemo())