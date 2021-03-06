// Generated by CoffeeScript 1.10.0
(function() {
  var App, MyElement,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  MyElement = (function(superClass) {
    extend(MyElement, superClass);

    function MyElement() {
      return MyElement.__super__.constructor.apply(this, arguments);
    }

    MyElement.prototype.initOpts = function() {
      MyElement.__super__.initOpts.call(this);
      return this.addOpts({
        title: {
          "default": "Default title",
          check: String
        },
        year: {
          check: "Integer",
          mandatory: true
        },
        show: {
          check: Boolean
        },
        size: {
          check: ["small", "big"],
          "default": "small"
        },
        number: {
          "default": 50,
          check: (function(_this) {
            return function(value) {
              return value > 10 && value < 100;
            };
          })(this)
        }
      });
    };

    MyElement.prototype.dump = function() {
      var data;
      data = {
        title: this._title,
        year: this._year,
        size: this._size,
        number: this._number
      };
      if (this._show) {
        return CUI.util.dump(data);
      } else {
        return "Show attribute is false";
      }
    };

    return MyElement;

  })(CUI.Element);

  App = (function() {
    function App() {
      var body, myElement, myElementTwo;
      myElement = new MyElement({
        year: 2018,
        show: true,
        size: "big"
      });
      myElementTwo = new MyElement({
        year: 1991,
        show: false,
        size: "small"
      });
      body = new CUI.VerticalLayout({
        top: {
          content: myElement.dump()
        },
        center: {
          content: myElementTwo.dump()
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
