###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###


class Demo.BlockDemo extends Demo

	display: ->

		@demo_table = new Demo.DemoTable()

		@demo_table.addDivider("blocks and sections")

		@demo_table.addExample("Section block", @createBlocks() )
		@demo_table.addExample("Section block with line separator mixin", @createSimpleBlocks("cui-demo-block-separator") )
		@demo_table.addExample("Section block 'inline'", @createSimpleBlocksWide() )
		@demo_table.addExample("Section block 'base config'", @createSectionBlockBaseConfig() )
		@demo_table.addExample("Bracket block in Editor only", @createBlockBracket() )

		@createWaitBlockExample()

		@demo_table.table

	createSimpleBlocks: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Title of block A1"
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


	createSimpleBlocksWide: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Wide block A"
						appearance: "wide"
						class: "cui-demo-block-grid"
						level: 1
						content: [
							new CUI.Label
								text: "content of main block"

						],
					new CUI.Block
						text: "Wide block B"
						appearance: "wide"
						class: "cui-demo-block-grid"
						level: 2
						content: [
							new CUI.Label
								text: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
								multiline: true

						],
					new CUI.Block
						text: "Wide block C"
						appearance: "wide"
						class: "cui-demo-block-grid"
						level: 2
						content: [
							new CUI.Label
								text: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
								multiline: true

						]

				]
		list.DOM


	createSectionBlockBaseConfig: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Admin"
						class: "cui-demo-block-base-config"
						level: 1
						content: [
							new CUI.Label
								text: "content of main block"

						],
					new CUI.Block
						text: "Some options"
						class: "cui-demo-block-base-config"
						level: 2
						content: [
							new CUI.Label
								text: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
								multiline: true
						],
					new CUI.Block
						text: "Configuration options"
						class: "cui-demo-block-base-config"
						level: 2
						content: [
							new CUI.Label
								text: "content of main block"

						]

				]
		list.DOM

	
	createBlockBracket: (style_class= "") ->

		list = new CUI.VerticalList
			maximize: true
			class: style_class
			content:
				[
					new CUI.Block
						text: "Fields in a Block"
						class: "cui-demo-block-bracket"
						level: 1
						content: [
							new CUI.Label
								text: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
								multiline: true
						],
					new CUI.Block
						text: "Other Fields in a Block"
						class: "cui-demo-block-bracket"
						level: 1
						content: [
							new CUI.Label
								text: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
								multiline: true
						],
					new CUI.Block
						text: "And even more Fields"
						class: "cui-demo-block-bracket"
						level: 1
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
						text: "Title of main block (level 1)"
						appearance: "normal"
						description: "Some sort of block description text"
						content: [
							new CUI.Label
								text: "content of main block"
							new CUI.Block
								text: "Subtitle of main block (level 2)"
								level: 2
								content: [
									new CUI.Label
										text: "content of subtitle block"
									new CUI.Block
										text: "normal block header (level 3)"
										level: 3
										content: [
											new CUI.Label
												text: "content of normal block."
										]
								]
							new CUI.Block
								text: "2nd Subtitle of main block (level 2)"
								level: 2
								content: [
									new CUI.Label
										text: "content of subtitle block"
									new CUI.Block
										level: 3
										text: "normal block header (level 3)"
										content: [
											new CUI.Label
												text: "content of normal block."
										]
									new CUI.Block
										text: "2nd normal block header (level 3)"
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
