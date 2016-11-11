//
//  Location.swift
//  WeatherApp
//
//  Created by Konada on 11/11/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import Foundation

struct Location {
	let lat: String?
	let lon: String?
	let error: String?
	
	init(lat: String?, lon: String?, error: String?) {
		self.lat = "0"
		self.lon = "0"
		self.error = "Error"
	}
	
	func formattedLat() -> String{
		let locationService = LocationService()
		
		return String.localizedStringWithFormat("%.2f", (locationService.locationManager.location?.coordinate.latitude)!)
	}
	
	func formattedLon() -> String{
		let locationService = LocationService()
		
		return String.localizedStringWithFormat("%.2f",(locationService.locationManager.location?.coordinate.longitude)!)
	}
	
	}
