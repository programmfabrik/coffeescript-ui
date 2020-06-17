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
					CUI.util.isArray(v) and v.length > 0
			#autoSizeY:
			#	default: false
			#	check: Boolean
			active_idx:
				check: 'Integer'
			appearance:
				check: ['normal', 'mini']
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

		header_dim = CUI.dom.getDimensions(@__header)
		# console.debug "header_dim", header_dim.scrollWidth, header_dim.clientWidth
		if header_dim.scrollWidth > header_dim.clientWidth
			@__overflowBtn.show()
			CUI.dom.addClass(@__pane_header.DOM, "cui-tabs-pane-header--overflow")
			@__dragscroll = new CUI.Dragscroll
				element: @__buttonbar.DOM
				scroll_element: @__header
		else
			@__dragscroll?.destroy()
			@__dragscroll = null
			@__overflowBtn.hide()
			CUI.dom.removeClass(@__pane_header.DOM, "cui-tabs-pane-header--overflow")
		@

	init: ->
		super()

		@__tabs_bodies = new CUI.Template
			name: "tabs-bodies"

		CUI.dom.addClass(@__pane_header.DOM, "cui-tabs-pane-header")

		if @_appearance == 'mini'
			CUI.dom.addClass(@__pane_header.DOM, "cui-tabs-pane-header--mini")

		@removeClass('cui-pane--padded')

		if @_padded
			@addClass('cui-tabs--padded')

		@__buttonbar = new CUI.Buttonbar()

		pane_key = "center"

		@__pane_header.append(@__buttonbar, pane_key)

		@__header = @__pane_header[pane_key]()

		CUI.Events.listen
			type: "scroll"
			node: @__header
			call: (ev) =>
				dim = CUI.dom.getDimensions(@__header)
				CUI.dom.setClass(@__pane_header.DOM, "cui-tabs-pane-header--scroll-at-end", dim.horizontalScrollbarAtEnd)
				CUI.dom.setClass(@__pane_header.DOM, "cui-tabs-pane-header--scroll-at-start", dim.horizontalScrollbarAtStart)

		@__overflowBtn = new CUI.Button
			icon: "ellipsis_h"
			class: "cui-tab-header-button-overflow"
			appearance: "flat"
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

		@__tabs = []
		for tab, idx in @_tabs
			if not tab
				continue
			if tab instanceof CUI.Tab
				_tab = @addTab(tab)
			else if CUI.util.isPlainObject(tab)
				_tab = @addTab(new CUI.Tab(tab))
			else
				CUI.util.assert(false, "new #{@__cls}", "opts.tabs[#{idx}] must be PlainObject or Tab but is #{CUI.util.getObjectClass(tab)}", opts: @opts)
			if @_appearance == "mini"
				_tab.getButton().setSize("mini")

		@__tabs[@_active_idx or 0].activate()

		CUI.dom.waitForDOMInsert(node: @getLayout())
		.done =>
			if @isDestroyed()
				return

			CUI.Events.listen
				node: @getLayout()
				type: "viewport-resize"
				call: =>
					@__checkOverflowButton()

			CUI.util.assert( CUI.dom.isInDOM(@getLayout().DOM),"Tabs getting DOM insert event without being in DOM." )
			@__checkOverflowButton()

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


	addTab: (tab) ->
		CUI.util.assert(tab instanceof CUI.Tab, "#{@__cls}.addTab", "Tab must be instance of Tab but is #{CUI.util.getObjectClass(tab)}", tab: tab)
		if not @hasTab(tab)
			@__tabs.push(tab)
			CUI.Events.listen
				node: tab
				type: "tab_activate"
				call: =>

					if @__overflowBtn.isShown()
						CUI.dom.scrollIntoView(tab.getButton().DOM)

					if CUI.__ng__
						if not @_maximize_vertical
							# set left margin on first tab
							# console.debug "style", @__tabs[0].DOM[0], -100*CUI.util.idxInArray(tab, @__tabs)+"%"
							CUI.dom.setStyle(@__tabs[0].DOM, marginLeft: -100*CUI.util.idxInArray(tab, @__tabs)+"%")

					@__active_tab = tab

					CUI.dom.setAttribute(@DOM, "active-tab-idx", CUI.util.idxInArray(tab, @__tabs))
					# console.error @__uniqueId, "activate"

			CUI.Events.listen
				node: tab
				type: "tab_deactivate"
				call: =>
					# console.error @__uniqueId, "deactivate"
					@__active_tab = null
					CUI.dom.setAttribute(@DOM, "active-tab-idx", "")

			CUI.Events.listen
				node: tab
				type: "tab_destroy"
				call: =>
					idx = @__tabs.indexOf(tab)
					CUI.util.removeFromArray(tab, @__tabs)
					idx--
					@__tabs[idx]?.activate()

		tab_padded = tab.getSetOpt("padded")

		if (tab_padded != false and @_padded) or
			(tab_padded == true)
				tab.addClass("cui-tab--padded")

		tab.hide()
		tab.initButton(@)
		@__buttonbar.addButton(tab.getButton())
		@__tabs_bodies.append(tab)
		tab

	# true or false if a tab exists
	hasTab: (tab_or_idx_or_name) ->
		@getTab(tab_or_idx_or_name)

	getTab: (tab_or_idx_or_name) ->
		found_tab = null
		# console.debug tab_or_idx_or_name, @, @__tabs.length
		if CUI.util.isString(tab_or_idx_or_name)
			for tab in @__tabs
				# console.debug tab._name, tab_or_idx_or_name
				if tab._name == tab_or_idx_or_name
					found_tab = tab
					break
		else if tab_or_idx_or_name instanceof CUI.Tab
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

	destroy: ->
		while @__tabs.length > 0
			# Tab destroy triggers 'tab_destroy' event which makes the tab to be removed from the array.
			@__tabs[0].destroy()
		super()
