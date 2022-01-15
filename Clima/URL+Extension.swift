//
//  URL+Extension.swift
//  Clima
//
//  Created by José Javier Cueto Mejía on 15/01/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

extension URL {
    static func urlForWeatherAPI(city: String) -> URL? {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=48ec4cb08795079ef863734440f56b8f&q=\(city)")
    }
}
