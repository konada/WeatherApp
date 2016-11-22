//
//  LocationService.swift
//  WeatherApp
//
//  Created by Konada on 11/11/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
	func tracingLocation(_ currentLocation: CLLocation)
	func tracingLocationDidFailWithError(_ error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
	static let sharedInstance: LocationService = {
		let instance = LocationService()
		return instance
	}()
	
	var locationManager: CLLocationManager?
	var currentLocation: CLLocation?
	var delegate: LocationServiceDelegate?
	
	override init() {
		super.init()
		
		self.locationManager = CLLocationManager()
		guard let locationManager = self.locationManager else {
			return
		}
		
		if CLLocationManager.authorizationStatus() == .notDetermined {

			locationManager.requestWhenInUseAuthorization()
		}
		
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.distanceFilter = 200
		locationManager.delegate = self
	}
	
	func startUpdatingLocation() {
		print("Starting Location Updates")
		self.locationManager?.startUpdatingLocation()
	}
	
	func stopUpdatingLocation() {
		print("Stop Location Updates")
		self.locationManager?.stopUpdatingLocation()
	}
	
	// CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		guard let location = locations.last else {
			return
		}
		
		// singleton for get last(current) location
		currentLocation = location
		
		// use for real time update location
		updateLocation(location)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		
		// do on error
		updateLocationDidFailWithError(error as NSError)
	}
	
	func formattedLat() -> String{
		
		
		return String.localizedStringWithFormat("%.2f", (locationManager!.location?.coordinate.latitude)!)
	}
	
	func formattedLon() -> String{
		
		
		return String.localizedStringWithFormat("%.2f",(locationManager!.location?.coordinate.longitude)!)
	}
	
	

	
	// Private function
	fileprivate func updateLocation(_ currentLocation: CLLocation){
		
		guard let delegate = self.delegate else {
			return
		}
		
		delegate.tracingLocation(currentLocation)
	}
	
	fileprivate func updateLocationDidFailWithError(_ error: NSError) {
		
		guard let delegate = self.delegate else {
			return
		}
		
		delegate.tracingLocationDidFailWithError(error)
	}
}


