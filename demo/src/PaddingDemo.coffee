
class PaddingDemo extends Demo

    getName: () ->
        "Padding"

    display: ->

        @demo_table = new DemoTable("cui-padding-demo")

        @demo_table.addDivider("Horizontal padding examples")

        layout =
            new HorizontalLayout
                maximize: false
                class: "cui-padding-outer-bigger"
                left:
                    content: new Label( text: "1" )
                center:
                    content: new Label( text: "2" )
                right:
                    content: [
                        new HorizontalLayout
                            maximize: false
                            left:
                                content: new Label( text: "3.1" )
                            center:
                                content: new Label( text: "3.2" )
                            right:
                                content: new Label( text: "3.3 Reset", class: "pad-reset" )
                    ]
        @demo_table.addExample("cui-padding-outer-bigger", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout =
            new HorizontalLayout
                maximize: false
                class: "cui-padding-outer-bigger"
                left:
                    content: new Label( text: "1" )
                center:
                    content: new Label( text: "2" )
                right:
                    content: [
                        new HorizontalLayout
                            maximize: false
                            left:
                                content: new Label( text: "3.1" )
                            center:
                                content: new Label( text: "3.2" )
                    ]
        @demo_table.addExample("cui-padding-outer-bigger", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            maximize: false
            class: "cui-padding-outer-bigger"
            left:
                content: new Label( text: "1" )
            center:
                content: new Label( text: "2" )
            right:
                content: [
                    new HorizontalLayout
                        maximize: false
#                        class: "cui-padding-outer-big"
#                        left:
#                            content: new Label( text: "3.1" )
                        center:
                            content: new Label( text: "3.1" )
#                        right:
#                            content: new Label( text: "3.3" )
                ]
        @demo_table.addExample("cui-padding-outer-bigger", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            maximize: false

            left:
                content: new Label( text: "1" )
            center:
                content: new Label( text: "2" )
            right:
                content: [
                    new HorizontalLayout
                        maximize: false
                        class: "cui-padding-outer-bigger"
#                        left:
#                            content: new Label( text: "3.1" )
                        center:
                            content: new Label( text: "3.1" )
#                        right:
#                            content: new Label( text: "3.3" )
                ]
        @demo_table.addExample("nested cui-padding-outer-bigger ", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            maximize: false
            class: "cui-padding-outer-bigger"
            left:
                content: new Label( text: "1" )
            center:
                content: new Label( text: "2" )
            right:
                content: [
                    new HorizontalLayout
                        maximize: false
                        class: "cui-padding-outer-big"
#                        left:
#                            content: new Label( text: "3.1" )
                        center:
                            content: [
                                new HorizontalLayout
                                    maximize: false
#class: "cui-padding-outer-big"
                                    center:
                                        content: new Label( text: "3.1.1" )
                            ]
#                        right:
#                            content: new Label( text: "3.3" )
                ]
        @demo_table.addExample("outer big inside outer bigger padding", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            maximize: false
            class: "cui-padding-outer-bigger"
            left:
                content: new Label( text: "1" )
            center:
                content: [
                    new HorizontalLayout
                        maximize: false
                        class: "cui-padding-outer-big"
#                        left:
#                            content: new Label( text: "3.1" )
                        center:
                            content: [
                                new HorizontalLayout
                                    maximize: false
#class: "cui-padding-outer-big"
                                    center:
                                        content: new Label( text: "2.1.1" )
                            ]
#                        right:
#                            content: new Label( text: "3.3" )
                ]
            right:
                content: new Label( text: "3" )
        @demo_table.addExample("outer big inside outer bigger padding", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            class: "cui-padding-outer-bigger"
            maximize: false
            center:
                content: new Label( text: "1" )
        @demo_table.addExample("cui-padding-outer-bigger, one cell", $div("cui-padding-demo-reset-width").append(layout.DOM) )


        layout = new HorizontalLayout
            class: "cui-padding-outer-bigger"
            maximize: false
            center:
                content: [
                    new HorizontalLayout
                        maximize: false
                        center:
                            content: new Label( text: "1.1" )
                ]
        @demo_table.addExample("cui-padding-outer-bigger, one cell", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            class: "cui-padding-outer-bigger"
            maximize: false
            left:
                content: new Label( text: "1" )
            center:
                content: [
                    new HorizontalLayout
                        maximize: false
                        left:
                            content: new Label( text: "2.1" )
                        center:
                            content: [
                                new HorizontalLayout
                                    maximize: false
                                    left:
                                        content: new Label( text: "2.1.1" )
                                    center:
                                        content: new Label( text: "2.1.2" )
                            ]
                ]
            right:
                content: new Label( text: "3" )

        @demo_table.addExample("cui-padding-outer-bigger, one cell", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            class: "cui-padding-outer-bigger"
            maximize: false
            left:
                content: new Label( text: "1" )
            center:
                content: [
                    new HorizontalLayout
                        maximize: false
                        left:
                            content: new Label( text: "2.1" )
                        center:
                            content: [
                                new HorizontalLayout
                                    maximize: false
                                    left:
                                        content: new Label( text: "2.1.1" )
                                    center:
                                        content: [
                                            new HorizontalLayout
                                                maximize: false
                                                left:
                                                    content: new Label( text: "2.1.2.1" )
                                                center:
                                                    content: new Label( text: "2.1.2.1" )
                                        ]
                            ]
                ]
            right:
                content: new Label( text: "3" )

        @demo_table.addExample("cui-padding-outer-bigger, one cell", $div("cui-padding-demo-reset-width").append(layout.DOM) )

        layout = new HorizontalLayout
            class: "cui-padding-outer-bigger"
            absolute: true
            maximize: true
            left:
                content: new Label( text: "1" )
            center:
                content: new Label( text: "2" )
            right:
                content: new Label( text: "3" )
        @demo_table.addExample("cui-padding-outer-bigger, absolute", $div("cui-padding-demo-reset-width").append(layout.DOM) )


        # ========================================================================================================================================

        @demo_table.addDivider("Horizontal list")

        layout = new HorizontalList
            class: "cui-padding-outer-bigger"
            maximize: false
            content: [
                new Label( text: "1" )
                new Label( text: "2" )
                new Label( text: "3" )
                new Label( text: "4" )
            ]

        @demo_table.addExample("cui-padding-outer-bigger, one cell", $div("cui-padding-demo-reset-width").append(layout.DOM) )



        @demo_table.table


Demo.register(new PaddingDemo())
