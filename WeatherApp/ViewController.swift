//
//  ViewController.swift
//  WeatherApp
//
//  Created by Konada on 10/12/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation


class ViewController: UIViewController, CLLocationManagerDelegate {
	
		var player: AVPlayer?
		var timer: DispatchSourceTimer!
	

		let locationManager = CLLocationManager()

	@IBAction func submit(_ sender: AnyObject) {
		
		var lat: String = "0"
		var lon: String = "0"
		
		locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled()  {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestLocation()

		}
		else{
			self.resultLabel.text = "Location services disabled"
			self.resultLabel.alpha = 1
		}
		
		while locationManager.location?.coordinate.latitude == nil && locationManager.location?.coordinate.longitude == nil {

			self.resultLabel.text = "Waiting for GPS signal, try again in a few secs"
			self.resultLabel.alpha = 1

		}
		
		lat = String.localizedStringWithFormat("%.2f", (locationManager.location?.coordinate.latitude)!)
		lon = String.localizedStringWithFormat("%.2f",(locationManager.location?.coordinate.longitude)!)
		

		let api = valueForAPIKey(keyname:"APIKey")
		//if you don't want to create plist file, just put your opeweather.org API Key in the line below:
		//let api = "your key goes here - remember to comment the line above and uncomment this line"
		
		
		if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(api)") {
		

		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			
			if error != nil {
				
				print(error)
				
			} else {
				
				if let urlContent = data {
					
					do {
						
						let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
						print(jsonResult)

						var rain: Double?
						rain = (jsonResult["rain"] as? NSDictionary)?["3h"] as? Double
						if rain == nil {rain = 0} else { rain = (jsonResult["rain"] as? NSDictionary)?["3h"] as? Double}
						var snow: Double?
						snow = (jsonResult["snow"] as? NSDictionary)?["3h"] as? Double
						print(rain)
						if snow == nil {snow = 0} else { snow = (jsonResult["snow"] as? NSDictionary)?["3h"] as? Double}
						
						let rs: String
						
						if snow != 0 {rs = "snow: \(snow!)"} else {rs = "rain: \(rain!)"}

						
						if let description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String,
							let temperature = (jsonResult["main"] as? NSDictionary)?["temp"] as? Double,
							let humidity = (jsonResult["main"] as? NSDictionary)?["humidity"] as? Double,
							let pressure = (jsonResult["main"] as? NSDictionary)?["pressure"] as? Double,
							let clouds = (jsonResult["clouds"] as? NSDictionary)?["all"] as? Double,
							var others: [String] = []
							
						{
					
							DispatchQueue.main.sync(execute: {
								
								others = ["humidity: \(humidity)%", "pressure: \(pressure) hPa", "clouds: \(clouds)%", rs]
								
								self.resultLabel.text = description
								self.resultLabel.alpha = 1


								self.temperatureLabel.text = String.localizedStringWithFormat("%.0f %@", (temperature - 273.15), "°C")
								self.temperatureLabel.alpha = 1

								
								self.cityLabel.text = "in " + (jsonResult["name"]! as! String)+"?"
								self.cityLabel.alpha = 1
								
								self.otherLabel.text = ""
								self.otherLabel.alpha = 1

								
								

								let welcomeStrings = others
								var index = welcomeStrings.startIndex
								self.timer = DispatchSource.makeTimerSource(queue: .main)
								self.timer.scheduleRepeating(deadline: .now(), interval: .seconds(2))
								self.timer.setEventHandler { [weak self] in
								UIView.transition(with: (self?.otherLabel)!, duration: 0.75, options: [.transitionCrossDissolve], animations: {
										self?.otherLabel.text = welcomeStrings[index]}, completion: nil)
									index = index.advanced(by: 1)
									if index == welcomeStrings.endIndex {
										index = welcomeStrings.startIndex
									}
								}
								self.timer.resume()
								
								
								})
									
								}
						
						
					} catch {
						
						print("JSON Processing Failed")
						self.resultLabel.text = "JSON Processing Failed, API KEY NEEDED!"
						self.resultLabel.alpha = 1
					}
				}
				
			}
			
		}
		
		task.resume()
		tapButton.fadeOut(withDuration: 3)
		} else {
			resultLabel.text = "Couldn't find weather for that city."
			self.resultLabel.alpha = 1
		}
	}
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var tapButton: UIButton!
	@IBOutlet weak var otherLabel: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		resultLabel.alpha = 0
		temperatureLabel.alpha = 0
		cityLabel.alpha = 0
		otherLabel.alpha = 0
		
		//background video:
		let videoURL: URL = Bundle.main.url(forResource: "Clouds - 2114", withExtension: "mp4")!
		
		player = AVPlayer(url: videoURL)
		player?.actionAtItemEnd = .none
		player?.isMuted = true
		
		let playerLayer = AVPlayerLayer(player: player)
		playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		playerLayer.zPosition = -1
		
		playerLayer.frame = view.frame
		
		view.layer.addSublayer(playerLayer)
		
		player?.play()
		
		//loop video
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	func loopVideo() {
		player?.seek(to: kCMTimeZero)
		player?.play()
	}
	
	func valueForAPIKey(keyname:String) -> String {

  let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist")
  let plist = NSDictionary(contentsOfFile:filePath!)
  let value = plist?.object(forKey: keyname) as! String
  return value
	}
	
	
}

public extension UIView {
	
	func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 1.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.alpha = 1.0}, completion: completion)}
	
	func fadeOut(withDuration duration: TimeInterval = 1.0) {
		UIView.animate(withDuration: duration, animations: {
			self.alpha = 0.2
		})}
	

}

extension UIView {
	func pushTransition(duration:CFTimeInterval) {
		let animation:CATransition = CATransition()
		animation.timingFunction = CAMediaTimingFunction(name:
			kCAMediaTimingFunctionEaseInEaseOut)
		animation.type = kCATransitionPush
		animation.subtype = kCATransitionFromLeft
		animation.duration = duration
		self.layer.add(animation, forKey: kCATransitionPush)
	}

}


