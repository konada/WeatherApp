//
//  ViewController.swift
//  WeatherApp
//
//  Created by Konada on 10/12/16.
//  Copyright © 2016 Konada. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation


class ViewController: UIViewController {
	
		var player: AVPlayer?
		var timer: DispatchSourceTimer!
	


	@IBAction func submit(_ sender: AnyObject) {
		
		LocationService.sharedInstance.startUpdatingLocation()

		let api = valueForAPIKey(keyname:"APIKey")
		//if you don't want to create plist file, just put your opeweather.org API Key in the line below:
		//let api = "your key goes here - remember to comment the line above and uncomment this line"
		
		
		let locationServ = LocationService()
		
		
		if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(locationServ.formattedLat())&lon=\(locationServ.formattedLon())&appid=\(api)") {
		
			//if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=630238557df5db3173072e27c5b9e7f8") {

			let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
				
				if error != nil {
					
					print(error)
					
				} else {
					
					if let urlContent = data {
						
						do {
							
							let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
							print(jsonResult)
							let weatherPar = WeatherParams(jsonResult)
							
							if weatherPar != nil {
							
								
								DispatchQueue.main.sync(execute: {
									
									
									self.resultLabel.text = weatherPar.description
									self.resultLabel.alpha = 1
									
									
									self.temperatureLabel.text = weatherPar.localizedTemperature()
									self.temperatureLabel.alpha = 1
									
									
									self.cityLabel.text = weatherPar.formattedLocation()
									self.cityLabel.alpha = 1
									
									self.otherLabel.text = ""
									self.otherLabel.alpha = 1
									
									
									
									
									let welcomeStrings = weatherPar.others
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
	
		//LocationService.sharedInstance.delegate = self
		

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
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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

extension UIView {
	
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


