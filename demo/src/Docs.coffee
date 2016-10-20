class Docs extends Demo
	getGroup: ->
		""

	getName: ->
		"Documentation"

	display: ->

		Events.listen
			type: "hashchange"
			node: window
			call: =>
				load_hash()
				return

		load_hash = =>
			hash = document.location.hash.split("#")
			if hash[2]
				browser.loadLocation(hash[2])
				true
			else
				false

		browser = new CUI.DocumentBrowser
			gotoLocation: (nodePath) ->
				document.location = document.location.origin + document.location.pathname + "#Documentation#"+nodePath
			url: "/easydb/docs/root"
			# url: CUI.getPathToScript()+Docs.path # set by Makefile

		dom = browser.render()
		browser.load()
		.done =>
			if not load_hash()
				# load first child
				browser.loadLocation()
		dom


Demo.register(new Docs())