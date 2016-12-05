###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ListViewTool extends CUI.Element

	registerListView: (@lV) =>
		assert(@lV instanceof ListView, "ListViewTool.registerListView", "Only instance of ListView can be registered", listView: @lV)

	mousemoveEvent: (ev, @info) ->

