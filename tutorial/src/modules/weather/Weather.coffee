#CUI = require("coffeescript-ui/public/cui.js")
WeatherService = require('./WeatherService.coffee')
htmlTemplate = require('./weather.html')
CUI.Template.loadTemplateText(htmlTemplate)


class Weather extends CUI.Element

  initOpts: ->
    super()
    @addOpts
      city:
        mandatory: true
        check: String

  render: ->
    template = new CUI.Template
      name: "weather"
      map:
        temperature: true
        skytext: true
        humidity: true

    waitBlock = new CUI.WaitBlock(element: template)
    waitBlock.show()

    WeatherService.getWeather(@_city)
      .always =>
        waitBlock.destroy()
      .done((data) =>
        for key of template.map
          template.append(data[key], key)
      )

    template

module.exports = Weather