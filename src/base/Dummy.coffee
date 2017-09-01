###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# dummy class so we can use "extend" to mark
# our classes for use in CUI.Element.readOpts
class CUI.Dummy
	constructor: ->
		@__uniqueId = CUI.Dummy.uniqueId++
		@__cls = CUI.util.getObjectClass(@)

	getUniqueId: ->
		@__uniqueId

	@uniqueId: 0

CUI.Dummy