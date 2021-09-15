//
//  WeatherHourly.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 29.08.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class WeatherHourly: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: Date = Date.distantPast
    @objc dynamic var temperature: Double = 0
    @objc dynamic var icon: String = ""
    @objc dynamic var city: String = ""
    
    convenience init(_ json: JSON, city: String) {
        self.init()
        
        let date = json["dt"].doubleValue
        self.date = Date(timeIntervalSince1970: date)
        self.temperature = json["main"]["temp"].doubleValue
        self.icon = json["weather"][0]["icon"].stringValue
        self.city = city
        self.id = city + String(date)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

//{
//    "dt": 1630713600,
//    "main": {
//        "temp": 7.05,
//        "feels_like": 3.31,
//        "temp_min": 6.98,
//        "temp_max": 7.05,
//        "pressure": 1000,
//        "sea_level": 1000,
//        "grnd_level": 984,
//        "humidity": 80,
//        "temp_kf": 0.07
//    },
//    "weather": [
//        {
//            "id": 500,
//            "main": "Rain",
//            "description": "light rain",
//            "icon": "10n"
//        }
//    ],
//    "clouds": {
//        "all": 100
//    },
//    "wind": {
//        "speed": 6.52,
//        "deg": 295,
//        "gust": 11.71
//    },
//    "visibility": 10000,
//    "pop": 0.2,
//    "rain": {
//        "3h": 0.12
//    },
//    "sys": {
//        "pod": "n"
//    },
//    "dt_txt": "2021-09-04 00:00:00"
//}
