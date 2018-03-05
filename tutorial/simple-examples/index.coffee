CUI.ready =>
	examples = ["vertical-layout", "horizontal-layout", "border-layout", "vertical-horizontal-list",
		"layout-complete", "form", "button", "pane", "icon", "modal", "custom-element", "element-props"]
	exampleLinks = examples.map((example) =>
		new CUI.ButtonHref
			href: "examples/#{example}/index.html"
			appearance: "link"
			text: example
	)

	exampleLinks.push(new CUI.ButtonHref
		href: "https://programmfabrik.github.io/coffeescript-ui-demo/public/index.html"
		appearance: "link"
		text: "Demo"
	)

	body = new CUI.VerticalLayout
		center:
			content: new CUI.Pane
				auto_buttonbar: false
				padded: true
				center:
					content: exampleLinks

	CUI.dom.append(document.body, body)