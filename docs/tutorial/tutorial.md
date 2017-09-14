# Tutorial

This tutorial uses [webpack](https://webpack.github.io/) as main dependency to bundle all files together.
It's not obligatory to use it, but It's recommended

If you use webpack we recommend you to use *webpack.ProvidePlugin*. The final solution of this tutorial is using that plugin.

## Dependencies

**package.json**
```json
    {
     ...
     "devDependencies": {
        "coffee-loader": "^0.7.3",
        "coffee-script": "^1.12.7",
        "coffeescript-ui": "git+https://github.com/programmfabrik/coffeescript-ui.git",
        "css-loader": "^0.28.7",
        "node-sass": "^4.5.3",
        "sass-loader": "^6.0.2",
        "style-loader": "^0.18.2",
        "webpack": "^2.2.1"
      }
    }
```

## Get started
### Hello world

```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
CUI.alert({text: "Hello world"})
```

### Main class

First of all, we create a main class which will be the input file of webpack. 
Also this class will have the responsibility of render the main structure of the site.

Inside that class we require **coffeescript-ui** so we can use its *ready* event and *dom.append* function.

**App.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
class App
  constructor: ->
    body = "Hello world!"
    CUI.dom.append(document.body, body)
  
CUI.ready ->
    new App()
```

### Add a main layout

There is different types of layouts that we can use as main dom element. We use **VerticalLayout** as example.

**App.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
  
class App
  constructor: ->
    body = new CUI.VerticalLayout
      top:
        content: new CUI.Label
          text: "Welcome to Coffeescript UI Tutorial"
      center:
        content: new CUI.Label
          icon: "fa-home"
          text: "Hello world"
      bottom:
        content: new CUI.Label
          text: "This is the bottom"
    CUI.dom.append(document.body, body)
  
CUI.ready ->
  new App()
```

### Add some styles

We create a **base.scss** inside *scss* directory and we require it in **App** class. 
After that we have to choose which classes our elements should use.

**App.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
require('./scss/base.scss')
  
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
        content: new CUI.Label
          icon: "fa-home"
          text: "Hello world"
      bottom:
        class: "tutorial-main-layout-bottom"
        content: new CUI.Label
          text: "This is the bottom"
    CUI.dom.append(document.body, body)
  
CUI.ready ->
  new App()
```

**scss/base.scss**
```scss
.tutorial-main-layout {
  background-color: #eef0f1;
}

.tutorial-main-layout-top {
  display: block;
  font-size: 20px;
}

.tutorial-main-layout-bottom {
  text-align: center;
  font-size: 10px
}
```
### Fetching data

It's easy to fetch data with *CUI.XHR*. Also we combine it with *CUI.Deferred* as an example, 
but It's not necesarry because the method *start()* of an instance of *CUI.XHR* returns a CUI.Promise.

We use a weather-api-rest as an example.
So, to separate responsibilities, we create a new class called "WeatherService". Its responsibility will be just fetch data from the api-rest.

**modules/weather/WeatherService.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
	
class WeatherService
	
  @urlService = "http://weathers.co/api.php?city="
	
  @getWeather: (city) ->
    deferred = new CUI.Deferred()
	
    xhr = new CUI.XHR 
      url: @urlService + city
	
    xhr.start().done((response) =>
      deferred.resolve(response.data)
    )
	
    return deferred.promise()
	
module.exports = WeatherService
```

After that, we modify the main class so it can use this new class and get the data and render it.

**App.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
require('./scss/base.scss')
  
WeatherService = require('./modules/weather/WeatherService.coffee')
  
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
        content: new CUI.Label
          icon: "fa-spinner"
          text: "Fetching data..."
      bottom:
        class: "tutorial-main-layout-bottom"
        content: new CUI.Label
          text: "This is the bottom"
  
    @fetchAndRenderData(body)
  
    CUI.dom.append(document.body, body)
  
  fetchAndRenderData: (body) ->
    WeatherService.getWeather("Berlin").done((data) ->
      ul = CUI.dom.ul()
      temperature = CUI.dom.append(CUI.dom.li(), data.temperature)
      CUI.dom.append(ul, temperature)
      skytext = CUI.dom.append(CUI.dom.li(), data.skytext)
      CUI.dom.append(ul, skytext)
      humidity = CUI.dom.append(CUI.dom.li(), data.humidity)
      CUI.dom.append(ul, humidity)
  
      body.replace(ul, "center")
    )
  
CUI.ready ->
  new App()
```

The function **fetchAndRenderData** is responsible of invoke **WeatherService** and render the data. 
To render the data we use the method *append* of *VerticalLayout*, and we pass the "key" of which "slot" we want to replace. 
In this case we replace the *center* "slot", which has the "loading" message. 

Please, don't pay to much attention to **CUI.dom.append** invocations, because it's not the best way to render data.

### Create a new template

**CUI.dom.append** is an useful function, but it has to be the last resource to use. 
So, we will use a custom template to render our data and remove those CUI.dom.append functions.

The first step is to create a *html* file, which has all the html structure of our desired *template*.

The main element has to have a *data-template* attribute with the name of our template, and optionally is possible to add *slots* inside that element.
*Slots* are used to put values inside them, and each one needs a *data-slot* attribute to access them.


**modules/weather/weather.html**
```html
<div data-template="weather">
    <ul>
        <li>
            <label>Temperature:</label>
            <span data-slot="temperature"></span>
        </li>
        <li>
            <label>Skytext:</label>
            <span data-slot="skytext"></span>
        </li>
        <li>
            <label>Humidity:</label>
            <span data-slot="humidity"></span>
        </li>
    </ul>
</div>
```

Then, we create a class which will have all the responsibilities about "weather". 
This is not obligatory to use templates, but it's a good way to organise your code, and avoid having all the responsibilities in just a class.

**modules/weather/Weather.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
WeatherService = require('./WeatherService.coffee')
htmlTemplate = require('./weather.html')
 
CUI.Template.loadTemplateText(htmlTemplate);
 
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
```

To wire our new template with our application is needed to use the function *CUI.Template.loadTemplateText*

This new class has two methods: *initOpts* and *render*. 
The first one is used by the constructor of our extended class *CUI.Element* and It's basically used to map all *options* and check for restrictions on those *options*.
In this case we add a restriction on *city* attribute, it must be a String and mandatory.

The function **render** is the responsible for invoke the service to fetch the data, use the new template to render the data obtained and then return the template.
As we know, **WeatherService.getWeather** is a promise, so the render method will return an empty template until the data is fetched. 
That's why we used a CUI element called **WaitBlock**. It basically render an spinner until we destroy it. 

The main class suffered some modifications in the wake of these changes.

**App.coffee**
```coffeescript
CUI = require("coffeescript-ui/public/cui.js")
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
```

**------In progress------**
