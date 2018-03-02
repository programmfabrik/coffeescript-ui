CUI.ready =>
	examples = ["vertical-layout", "horizontal-layout", "border-layout", "vertical-horizontal-list", "layout-complete", "form", "button", "pane"]
	exampleLinks = examples.forEach((example) =>
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

	CUI.dom.append(document.body, exampleLinks)