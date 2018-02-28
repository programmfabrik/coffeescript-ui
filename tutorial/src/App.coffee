#CUI = require("coffeescript-ui/public/cui.js")
require('coffeescript-ui/public/cui.css')
require('./scss/base.scss')

Weather = require('./modules/weather/Weather.coffee')

class App
  constructor: ->
    body = new CUI.VerticalLayout
      class: "tutorial-main-layout"
      top:
        class: "tutorial-main-layout-top"
        content: new CUI.Label
          text: "Welcome to Coffeescript UI Tutorial"
          icon: "fa-star"
      center:
        content: new Weather(city: "Berlin").render()
      bottom:
        class: "tutorial-main-layout-bottom"
        content: new CUI.Label
          text: "This is the bottom"

    CUI.dom.append(document.body, body)

CUI.ready ->
  new App()