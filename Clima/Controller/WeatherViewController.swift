//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController{
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    let locationManager = CLLocationManager()
    
    //var weatherManager = WeatherManager()
    
    private var disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //order necessary to use the gps
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.searchField.text }
            .subscribe(onNext: { city in 
                if let city = city {
                    if city.isEmpty{
                        self.displayWeather(nil)
                    }else{
                        self.fetchWeather(by: city)
                        
                    }
                }
            }).disposed(by: disposebag)
    }
    
    private func displayWeather(_ weather: WeatherModel?) {
        if let weather = weather {
            DispatchQueue.main.async {
                self.temperatureLabel.text = weather.temperatureString
                self.conditionImageView.image = UIImage(systemName: weather.conditionName)
                self.cityLabel.text = weather.cityName
                
            }
        }else {
            self.temperatureLabel.text = ""
            self.conditionImageView.image = UIImage()
            self.cityLabel.text = ""
        }
    }
    
    private func fetchWeather(by city: String){
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL.urlForWeatherAPI(city: cityEncoded) else {
            return
        }
        
        let resource = Resource<WeatherData>(url: url)
 
        /*
         let search = URLRequest.load(resource: resource).observe(on: MainScheduler.instance).asDriver(onErrorJustReturn: WeatherData.empty)
        */
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance).retry(3)
            .catch { error in
                print("-------" + error.localizedDescription)
                return Observable.just(WeatherData.empty)
            }.asDriver(onErrorJustReturn: WeatherData.empty)
        
        search.map { result in
            let id = result.weather[0].id
            let temp = result.main.temp
            let name = result.name
            return WeatherModel(conditionId: id, cityName: name, temperature: temp).temperatureString

        }.drive(self.temperatureLabel.rx.text)
            .disposed(by: disposebag)
        
        search.map { result in
            return result.name

        }.drive(self.cityLabel.rx.text).disposed(by: disposebag)
        
        
        search.map { result in
            let id = result.weather[0].id
            let temp = result.main.temp
            let name = result.name
            return UIImage(systemName: WeatherModel(conditionId: id, cityName: name, temperature: temp).conditionName)!

        }.drive(self.conditionImageView.rx.image).disposed(by: disposebag)
    
    }
    

    @IBAction func currentLocationButton(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    
    @IBAction func searchButton(_ sender: UIButton) {
        searchField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        return  true
    }
    
    //validation
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else {
            textField.placeholder = "-.-, escribe algo"
            return false
        }
    }
    
    
}


//MARK: - WeatherManagerDelegate

//when the request ends the controller updates the interface

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            
        }
        
    }
    //en case of error appear a messege just in console, fix this part
    func didFailWithError(error: Error) {
        
        print("###########################################")
        DispatchQueue.main.async {
            // create the alert
            let alert = UIAlertController(title: ":(", message: "Lo sentimos pero no existe lo que busca, ella no te ama.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        print(error)
        print("###########################################")
    }
}


//MARK: - Delegate location

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations : [CLLocation]){
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("realiza la peticion con el gps automatico")
            //weatherManager.fechWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("###########################################")
        DispatchQueue.main.async {
            // create the alert
            let alert = UIAlertController(title: ":)", message: "Lo sentimos pero te hackearon los Rusos", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        print(error)
        print("###########################################")
    }
}

