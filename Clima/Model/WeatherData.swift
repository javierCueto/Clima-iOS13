//
//  WeatherData.swift
//  Clima
//
//  Created by José Javier Cueto Mejía on 08/11/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {
    let name : String
    let main : Main
    let weather : [Weather]
}

extension WeatherData {
    static var empty: WeatherData {
        return WeatherData(name: "Nada de nada", main: Main(temp: 0), weather: [Weather(main: "vacio", id: 5)])
    }
}

struct Main: Decodable {
    let temp : Double
}

struct Weather: Decodable {
    let main : String
    let id : Int
}

