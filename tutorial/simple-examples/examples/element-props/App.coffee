# All classes are created in the same file to give it read simplicity, but it shouldn't be like this in a real application.
class MyElement extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			title:
				default: "Default title"
				check: String
			year:
				check: "Integer"
				mandatory: true
			show:
				check: Boolean
			size:
				check: ["small", "big"]
				default: "small"
			number:
				default: 50
				check: (value) =>
					value > 10 && value < 100

	dump: ->
		data =
			title: @_title
			year: @_year
			size: @_size
			number: @_number

		if @_show
			return CUI.util.dump(data)
		else
			return "Show attribute is false"


class App
	constructor: ->

		myElement = new MyElement(
			year: 2018
			show: true
			size: "big"
		)

		myElementTwo = new MyElement(
			year: 1991
			show: false
			size: "small"
		)

		body = new CUI.VerticalLayout
			top:
				content: myElement.dump()
			center:
				content: myElementTwo.dump()

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()