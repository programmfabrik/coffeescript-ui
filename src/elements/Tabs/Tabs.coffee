###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Tabs.html'));

class CUI.Tabs extends CUI.SimplePane

	@defaults:
		overflow_button_tooltip: null

	initOpts: ->
		super()
		# @removeOpt("header_right")
		@removeOpt("header_center")
		@removeOpt("content")
		@removeOpt("force_footer")
		@removeOpt("force_header")

		@addOpts
			tabs:
				mandatory: true
				check: (v) ->
					CUI.isArray(v) and v.length > 0
			#autoSizeY:
			#	default: false
			#	check: Boolean
			active_idx:
				check: "Integer"
			appearance:
				check: ["normal", "mini"]
			#header_right: {}
			#footer_right: {}
			#footer_left: {}

	forceHeader: ->
		true

	forceFooter: ->
		true

	__checkOverflowButton: ->
		if not @__maximize_horizontal
			return

		header_dim = DOM.getDimensions(@__header)
		# console.debug "header_dim", header_dim.scrollWidth, header_dim.clientWidth
		if header_dim.scrollWidth > header_dim.clientWidth
			@__overflowBtn.show()
			CUI.DOM.addClass(@__pane_header.DOM, "cui-tabs-pane-header--overflow")
			@__dragscroll = new CUI.Dragscroll
				element: @__buttonbar.DOM
				scroll_element: @__header
		else
			@__dragscroll?.destroy()
			@__dragscroll = null
			@__overflowBtn.hide()
			CUI.DOM.removeClass(@__pane_header.DOM, "cui-tabs-pane-header--overflow")
		@

	__setActiveMarker: ->
		btn = @getActiveTab()?.getButton().DOM[0]

		if not btn
			CUI.DOM.hideElement(@__tabs_marker)
			return

		CUI.DOM.showElement(@__tabs_marker)
		btn_dim = DOM.getDimensions(btn)
		DOM.setStyle @__tabs_marker,
			left: btn_dim.offsetLeft
			width: btn_dim.borderBoxWidth
		@

	init: ->
		super()
		# slider to mark active tab
		@__tabs_marker = CUI.DOM.element("DIV", class: "cui-tabs-active-marker")

		@__tabs_bodies = new Template
			name: "tabs-bodies"

		@__pane_header.addClass("cui-tabs-pane-header")

		if @_appearance == "mini"
			@__pane_header.addClass("cui-tabs-pane-header--mini")

		@__buttonbar = new Buttonbar()

		pane_key = "center"

		@__pane_header.append(@__buttonbar, pane_key)

		@__pane_header.append(@__tabs_marker, pane_key)

		@__header = @__pane_header[pane_key]()[0]

		Events.listen
			type: "scroll"
			node: @__header
			call: (ev) =>
				dim = CUI.DOM.getDimensions(@__header)
				CUI.DOM.setClass(@__pane_header.DOM, "cui-tabs-pane-header--scroll-at-end", dim.horizontalScrollbarAtEnd)
				CUI.DOM.setClass(@__pane_header.DOM, "cui-tabs-pane-header--scroll-at-start", dim.horizontalScrollbarAtStart)

		@__overflowBtn = new Button
			icon: "ellipsis_h"
			class: "cui-tab-header-button-overflow"
			icon_right: false
			size: if @_appearance == "mini" then "mini" else undefined
			tooltip: text: CUI.Tabs.defaults.overflow_button_tooltip
			menu:
				items: =>
					btns = []
					for tab in @__tabs
						do (tab) =>
							btns.push
								text: tab.getText()
								active: tab == @getActiveTab()
								onClick: =>
									tab.activate()
					btns

		@__overflowBtn.hide()

		@__pane_header.prepend(@__overflowBtn, "right")

		@getLayout().append(@__tabs_bodies, "center")

		if @_appearance == "mini"
			@addClass("cui-tabs--mini")

		if not CUI.__ng__
			if not @__maximize_horizontal or not @__maximize_vertical
				Events.listen
					node: @getLayout()
					type: "content-resize"
					call: (event, info) =>
						event.stopPropagation()
						@__doLayout()

			# if not @_footer_left and not @_footer_right
			#       @tabs.map.footer.css("display","none")

		@__tabs = []
		for tab, idx in @_tabs
			if not tab
				continue
			if tab instanceof Tab
				_tab = @addTab(tab)
			else if CUI.isPlainObject(tab)
				_tab = @addTab(new Tab(tab))
			else
				assert(false, "new #{@__cls}", "opts.tabs[#{idx}] must be PlainObject or Tab but is #{getObjectClass(tab)}", opts: @opts)
			if @_appearance == "mini"
				_tab.getButton().setSize("mini")

		@__tabs[@_active_idx or 0].activate()

		DOM.waitForDOMInsert(node: @getLayout())
		.done =>
			if @isDestroyed()
				return

			Events.listen
				node: @getLayout()
				type: "viewport-resize"
				call: =>
					@__checkOverflowButton()
					@__setActiveMarker()

			assert( DOM.isInDOM(@getLayout().DOM[0]),"Tabs getting DOM insert event without being in DOM." )
			@__checkOverflowButton()
			@__setActiveMarker()

			if not CUI.__ng__
				@__doLayout()

		@addClass("cui-tabs")

		@__max_width = -1
		@__max_height = -1
		@

	setFooterRight: (content) ->
		# @tabs.map.footer.css("display","")
		@replace(content, "footer_right")

	setFooterLeft: (content) ->
		# @tabs.map.footer.css("display","")
		@replace(content, "footer_left")

	__doLayout: ->
		if @__maximize_horizontal and @__maximize_vertical
			return

		if @__measureAndSetBodyWidth()
			# size has changed
			Events.trigger
				type: "content-resize"
				node: @DOM.parentNode
		@

	addTab: (tab) ->
		assert(tab instanceof Tab, "#{@__cls}.addTab", "Tab must be instance of Tab but is #{getObjectClass(tab)}", tab: tab)
		if not @hasTab(tab)
			@__tabs.push(tab)
			Events.listen
				node: tab
				type: "tab_activate"
				call: =>

					if @__overflowBtn.isShown()
						DOM.scrollIntoView(tab.getButton().DOM[0])

					if CUI.__ng__
						if not @_maximize_vertical
							# set left margin on first tab
							# console.debug "style", @__tabs[0].DOM[0], -100*idxInArray(tab, @__tabs)+"%"
							DOM.setStyle(@__tabs[0].DOM[0], marginLeft: -100*idxInArray(tab, @__tabs)+"%")

					@__active_tab = tab
					@__setActiveMarker()

					DOM.setAttribute(@DOM[0], "active-tab-idx", idxInArray(tab, @__tabs))
					# CUI.error @__uniqueId, "activate"

			Events.listen
				node: tab
				type: "tab_deactivate"
				call: =>
					# CUI.error @__uniqueId, "deactivate"
					@__active_tab = null
					DOM.setAttribute(@DOM[0], "active-tab-idx", "")

			Events.listen
				node: tab
				type: "tab_destroy"
				call: =>
					idx = @__tabs.indexOf(tab)
					removeFromArray(tab, @__tabs)
					idx--
					@__tabs[idx]?.activate()


		tab.hide()
		tab.initButton(@)
		@__buttonbar.addButton(tab.getButton())
		CUI.DOM.append(@__tabs_bodies, tab)
		tab


	__measureAndSetBodyWidth: ->

		for parent in CUI.DOM.parents(@DOM)
			if parent.scrollTop or parent.scrollLeft
				scrollSaveParent =
						node: parent
						top: parent.scrollTop
						left: parent.scrollLeft
				break

		# measure and set body
		#

		# remove previously set dimensions
		for tab in @__tabs
			CUI.DOM.setStyle(tab.getBody(), 
				"min-width": "", 
				"height": ""
			)

		CUI.DOM.setStyle(@__tabs_bodies.DOM,
			"min-width": "", 
			"height": ""
		)

		# measure
		max_width = -1
		max_height = -1

		for tab in @__tabs
			dim =
				width: tab.getBody().outerWidth(true)
				height: tab.getBody().outerHeight(true)

			if dim.width > max_width
				max_width = dim.width
			if dim.height > max_height
				max_height = dim.height

		CUI.DOM.setStyle(@__tabs_bodies.DOM,
			"min-width": max_width, 
			"height": max_height
		)

		for tab in @__tabs
			CUI.DOM.setStyle(tab.getBody(),
				"min-width": max_width, 
				height: max_height
			)

		if @max_width != @__max_width or @max_height != @__max_height
			@__max_width = max_width
			@__max_height = max_height

			size_has_changed = true
		else
			size_has_changed = false

		# set back scroll position
		if scrollSaveParent
			scrollSaveParent.node.scrollTop = scrollSaveParent.top
			scrollSaveParent.node.scrollLeft = scrollSaveParent.left

		return size_has_changed


	# true or false if a tab exists
	hasTab: (tab_or_idx_or_name) ->
		@getTab(tab_or_idx_or_name)

	getTab: (tab_or_idx_or_name) ->
		found_tab = null
		# CUI.debug tab_or_idx_or_name, @, @__tabs.length
		if isString(tab_or_idx_or_name)
			for tab in @__tabs
				# CUI.debug tab._name, tab_or_idx_or_name
				if tab._name == tab_or_idx_or_name
					found_tab = tab
					break
		else if tab_or_idx_or_name instanceof Tab
			if @__tabs.indexOf(tab_or_idx_or_name) > -1
				found_tab = tab_or_idx_or_name
		else
			found_tab = @__tabs[tab_or_idx_or_name]

		return found_tab

	getActiveTab: ->
		@__active_tab

	activate: (tab_or_idx_or_name) ->
		tab = @getTab(tab_or_idx_or_name)
		tab.activate()
		@
