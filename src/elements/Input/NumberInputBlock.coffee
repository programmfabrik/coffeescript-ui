class NumberInputBlock extends InputBlock

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
