###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./StickyHeader.html'));

class CUI.StickyHeader extends CUI.DOMElement
	constructor: (opts) ->
		super(opts)

		@header = new CUI.Template
			name: "sticky-header"
			map:
				center: true

		@registerTemplate(@header)

		@addClass("cui-sticky-header-level-#{@_level}")
		if not CUI.util.isEmpty(@_text)
			@replace(CUI.dom.text(@_text), "center")
		else
			@replace(@_content, "center")

		# @_control.addStickyHeader(@)

		# el = document.querySelector(@)

		# todo:
		# level-1 / level-2 probably need a rootMargin of their respective "top" value ??

		@intersectionCallback = (entries) =>
			entries.forEach((entry) =>
				# console.log("entry.isIntersecting:", entry.isIntersecting)
				# console.log("entry.boundingClientRect.top:" , entry.boundingClientRect.top)
				# console.log("entry.intersectionRatio:" , entry.intersectionRatio)
				# console.log("entry.rootBounds:" , entry.rootBounds)

				if entry.boundingClientRect.top < entry.rootBounds.top
					entry.target.classList.add("is-stuck")
				else
					entry.target.classList.remove("is-stuck")
			)
		
		observer = new IntersectionObserver( 
			@intersectionCallback,				
			{ 
				root: @_parent,
				threshold: [1] 
			}
		)

		observer.observe(@DOM)

	initOpts: ->
		super()
		@addOpts
			control:
				mandatory: true
				check: CUI.StickyHeaderControl
			parent: {} #todo: we nned the parent container
			text:
				check: String
			content: {}
			level:
				default: 0
				check: (v) ->
					v == 0 or v == 1 or v == 2


	getLevel: ->
		@_level


