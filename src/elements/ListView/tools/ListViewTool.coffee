class ListViewTool
	constructor: (@opts) ->

	registerListView: (@lV) =>
		assert(@lV instanceof ListView, "ListViewTool.registerListView", "Only instance of ListView can be registered", listView: @lV)

	mousemoveEvent: (ev, @info) ->

