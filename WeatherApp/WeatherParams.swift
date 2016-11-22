//
//  WeatherParams.swift
//  WeatherApp
//
//  Created by Konada on 11/11/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import Foundation

struct WeatherParams {

	var description :String?
	var temperature :Double!
	var humidity :Double!
	var pressure :Double!
	var clouds :Double!
	var others :[String]
	var rain: Double?
	var snow: Double?
	var name: String
	let rs: String

	init(_ jsonResult: NSDictionary) {
		rain = (jsonResult["rain"] as? NSDictionary)?["3h"] as? Double
		if rain == nil {rain = 0} else { rain = (jsonResult["rain"] as? NSDictionary)?["3h"] as? Double}
		snow = (jsonResult["snow"] as? NSDictionary)?["3h"] as? Double
		if snow == nil {snow = 0} else { snow = (jsonResult["snow"] as? NSDictionary)?["3h"] as? Double}
		
		if snow != 0 {rs = "snow: \(snow!)"} else {rs = "rain: \(rain!)"}
		
		description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String
		temperature = (jsonResult["main"] as? NSDictionary)?["temp"] as? Double
		humidity = (jsonResult["main"] as? NSDictionary)?["humidity"] as? Double
		pressure = (jsonResult["main"] as? NSDictionary)?["pressure"] as? Double
		clouds = (jsonResult["clouds"] as? NSDictionary)?["all"] as? Double
		others = ["humidity: \(humidity!)%", "pressure: \(pressure!) hPa", "clouds: \(clouds!)%", rs]
		name = jsonResult["name"]! as! String
	}
	
	func localizedTemperature() -> String {
		return String.localizedStringWithFormat("%.0f %@", (temperature - 273.15), "°C")
	}
	
func formattedLocation() -> String {
	return "in " + name + "?"
	}
	
	
}
