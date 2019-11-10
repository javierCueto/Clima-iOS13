//
//  WeatherManager.swift
//  Clima
//
//  Created by José Javier Cueto Mejía on 06/11/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager  {
    let urlWeather : String = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=48ec4cb08795079ef863734440f56b8f"
    var delegate : WeatherManagerDelegate?
    
    func fechWeather(cityName : String){
        let urlString = "\(urlWeather)&q=\(cityName)"
        performRequest(with : urlString)
    }
    
    func fechWeather(latitude: CLLocationDegrees, longitude : CLLocationDegrees){
        let urlString = "\(urlWeather)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with : urlString)
    }
    
    func performRequest(with urlString : String){
        print("Esta realizando una busqueda...")
        let urlStringParsed = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: urlStringParsed!){
            print("is url")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                print("create the request")
                if error != nil{
                    print("request is null")
                    print("fallo al buscar")
                    self.delegate?.didFailWithError(error : error!)
                    return
                }
                
                if let safeData = data {
                    print("trae datos")
                    //let dataString = String(data: safeData, encoding: .utf8)
                    //print(dataString)
                    if let weather = self.parseJSON(safeData) {
                        print("regresa los datos")
                        // this line call a delegated method, this method is in the controller
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                
            }
            print("finaliza la peticion")
            task.resume()
        }
        print("no es url")
    }
    
    // the data is saved in weatherData in returned to the controller in the object weatherModel
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        }catch {
            print("problemas de conexion")
           delegate?.didFailWithError(error : error)
            return nil
        }
    }
    

    
}
