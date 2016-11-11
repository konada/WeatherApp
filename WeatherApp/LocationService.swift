//
//  LocationService.swift
//  WeatherApp
//
//  Created by Konada on 11/11/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import Foundation
import CoreLocation



class LocationService: NSObject, CLLocationManagerDelegate {
	
	var locationManager: CLLocationManager!
	
	var lat: String = "0"
	var lon: String = "0"
	
	override init() {
		super.init()
		
		self.locationManager = CLLocationManager()
		
		if CLLocationManager.locationServicesEnabled()  {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestLocation()
		} else {
			//self.resultLabel.text = "Location services disabled"
			//self.resultLabel.alpha = 1
			print("Location services disabled")
			
		}
		
		while locationManager.location?.coordinate.latitude == nil && locationManager.location?.coordinate.longitude == nil {
			
			//self.resultLabel.text = "Waiting for GPS signal, try again in a few secs"
			//self.resultLabel.alpha = 1
				print("Waiting for GPS signal, try again in a few secs")
			
		}
		
		
			Location(lat: lat, lon: lon, error: "Error")
			}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}

	
}
