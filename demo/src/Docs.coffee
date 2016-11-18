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
			match = document.location.hash.match('#Documentation(\/.*?)(?:;(.+?)|)(?:\\*([0-9]+)|)$')
			if match
				browser.loadLocation(match[1], match[2], match[3])
				true
			else
				false

		renderer = new marked.Renderer()

		browser = new CUI.DocumentBrowser
			marked_opts:
				renderer: renderer

			gotoLocation: (nodePath, search, nodeIdx) ->
				loc = document.location.origin + document.location.pathname + "#Documentation"+nodePath
				if search
					loc = loc + ";" + search
					if parseInt(nodeIdx) >= 0
						loc = loc + "*" + nodeIdx

				document.location = loc

			renderHref: (href, nodePath) ->
				if href.startsWith("http")
					return href

				if href.startsWith("/")
					console.warn("Absolute links are not recommended:", nodePath)
					new_href = nodePath
				else
					path = nodePath.split("/")
					href_path = href.split("/")

					while part = href_path.shift()
						if part.startsWith("#") # ignore for now
							console.warn("Ignoring #link:", nodePath, href)
							break

						switch path
							when "."
								continue
							when ".."
								path.pop()
							else
								path.push(part)

					if path[0] == ""
						new_href = path.join("/")
					else
						new_href = "/"+path.join("/")

				new_href = "#Documentation"+new_href
				new_href
			# url: "/easydb/docs/root"
			url: CUI.getPathToScript()+Docs.path # set by Makefile

		dom = browser.render()
		browser.load()
		.done =>
			if not load_hash()
				# load first child
				browser.loadLocation()
		dom


Demo.register(new Docs())