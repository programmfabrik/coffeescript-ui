#CUI = require("coffeescript-ui/public/cui.js")

class WeatherService

	@urlService = "public/weather-service.json?city="

	@getWeather: (city) ->
		deferred = new CUI.Deferred()

		xhr = new CUI.XHR
			url: @urlService + city

		xhr.start().done((response) =>
			deferred.resolve(response.data)
		)

		return deferred.promise()

module.exports = WeatherService
