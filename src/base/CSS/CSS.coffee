
#REMARKED hack used for debugging scss without additional customer css
#css_loaded = false

class CSS extends Element
	constructor: (@opts={}) ->
		super(@opts)
		# use basename of file
		@__cssName = @_group
		@setUrl(@_url)
		# CUI.debug @_name, @_path, @__url

	initOpts: ->
		super()
		@addOpts
			group:
				mandatory: true
				check: String
			name:
				mandatory: true
				check: String
			url:
				mandatory: true
				check: String

	unload: ->
		@__cssNode?.remove()
		@__cssNode = null

	reload: ->
		@load(true)

	setUrl: (url) ->
		if url == @getUrl()
			CUI.info("CSS.setUrl: URL already the same", url)
			return CUI.resolvedPromise()

		@__url = url
		if @__cssNode
			CUI.info("CSS.setUrl: new URL", @__url)
			# reload
			@load()
		else
			CUI.info("CSS.setUrl: new URL", @getName(), @__url, "not loading.")
			CUI.resolvedPromise()

	getUrl: ->
		@__url

	getLoadedUrl: ->
		@__loadedUrl

	load: (produce=false) ->

		#		if css_loaded
		#			return
		#		css_loaded = true

		if @__loading
			CUI.info("CSS.load: Loading in progres, not loading a second time.")
			return CUI.resolvedPromise()

		@__loading = true

		if produce
			ms = (new Date().getTime())
			if @getUrl().match(/\?/)
				url = @getUrl()+"&produce=1&ms="+ms
			else
				url = @getUrl()+"?produce=1&ms="+ms
		else
			url = @getUrl()

		CUI.info("CSS.load:", url)

		dfr = new CUI.Deferred()

		dfr.always =>
			@__loading = false

		cssNode = $element("link", ""
			rel: "stylesheet"
			charset: "utf-8"
			name: @__cssName
			href: url
		)

		DOM.data(cssNode, "element", @)

		Events.listen
			node: cssNode
			type: "load"
			call: (ev, info) =>
				if dfr.state() != "pending"
					CUI.warn("CSS.load: Caught event load second time, ignoring. IE does that for some reason.")
					return

				old_css_nodes = []
				for css_node in DOM.matchSelector(document.head, "link[name='"+@__cssName+"']")
					if css_node != cssNode
						DOM.remove(css_node)
						old_css_nodes.push(css_node)

				CUI.info("CSS.load: loading went fine: ", url, "Removing the old CSS node: ",  old_css_nodes)
				Events.trigger
					type: "viewport-resize"

				@__loadedUrl = url
				@__cssNode = cssNode
				dfr.resolve()
				return

		Events.listen
			node: cssNode
			type: "error"
			call: (ev, info) =>
				cssNode.remove()
				CUI.error("CSS.load: loading error:", url)
				dfr.reject()
				return

		document.head.appendChild(cssNode)

		# anchor_node.after(@__cssNode)
		dfr.promise()

	isActive: ->
		!!@__cssNode

	getNode: ->
		@__cssNode

	getName: ->
		@_name

	destroy: ->
		@unload()
		super()

