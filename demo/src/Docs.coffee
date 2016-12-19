###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

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


		# Overwrite renderer's function "code" with ability to create DIV-blocks
		`
		renderer.code = function(code, lang, escaped) {

			/* Div-Hack */
			if (lang && lang.substring) {
				if (lang.substring(0,4) == "div-") {

					marked.setOptions({
						renderer: new marked.Renderer(),
						gfm: true,
						tables: true,
						breaks: false,
						pedantic: false,
						sanitize: false,
						smartLists: true,
						smartypants: false
					});

					return '<div class="'
						+ lang.substring(4)
						+ '">'
						+ marked(code)
						+ '\n</div>';

				}
			}

			if (this.options.highlight) {
				var out = this.options.highlight(code, lang);
				if (out != null && out !== code) {
					escaped = true;
					code = out;
				}
			}

			if (!lang) {
				return '<pre class="preee"><code>'
					+ (escaped ? code : escape(code, true))
					+ '\n</code></pre>';
			  }

			return '<pre class="preee"><code class="'
				+ this.options.langPrefix
				+ escape(lang, true)
				+ '">'
				+ (escaped ? code : escape(code, true))
				+ '\n</code></pre>\n';
		}
		`
		

		browser = new CUI.DocumentBrowser
			marked_opts:
				renderer: renderer
				gfm: true
				tables: true
				breaks: false
				pedantic: false
				sanitize: false
				smartLists: true
				smartypants: false
				highlight: (code) ->
					hljs.highlightAuto(code).value

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