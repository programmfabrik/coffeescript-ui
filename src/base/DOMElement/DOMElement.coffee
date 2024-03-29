class CUI.DOMElement extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			class:
				default: ""
				check: String
			# add a DOM id
			id:
				check: String
			ui:
				check: String
			attr:
				check: "PlainObject"

	registerTemplate: (template, add_default_classes=true) ->
		CUI.util.assert(template instanceof CUI.Template, "#{CUI.util.getObjectClass(@)}.registerDOMElement", "template must be instance of Template but is #{CUI.util.getObjectClass(template)}.", template: template)
		if @__template
			console.warn("#{CUI.util.getObjectClass(@)}.registerDO MElement", "Already called before, destroying existing template", template: @__template)
			@__template.destroy()
		@__template = template
		@registerDOMElement(@__template.DOM, add_default_classes)

	getDOMElementClasses: ->
		return 'cui-'+CUI.util.toDash(@__cls)

	registerDOMElement: (@DOM, add_default_classes=true) ->

		if add_default_classes
			CUI.dom.addClass(@DOM, @getDOMElementClasses())

		if @_attr
			CUI.dom.setAttributeMap(@DOM, @_attr)

		if @_id
			CUI.dom.setAttribute(@DOM, 'id', @_id)

		if @_class
			CUI.dom.addClass(@DOM, @_class)

		if @_ui
			CUI.dom.setAttribute(@DOM, 'ui', @_ui)

		CUI.dom.data(@DOM, "element", @)
		@

	# if used as parameter in "Layer", overwrite to
	# a different element to position the layer with
	getElementForLayer: ->
		@DOM

	unregisterDOMElement: ->
		CUI.dom.removeClass(@DOM, @getDOMElementClasses())
		CUI.dom.removeAttribute(@DOM, "id")
		if @_class
			CUI.dom.removeClass(@DOM, @_class)
		CUI.dom.removeData(@DOM, "element")
		delete(@DOM)
		@

	__assertDOMElement: (func) ->
		CUI.util.assert(@DOM, "#{@__cls}.#{func}", "registerDOMElement needs to be called before \"#{func}\" is supported.")

	__assertTemplateElement: (func) ->
		CUI.util.assert(@__template, "#{@__cls}.#{func}", "registerTemplateElement needs to be called before \"#{func}\" is supported.")

	addClass: (className, key) ->
		CUI.util.assert(arguments.length == 1 or arguments.length == 2, "addClass", "Only 'className' and 'key' parameters are allowed.")
		if key
			@__assertTemplateElement("addClass")
			@__template.addClass.call(@__template, className, key, @)
		else
			@__assertDOMElement("addClass")
			CUI.dom.addClass(@DOM, className)

	setAria: (attr, value) ->
		@__assertDOMElement("setAria")
		CUI.dom.setAria(@DOM, attr, value)

	removeClass: (className, key) ->
		CUI.util.assert(arguments.length == 1 or arguments.length == 2, "removeClass", "Only 'className' and 'key' parameters are allowed.")
		if key
			@__assertTemplateElement("removeClass")
			@__template.removeClass.call(@__template, className, key, @)
		else
			@__assertDOMElement("removeClass")
			CUI.dom.removeClass(@DOM, className)

	hide: (key) ->
		if CUI.util.isEmpty(key)
			@__assertDOMElement("hide")
			CUI.dom.hideElement(@DOM)
		else
			@__assertTemplateElement("hide")
			@__template.hide.call(@__template, key)

	show: (key) ->
		if CUI.util.isEmpty(key)
			@__assertDOMElement("show")
			CUI.dom.showElement(@DOM)
		else
			@__assertTemplateElement("show")
			@__template.show.call(@__template, key)

	showWaitBlock: ->
		@__assertDOMElement("showWaitBlock")
		@__wb = new CUI.WaitBlock
			element: @DOM
		.show()
		@

	hideWaitBlock: ->
		@__wb.destroy()
		delete(@__wb)
		@

	hasClass: (cls) ->
		CUI.util.assert(arguments.length == 1, "CUI.dom.hasClass", "Only one parameter allowed.")
		@__assertDOMElement("hasClass")
		CUI.dom.hasClass(@DOM, cls)

	isDestroyed: (key) ->
		@__template?.isDestroyed.call(@__template, key)

	empty: (key) ->
		@__assertTemplateElement("empty")
		@__template.empty.call(@__template, key)

	replace: (value, key) ->
		@__assertTemplateElement("replace")
		@__template.replace.call(@__template, value, key, @)

	append: (value, key) ->
		@__assertTemplateElement("append")
		@__template.append.call(@__template, value, key, @)

	prepend: (value, key) ->
		@__assertTemplateElement("prepend")
		@__template.prepend.call(@__template, value, key, @)

	text: (value, key) ->
		@__assertTemplateElement("text")
		@__template.text.call(@__template, value, key, @)

	get: (key) ->
		@__assertTemplateElement("get")
		@__template.get.call(@__template, key, @)

	getFlexHandle: (key, do_assert) ->
		@__assertTemplateElement("getFlexHandle")
		@__template.getFlexHandle.call(@__template, key, do_assert)

	destroy: ->
	# we need to set "isDestroyed" first, so
		super()
		if @__template
			@__template?.destroy()
		else if @DOM
			CUI.dom.remove(@DOM)
		@