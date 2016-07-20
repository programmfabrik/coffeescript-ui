
class BlockDemo extends Demo

    display: ->
        
        @demo_table = new DemoTable()

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
                        appearance: "title"
                        content: [
                            new Label
                                text: "content of main block"

                        ],
                    new Block
                        text: "Title of block B"
                        appearance: "title"
                        content: [
                            new Label
                                text: "content of main block"

                        ],
                    new Block
                        text: "Title of block C"
                        appearance: "title"
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
                                appearance: "subtitle"
                                content: [
                                    new Label
                                        text: "content of subtitle block"
                                    new Block
                                        text: "normal block header"
                                        appearance: "normal"
                                        content: [
                                            new Label
                                                text: "content of normal block."
                                        ]
                                ]
                            new Block
                                text: "2nd Subtitle of main block"
                                appearance: "subtitle"
                                content: [
                                    new Label
                                        text: "content of subtitle block"
                                    new Block
                                        text: "normal block header"
                                        appearance: "normal"
                                        content: [
                                            new Label
                                                text: "content of normal block."
                                        ]
                                    new Block
                                        text: "2nd normal block header"
                                        appearance: "normal"
                                        content: [
                                            new Label
                                                text: "content of normal block."
                                        ]
                                ]

                        ]
                ]
        list.DOM
        

Demo.register(new BlockDemo())