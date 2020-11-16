###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./HorizontalLayout.html'));

class CUI.HorizontalLayout extends CUI.Layout

	# @return [String] css name of this class , excluding namespace prefix
	getName: ->
		if @hasFlexHandles()
			return "horizontal-layout"

		panes = @getPanes()

		if panes.length == 2
			"horizontal-layout-left-center-right"
		else if "left" in panes
			"horizontal-layout-left-center"
		else if "right" in panes
			"horizontal-layout-center-right"
		else
			"horizontal-layout-center"

	getMapPrefix: ->
		"cui-horizontal-layout"

	hasFlexHandles: ->
		if @_left?.flexHandle or @_right?.flexHandle
			return true
		false

	# @return [Array] the first and last pane name of this 3 pane layout
	getPanes: ->
		if @hasFlexHandles()
			return ["left", "right"]

		panes = []
		if @_left
			panes.push("left")
		if @_right
			panes.push("right")
		panes

	getSupportedPanes: ->
		["left", "right"]
