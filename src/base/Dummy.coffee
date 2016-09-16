# dummy class so we can use "extend" to mark
# our classes for use in CUI.Element.readOpts
class CUI.Dummy
	constructor: ->
		@__uniqueId = CUI.Dummy.uniqueId++
		@__cls = getObjectClass(@)

	getUniqueId: ->
		@__uniqueId

	@uniqueId: 0

CUI.Dummy