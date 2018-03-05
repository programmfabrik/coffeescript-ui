class CUI.DataFieldProxy extends CUI.DataField

	readOpts: ->
		super()
		@__element = null

	initOpts: ->
		super()
		@addOpts
			call_others:
				default: true
				check: Boolean
			element:
				mandatory: true
				check: (v) ->
					CUI.util.isContent(v)
			getDefaultValue:
				check: Function

	getFields: ->
		fields = []

		if not @_call_others
			return fields

		if not @__element
			if CUI.isFunction(@_element)
				# console.warn("DataFieldProxy.getFields", "element is a function and DataFieldProxy.render has not been called yet, unable to getFields", opts: @opts)
				return fields
			search_el = @_element
		else
			search_el = @__element

		if search_el instanceof CUI.DOMElement
			if search_el.isDestroyed()
				return fields

			_el = search_el.DOM
		else
			_el = search_el

		for el in CUI.dom.matchSelector(_el, "[cui-data-field-name]")
			df = CUI.dom.data(el, "element")
			# in some case, like "remove", data is already cleaned up
			if not df
				continue
			fields.push(df)
		# console.debug "DataFieldProxy.getFields", search_el, fields
		fields

	remove: ->
		@__detach()
		super()

	__detach: ->
		if not @__element
			return  @

		CUI.Events.ignore
			type: "data-changed"
			node: @__element

		if @__element.DOM
			CUI.dom.remove(@__element.DOM)
		else
			CUI.dom.remove(@__element)
		@__element = null
		@

	destroy: ->
		@__detach()
		super()

	render: ->
		# console.debug "DataFieldsProxy.render", @
		# console.debug "rendering data field proxy", @opts
		if CUI.isFunction(@_element)
			@__element = @_element.call(@, @)
		else
			@__element = @_element
		@replace(@__element)

		# console.debug "DataFieldsProxy.render", @_element, @__element

		# can be used by elements to tell data field proxy
		# that data has changed
		CUI.Events.listen
			type: "data-changed"
			node: @__element
			call:  (ev, info) =>
				# console.debug "caught data changed event on proxy", ev, info
				ev.stopImmediatePropagation()
				info.element = @
				CUI.Events.trigger
					type: "data-changed"
					node: @DOM
					info: info

		super()
		@

	setCheckChangedValue: ->
		# dummy

	initData: ->
		# dummy

DataFieldProxy = CUI.DataFieldProxy