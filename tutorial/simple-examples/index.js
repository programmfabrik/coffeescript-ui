// Generated by CoffeeScript 1.10.0
(function() {
  CUI.ready((function(_this) {
    return function() {
      var body, exampleLinks, examples;
      examples = ["vertical-layout", "horizontal-layout", "border-layout", "vertical-horizontal-list", "layout-complete", "form", "button", "pane", "icon", "modal", "custom-element", "element-props"];
      exampleLinks = examples.map(function(example) {
        return new CUI.ButtonHref({
          href: "examples/" + example + "/index.html",
          appearance: "link",
          text: example
        });
      });
      exampleLinks.push(new CUI.ButtonHref({
        href: "https://programmfabrik.github.io/coffeescript-ui-demo/public/index.html",
        appearance: "link",
        text: "Demo"
      }));
      body = new CUI.VerticalLayout({
        center: {
          content: new CUI.Pane({
            auto_buttonbar: false,
            padded: true,
            center: {
              content: exampleLinks
            }
          })
        }
      });
      return CUI.dom.append(document.body, body);
    };
  })(this));

}).call(this);
