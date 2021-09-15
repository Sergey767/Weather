//
//  DataManager.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 02.09.2021.
//

import Foundation

class DataManager: NSObject {
    
    static let shared = DataManager()
    var cities = [CitiesData]()
    
    let url = Bundle.main.url(forResource: "current.city.list", withExtension: "json")
    
    override init() {
        guard let jsonData = url else {
            print("data not found")
            return
        }
        
        guard let data = try? Data(contentsOf: jsonData) else { return }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("failedh")
            return
        }
        
        if let jsonArray = json as? [[String: Any]] {
            self.cities = jsonArray.compactMap{return CitiesData($0)}
        }
    }
}
