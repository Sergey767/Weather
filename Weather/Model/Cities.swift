//
//  Cities.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 01.09.2021.
//

import Foundation

class CitiesData {
    
    let cityName: String
    
    init(_ dictionary: [String: Any]) {
        self.cityName = dictionary["name"] as? String ?? ""
    }
}
