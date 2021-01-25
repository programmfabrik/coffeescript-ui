###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###


class Demo.BlockDemo extends Demo

	display: ->

		@demo_table = new Demo.DemoTable()

		@demo_table.addDivider("blocks")

		@demo_table.addExample("Blocks", @createBlocks() )
		@demo_table.addExample("Blocks with line separator mixin", @createSimpleBlocks("cui-block-demo-separator") )

		@createWaitBlockExample()


		@demo_table.table

	createSimpleBlocks: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Title of block A"
						content: [
							new CUI.Label
								text: "content of main block"

						],
					new CUI.Block
						text: "Title of block B"
						content: [
							new CUI.Label
								text: "content of main block"

						],
					new CUI.Block
						text: "Title of block C"
						content: [
							new CUI.Label
								text: "content of main block"

						]

				]
		list.DOM


	createWaitBlockExample: ->
		@__wait_block_container = CUI.dom.div("cui-waiting-block-demo")

		CUI.dom.append(@__wait_block_container, new CUI.Label(text: "Is it worth waiting?").DOM)

		#make sure __wait_block_container has position: relative or absolute in its style! otherwise waitblock gets fullscreen
		wait_block = new CUI.WaitBlock
			element: @__wait_block_container
			text: "I think you should wait..."

		controls = [
			new CUI.Buttonbar
				buttons: [
					new CUI.Button
						text: "Wait"
						switch: true
						onActivate: ->
							wait_block.show()
						onDeactivate: ->
							wait_block.hide()
				]
			.DOM
		]

		@demo_table.addExample("Wait Block", [controls, @__wait_block_container])


	createBlocks: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Title of main block"
						appearance: "title"
						content: [
							new CUI.Label
								text: "content of main block"
							new CUI.Block
								text: "Subtitle of main block"
								level: 2
								content: [
									new CUI.Label
										text: "content of subtitle block"
									new CUI.Block
										text: "normal block header"
										level: 3
										content: [
											new CUI.Label
												text: "content of normal block."
										]
								]
							new CUI.Block
								text: "2nd Subtitle of main block"
								level: 2
								content: [
									new CUI.Label
										text: "content of subtitle block"
									new CUI.Block
										level: 3
										text: "normal block header"
										content: [
											new CUI.Label
												text: "content of normal block."
										]
									new CUI.Block
										text: "2nd normal block header"
										level: 3
										content: [
											new CUI.Label
												text: "content of normal block."
										]
								]

						]
				]
		list.DOM


Demo.register(new Demo.BlockDemo())