// Generated by CoffeeScript 1.10.0
(function() {
  var App;

  App = (function() {
    var bodyHorizontalList, bodyVerticalList;

    function App() {}

    bodyHorizontalList = new CUI.HorizontalList({
      content: [
        new CUI.Label({
          centered: true,
          text: "Label #1"
        }), new CUI.Label({
          centered: true,
          text: "Label #2"
        }), new CUI.Label({
          centered: true,
          text: "Label #3"
        })
      ]
    });

    bodyVerticalList = new CUI.VerticalList({
      content: [
        new CUI.Label({
          centered: true,
          text: "Label #1"
        }), new CUI.Label({
          centered: true,
          text: "Label #2"
        }), new CUI.Label({
          centered: true,
          text: "Label #3"
        })
      ]
    });

    CUI.dom.append(document.body, bodyHorizontalList);

    CUI.dom.append(document.body, bodyVerticalList);

    return App;

  })();

  CUI.ready(function() {
    return new App();
  });

}).call(this);