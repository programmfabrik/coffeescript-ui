class CUI.DOMElement extends CUI.Element

	@defaults:
		qa: false

	initOpts: ->
		super()
		@addOpts
			class:
				default: ""
				check: String
			# add a DOM id
			id:
				check: String
			qa:
				check: String
			attr:
				default: {}
				check: "PlainObject"

	registerTemplate: (template, add_default_classes=true) ->
		CUI.util.assert(template instanceof CUI.Template, "#{CUI.util.getObjectClass(@)}.registerDOMElement", "template must be instance of Template but is #{CUI.util.getObjectClass(template)}.", template: template)
		if @__template
			CUI.warn("#{CUI.util.getObjectClass(@)}.registerDOMElement", "Already called before, destroying existing template", template: @__template)
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

		if @_qa and CUI.DOMElement.defaults.qa
			CUI.dom.setAttribute(@DOM, 'data-qa', @_qa)

		@setElement()
		@

	setElement: ->
		@__assertDOMElement('setElement')
		CUI.dom.setElement(@DOM, @)

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

	addClass: (cls) ->
		CUI.util.assert(arguments.length == 1, "CUI.dom.addClass", "Only one parameter allowed.")

		@__assertDOMElement("addClass")
		CUI.dom.addClass(@DOM, cls)

	setAria: (attr, value) ->
		@__assertDOMElement("setAria")
		CUI.dom.setAria(@DOM, attr, value)

	removeClass: (cls) ->
		CUI.util.assert(arguments.length == 1, "CUI.dom.removeClass", "Only one parameter allowed.")

		@__assertDOMElement("removeClass")
		CUI.dom.removeClass(@DOM, cls)

	hide: ->
		@__assertDOMElement("hide")
		CUI.dom.hideElement(@DOM)

	show: ->
		@__assertDOMElement("show")
		CUI.dom.showElement(@DOM)

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
# CUI.Events.ignore(node: @DOM)