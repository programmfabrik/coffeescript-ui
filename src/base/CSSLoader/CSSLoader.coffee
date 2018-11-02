###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# my_load = new CUI.CSSLoader()
# my_load.load(theme: "1", url: "...theme1.css") -> Promise
# my_load.load(theme: "roman", url: "...theme2.css") -> Promise
# my_load.getActiveCSS() -> {theme: "roman", url: ...}

class CUI.CSSLoader extends CUI.Element

	readOpts: ->
		super()
		@__cssName = "cui-css-"+@getUniqueId()

	__getCSSNodes: ->
		CUI.dom.matchSelector(document.documentElement, "link[name=\""+@__cssName+"\"]")

	getActiveCSS: ->
		for cssNode in @__getCSSNodes()
			if CUI.dom.getAttribute(cssNode, "data-cui-loading")
				continue

			return
				url: CUI.dom.getAttribute(cssNode, "data-cui-url")
				theme: CUI.dom.getAttribute(cssNode, "data-cui-theme")

		return null

	load: (_opts = {}) ->
		opts = CUI.Element.readOpts _opts, "CSSLoader",
			theme:
				check: String
				default: ""
			url:
				mandatory: true
				check: String

		# console.error "nodes:", @__getCSSNodes(), opts, @getActiveCSS()
		for oldCssNode in @__getCSSNodes()
			is_loading = CUI.dom.getAttribute(oldCssNode, "data-cui-loading")
			if is_loading
				console.warn("CSSLoader.load. CSS already loading.", opts: opts)
				return CUI.rejectedPromise()

		active = @getActiveCSS()
		if active and opts.url == active.url and active.theme == opts.theme
			return CUI.resolvedPromise()

		url = opts.url

		dfr = new CUI.Deferred()

		if url.startsWith("http://") or
			url.startsWith("https://") or
			url.startsWith("file://")
				css_href = url
		else if not url.startsWith("/")
			css_href = CUI.getPathToScript() + url
		else
			css_href = document.location.origin + url

		# console.info("CSSLoader: Loading:", css_href)

		# console.error "parsing location", url, CUI.getPathToScript(), css_href

		cssNode = CUI.dom.element "LINK",
			rel: "stylesheet"
			charset: "utf-8"
			name: @__cssName
			"data-cui-loading": "1"
			"data-cui-theme": opts.theme
			"data-cui-url": opts.url
			href: css_href

		old_css_nodes = CUI.dom.matchSelector(document.head, "link[name='"+@__cssName+"']")

		dfr.always =>
			CUI.dom.removeAttribute(cssNode, "data-cui-loading")

		dfr.fail (css_href) =>
			console.error("CSSLoader: Loading failed, removing node.", css_href)
			CUI.dom.remove(cssNode)

		CUI.Events.listen
			node: cssNode
			type: "load"
			call: (ev, info) =>

				if dfr.state() != "pending"
					console.warn("CSSLoader.loadTheme: Caught event load second time, ignoring. IE does that for some reason.")
					return

				if CUI.browser.ie
					found_stylesheet = false

					# ok, let's check if the style sheet loaded actually applies
					# rules. IE tends to ignore 404 here.
					for styleSheet in document.styleSheets
						if styleSheet.href == css_href # this is the css loaded
							try
								if not styleSheet.cssRules?.length # we assume loading failed
									console.error("CSSLoader: Loaded a stylesheet with no rules: ", css_href, styleSheet)
									dfr.reject(css_href)
									return
								found_stylesheet = true
							catch ex
								; # ignore, we output an error below
							break

					if not found_stylesheet
						console.error("CSSLoader: Stylesheet not correctly loaded: ", css_href)
						dfr.reject(css_href)
						return

				# old_css_nodes = []
				for css_node in old_css_nodes # :not([loading])")
					if css_node == cssNode
						continue
						# console.info("CSSLoader.loadTheme: Removing old css node:", CUI.dom.getAttribute(css_node, "href"), "New Node is:", CUI.dom.getAttribute(cssNode, "href"), "Is loading:", CUI.dom.getAttribute(css_node, "loading"))
					CUI.dom.remove(css_node)
						# old_css_nodes.push(css_node)

				CUI.dom.setAttribute(document.body, "data-cui-theme", opts.theme)

				# console.info("CSSLoader.loadTheme: Loading went fine: ", url, "Removing the old CSS node: ",  old_css_nodes)
				CUI.Events.trigger
					type: "viewport-resize"
					info:
						css_load: true

				dfr.resolve(css_href)
				return

		CUI.Events.listen
			node: cssNode
			type: "error"
			call: (ev, info) =>
				console.error("CSS.load: loading error:", url)
				dfr.reject(css_href)
				return

		if old_css_nodes.length > 0
			CUI.dom.insertAfter(old_css_nodes[old_css_nodes.length - 1], cssNode)
		else
			document.head.appendChild(cssNode)
		dfr.promise()
