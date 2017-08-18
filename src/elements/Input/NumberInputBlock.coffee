###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.NumberInputBlock extends CUI.InputBlock

	incrementBlock: (block, blocks) ->
		@__changeBlock(block, blocks, 1)

	decrementBlock: (block, blocks) ->
		@__changeBlock(block, blocks, -1)

	__changeBlock: (block, blocks, diff) ->
		number = parseInt(@__string)
		nn = (""+(number+diff)).split("")
		# while nn.length < match_len
		#	nn.splice(0, 0, "0")
		block.setString(nn.join(""))
