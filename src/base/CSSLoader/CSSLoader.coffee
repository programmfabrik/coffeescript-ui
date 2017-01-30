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
		CUI.DOM.matchSelector(document.documentElement, "link[name=\""+@__cssName+"\"]")

	getActiveTheme: ->
		for cssNode in @__getCSSNodes()
			if not CUI.DOM.getAttribute(cssNode, "loading")
				name = CUI.DOM.getAttribute(cssNode, "theme")
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
		assert(url, "CSSLoader.loadTheme", "Theme not found.", name: name, themes: @__themes)

		if overload_url
			url = overload_url

		# console.error "nodes:", @__getCSSNodes()

		for oldCssNode in @__getCSSNodes()
			same_theme = CUI.DOM.getAttribute(oldCssNode, "theme") == name
			same_url = CUI.DOM.getAttribute(oldCssNode, "href") == url
			is_loading = CUI.DOM.getAttribute(oldCssNode, "loading")

			# console.debug same_theme, same_url, is_loading

			if is_loading
				loader_deferred = CUI.DOM.data(oldCssNode, "css-loader-deferred")
				if same_theme and same_url
					console.warn("CSSLoader.loadTheme:", name, ". Theme already loading, returning Promise.")
					return loader_deferred.promise()

				console.warn("CSSLoader.loadTheme:", name, ". Theme still loading, but a different one, aborting other load.")
				# reject loading, this removed the old node
				load_deferred.reject()
			else
				if same_theme and same_url
					# all good
					console.warn("CSSLoader.loadTheme:", name, ". Theme already loaded.")
					return CUI.resolvedPromise()

				# in all other cases we simply "overload"

		console.info("CSSLoader: Loading:", url)

		if name.startsWith("ng")
			CUI.__ng__ = true

		dfr = new CUI.Deferred()

		cssNode = CUI.DOM.element "LINK",
			rel: "stylesheet"
			charset: "utf-8"
			name: @__cssName
			loading: "1"
			theme: name
			href: url

		loc = CUI.parseLocation(url)

		if not loc.origin
			css_href = document.location.origin + url
		else
			css_href = url

		CUI.DOM.data(cssNode, "css-loader-deferred", dfr)

		dfr.always =>
			CUI.DOM.removeData(cssNode, "css-loader-deferred")
			CUI.DOM.removeAttribute(cssNode, "loading")

		dfr.fail (css_href) =>
			console.error("CSSLoader: Loading failed, removing node.", css_href)
			CUI.DOM.remove(cssNode)

		Events.listen
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
				for css_node in DOM.matchSelector(document.head, "link[name='"+@__cssName+"']") # :not([loading])")
					if css_node != cssNode
						console.warn("CSSLoader.loadTheme: Removing old css node:", CUI.DOM.getAttribute(css_node, "href"), "New Node is:", CUI.DOM.getAttribute(cssNode, "href"), "Is loading:", CUI.DOM.getAttribute(css_node, "loading"))
						CUI.DOM.remove(css_node)
						old_css_nodes.push(css_node)

				CUI.DOM.setAttribute(document.body, "cui-theme", name)

				console.info("CSSLoader.loadTheme: Loading went fine: ", url, "Removing the old CSS node: ",  old_css_nodes)
				Events.trigger
					type: "viewport-resize"
					info:
						css_load: true

				dfr.resolve(css_href)
				return

		Events.listen
			node: cssNode
			type: "error"
			call: (ev, info) =>
				console.error("CSS.load: loading error:", url)
				dfr.reject(css_href)
				return

		document.head.appendChild(cssNode)
		dfr.promise()
