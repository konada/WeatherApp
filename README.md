# WeatherApp

This is a simple weather app based on [openweathermap.org](http://openweathermap.org/) API, created to display weather details for your current location.

In order to make it work you need to provide your own APIKey available after signing up on [openweathermap.org](http://openweathermap.org/).

You can add it in two ways:

1. By creating APIKeys.plist with "APIKey" key name and API Key value in a string form:

    ```
let api = valueForAPIKey(keyname:"APIKey")
    ```
2. If you don't want to create a .plist file, just put your opeweather.org API Key in the following commented line 
in ViewController.swift:
 
 ```
 let api = "your key goes here - remember to comment the line above and uncomment this line" 
 ```
 and by commenting the line from point 1.
