//
//  ViewController.swift
//  WeatherApp
//
//  Created by Oliwia Michalak on 07/03/2020.
//  Copyright © 2020 Oliwia Michalak. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var gradientVIew: UIView!
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "9e0915aa7910ac4b815c48e32db1d05a"
    var latitude = 51.4799995
    var longitude = -3.1800001
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientVIew.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setBlueBackgroundView()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let location = locations[0]
           latitude = location.coordinate.latitude
           longitude = location.coordinate.longitude
           Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric").responseJSON {
               response in
               self.activityIndicator.stopAnimating()
               if let responseStr = response.result.value {
                   let jsonResponse = JSON(responseStr)
                   let jsonWeather = jsonResponse["weather"].array![0]
                   let jsonTemp = jsonResponse["main"]
                   let iconName = jsonWeather["icon"].stringValue
                   
                   self.locationLabel.text = jsonResponse["name"].stringValue
                   self.weatherImage.image = UIImage(named: iconName)
                   self.weatherLabel.text = jsonWeather["main"].stringValue
                   self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                   
                   let date = Date()
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "EEEE"
                   self.dayLabel.text = dateFormatter.string(from: date)
                   
                   let suffix = iconName.suffix(1)
                   if(suffix == "n"){
                       self.setGrayBackgroundVIew()
                   }else{
                       self.setBlueBackgroundView()
                   }
               }
           }
           self.locationManager.stopUpdatingLocation()
       }
       
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error.localizedDescription)
       }
       

    func setBlueBackgroundView() {
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGrayBackgroundVIew() {
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
               let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
               gradientLayer.frame = view.bounds
               gradientLayer.colors = [topColor, bottomColor]
    }
}

extension ViewController: CLLocationManagerDelegate {}
