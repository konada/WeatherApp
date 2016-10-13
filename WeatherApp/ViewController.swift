//
//  ViewController.swift
//  API Demo
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

		let locationManager = CLLocationManager()

	@IBAction func submit(_ sender: AnyObject) {
		

		
		locationManager.requestWhenInUseAuthorization();
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestLocation()
			
		}
		else{
			self.resultLabel.text = "Location services disabled"
			self.resultLabel.alpha = 1
		}
		
		let lat = String(format: "%.2f",(locationManager.location?.coordinate.latitude)!)
		let lon = String(format: "%.2f",(locationManager.location?.coordinate.longitude)!)
		
		
		if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=630238557df5db3173072e27c5b9e7f8") {
	

		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			
			if error != nil {
				
				print(error)
				
			} else {
				
				if let urlContent = data {
					
					do {
						
						let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
						
						//print(jsonResult)
						
						print(jsonResult["name"])
						
						
						if let description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String,
							let temperature = (jsonResult["main"] as? NSDictionary)?["temp"] as? Double,
							let humidity = (jsonResult["main"] as? NSDictionary)?["humidity"] as? Double,
							let pressure = (jsonResult["main"] as? NSDictionary)?["pressure"] as? Double,
							let clouds = (jsonResult["clouds"] as? NSDictionary)?["all"] as? Double,
							let rain = (jsonResult["rain"] as? NSDictionary)?["3h"] as? Double
						{//humidity, pressure, overcast clouds, rain
					
							DispatchQueue.main.sync(execute: {
								
								self.resultLabel.text = description
								self.resultLabel.alpha = 1
								print("It's working")

								self.temperatureLabel.text = String.localizedStringWithFormat("%.0f %@", (temperature - 273.15), "°C")
								self.temperatureLabel.alpha = 1
								print("It's working too")
								
								self.cityLabel.text = "in " + (jsonResult["name"]! as! String)+"?"
								self.cityLabel.alpha = 1
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
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		resultLabel.alpha = 0
		temperatureLabel.alpha = 0
		cityLabel.alpha = 0
		
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
	
	
}

public extension UIView {
	
	func fadeOut(withDuration duration: TimeInterval = 1.0) {
		UIView.animate(withDuration: duration, animations: {
			self.alpha = 0.2
		})}
}

