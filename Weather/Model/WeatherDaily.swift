//
//  WeatherDaily.swift
//  Weather
//
//  Created by Сергей Горячев on 04.09.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class WeatherDaily: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: Date = Date.distantPast
    @objc dynamic var temperatureDay: Double = 0
    @objc dynamic var temperatureMin: Double = 0
    @objc dynamic var temperatureMax: Double = 0
    @objc dynamic var icon: String = ""
    @objc dynamic var city: String = ""
    
    convenience init(_ json: JSON, city: String) {
        self.init()
        let date = json["dt"].doubleValue
        self.date = Date(timeIntervalSince1970: date)
        self.temperatureDay = json["temp"]["day"].doubleValue
        self.temperatureMin = json["temp"]["min"].doubleValue
        self.temperatureMax = json["temp"]["max"].doubleValue
        self.icon = json["weather"][0]["icon"].stringValue
        self.city = city
        self.id = city + String(date)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

//{
//    "dt": 1630746000,
//    "sunrise": 1630723217,
//    "sunset": 1630772239,
//    "temp": {
//        "day": 8.12,
//        "min": 6.42,
//        "max": 9.93,
//        "night": 7.19,
//        "eve": 9.21,
//        "morn": 6.42
//    },
//    "feels_like": {
//        "day": 4.76,
//        "night": 4.46,
//        "eve": 6.45,
//        "morn": 2.67
//    },
//    "pressure": 1006,
//    "humidity": 71,
//    "weather": [
//        {
//            "id": 500,
//            "main": "Rain",
//            "description": "light rain",
//            "icon": "10d"
//        }
//    ],
//    "speed": 7.08,
//    "deg": 300,
//    "gust": 12.1,
//    "clouds": 99,
//    "pop": 0.4,
//    "rain": 0.62
//}
