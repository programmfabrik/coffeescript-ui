// Generated by CoffeeScript 1.10.0
(function() {
  var App;

  App = (function() {
    function App() {
      var body, modal, openModal;
      modal = new CUI.Modal({
        cancel: true,
        fill_screen_button: true,
        cancel_action: "hide",
        onToggleFillScreen: (function(_this) {
          return function() {
            return CUI.alert({
              text: "Fillscreen!"
            });
          };
        })(this),
        onCancel: (function(_this) {
          return function() {
            return CUI.alert({
              text: "Cancel!"
            });
          };
        })(this),
        pane: {
          padded: true,
          header_left: new CUI.Label({
            text: "I'm the header"
          }),
          content: new CUI.Label({
            icon: "fa-building",
            text: "Modal Content!"
          }),
          footer_right: [
            {
              text: "Destroy!",
              onClick: (function(_this) {
                return function() {
                  return modal.destroy();
                };
              })(this)
            }
          ]
        }
      });
      openModal = new CUI.Button({
        text: "Open modal!",
        onClick: (function(_this) {
          return function() {
            return modal.show();
          };
        })(this)
      });
      body = new CUI.HorizontalLayout({
        left: {
          content: new CUI.Label({
            centered: true,
            text: "Left"
          })
        },
        center: {
          content: openModal
        },
        right: {
          content: new CUI.Label({
            centered: true,
            text: "Right"
          })
        }
      });
      CUI.dom.append(document.body, body);
    }

    return App;

  })();

  CUI.ready(function() {
    return new App();
  });

}).call(this);