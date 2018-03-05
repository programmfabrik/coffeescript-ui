# All classes are created in the same file to give it read simplicity, but it shouldn't be like this in a real application.

class HelloWorld extends CUI.DOMElement
	constructor: (@opts={}) ->
		super(@opts)

		label = new CUI.Label(text: "Hello World!", centered: true)
		@registerDOMElement(label.DOM)

class HelloWorldTemplate extends CUI.DOMElement

	constructor: (@opts={}) ->
		super(@opts)

		template = new CUI.Template
			name: "hello-world"
			map:
				title: true

		template.append("Hello world", "title")

		@registerTemplate(template)

# Main class
class App
	constructor: ->

		body = new CUI.VerticalLayout
			top:
				content: new HelloWorldTemplate()
			center:
				content: new HelloWorld()

		CUI.dom.append(document.body, body)

CUI.ready ->
	# We need to load the templates first.
	CUI.Template.loadTemplateFile("hello-world.html").done( =>
		new App()
	)