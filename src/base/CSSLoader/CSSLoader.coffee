###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###


class CUI.CSSLoader extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			group:
				mandatory: true
				default: "main"
				check: String

	readOpts: ->
		super()
		@__cssName = "cui-css-"+@_group
		@__themes = {}

	__getCSSNodes: ->
		CUI.dom.matchSelector(document.documentElement, "link[name=\""+@__cssName+"\"]")

	getActiveTheme: ->
		for cssNode in @__getCSSNodes()
			if not CUI.dom.getAttribute(cssNode, "loading")
				name = CUI.dom.getAttribute(cssNode, "theme")
				active_theme = @__themes[name]
				break

		if active_theme
			return active_theme

		return null

	getThemes: ->
		@__themes

	registerTheme: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CSS.registerTheme",
			name:
				mandatory: true
				check: String
			url:
				mandatory: true
				check: String

		@__themes[opts.name] = opts

	forceReloadTheme: ->
		theme = @getActiveTheme()
		if not active_theme
			return CUI.rejectedPromise()

		@loadTheme(theme, true)


	loadTheme: (name, overload_url = null) ->
		url = @__themes[name]?.url
		CUI.util.assert(url, "CSSLoader.loadTheme", "Theme not found.", name: name, themes: @__themes)

		if overload_url
			url = overload_url

		# console.error "nodes:", @__getCSSNodes()

		for oldCssNode in @__getCSSNodes()
			same_theme = CUI.dom.getAttribute(oldCssNode, "theme") == name
			same_url = CUI.dom.getAttribute(oldCssNode, "href") == url
			is_loading = CUI.dom.getAttribute(oldCssNode, "loading")

			# console.debug same_theme, same_url, is_loading

			if is_loading
				loader_deferred = CUI.dom.data(oldCssNode, "css-loader-deferred")
				if same_theme and same_url
					console.warn("CSSLoader.loadTheme:", name, ". Theme already loading, returning Promise.")
					return loader_deferred.promise()

				# console.warn("CSSLoader.loadTheme:", name, ". Theme still loading, but a different one, aborting other load.")
				# reject loading, this removed the old node
				load_deferred.reject()
			else
				if same_theme and same_url
					# all good
					# console.warn("CSSLoader.loadTheme:", name, ". Theme already loaded.")
					return CUI.resolvedPromise()

				# in all other cases we simply "overload"

		# console.info("CSSLoader: Loading:", url)

		dfr = new CUI.Deferred()

		if url.startsWith("http://") or
			url.startsWith("https://") or
			url.startsWith("file://")
				css_href = url
		else if not url.startsWith("/")
			css_href = CUI.getPathToScript() + url
		else
			css_href = document.location.origin + url

		# console.error "parsing location", url, CUI.getPathToScript(), css_href

		cssNode = CUI.dom.element "LINK",
			rel: "stylesheet"
			charset: "utf-8"
			name: @__cssName
			loading: "1"
			theme: name
			href: css_href


		CUI.dom.data(cssNode, "css-loader-deferred", dfr)

		dfr.always =>
			CUI.dom.removeData(cssNode, "css-loader-deferred")
			CUI.dom.removeAttribute(cssNode, "loading")

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

				old_css_nodes = []
				for css_node in CUI.dom.matchSelector(document.head, "link[name='"+@__cssName+"']") # :not([loading])")
					if css_node != cssNode
						# console.info("CSSLoader.loadTheme: Removing old css node:", CUI.dom.getAttribute(css_node, "href"), "New Node is:", CUI.dom.getAttribute(cssNode, "href"), "Is loading:", CUI.dom.getAttribute(css_node, "loading"))
						CUI.dom.remove(css_node)
						old_css_nodes.push(css_node)

				CUI.dom.setAttribute(document.body, "cui-theme", name)

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

		document.head.appendChild(cssNode)
		dfr.promise()
