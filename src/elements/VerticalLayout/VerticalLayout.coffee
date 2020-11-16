###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./VerticalLayout.html'));

class CUI.VerticalLayout extends CUI.Layout

	# @return [String] css name of this class , excluding namespace prefix
	getName: ->
		if @hasFlexHandles()
			return "vertical-layout"

		panes = @getPanes()
		# console.debug CUI.util.getObjectClass(@)+".getPanes: ",panes
		if panes.length == 2
			"vertical-layout-top-center-bottom"
		else if "top" in panes
			"vertical-layout-top-center"
		else if "bottom" in panes
			"vertical-layout-center-bottom"
		else
			"vertical-layout-center"

	getMapPrefix: ->
		"cui-vertical-layout"

	hasFlexHandles: ->
		if @_top?.flexHandle or @_bottom?.flexHandle
			return true
		false

	# @return [Array] the first and last pane name of this 3 pane layout
	getPanes: ->
		if @hasFlexHandles()
			return ["top", "bottom"]

		panes = []
		if @_top
			panes.push("top")
		if @_bottom
			panes.push("bottom")
		panes

	getSupportedPanes: ->
		["top", "bottom"]

