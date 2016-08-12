
class BlockDemo extends Demo

	display: ->

		@demo_table = new DemoTable()

		@demo_table.addDivider("blocks")

		@demo_table.addExample("Blocks", @createBlocks() )
		@demo_table.addExample("Blocks with line separator mixin", @createSimpleBlocks("cui-block-demo-separator") )

		@demo_table.table

	createSimpleBlocks: (style_class= "") ->

		list = new VerticalList
			maximize: true
			class: style_class
			content:
				[
					new Block
						text: "Title of block A"
						content: [
							new Label
								text: "content of main block"

						],
					new Block
						text: "Title of block B"
						content: [
							new Label
								text: "content of main block"

						],
					new Block
						text: "Title of block C"
						content: [
							new Label
								text: "content of main block"

						]

				]
		list.DOM


	createBlocks: (style_class= "") ->

		list = new VerticalList
			maximize: true
			class: style_class
			content:
				[
					new Block
						text: "Title of main block"
						appearance: "title"
						content: [
							new Label
								text: "content of main block"
							new Block
								text: "Subtitle of main block"
								level: 2
								content: [
									new Label
										text: "content of subtitle block"
									new Block
										text: "normal block header"
										level: 3
										content: [
											new Label
												text: "content of normal block."
										]
								]
							new Block
								text: "2nd Subtitle of main block"
								level: 2
								content: [
									new Label
										text: "content of subtitle block"
									new Block
										level: 3
										text: "normal block header"
										content: [
											new Label
												text: "content of normal block."
										]
									new Block
										text: "2nd normal block header"
										level: 3
										content: [
											new Label
												text: "content of normal block."
										]
								]

						]
				]
		list.DOM


Demo.register(new BlockDemo())