//
//  NetworkService.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 04.09.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkService {
    
    private let concurrentQueue = DispatchQueue(label: "WeatherForecastAsyncQueue", attributes: .concurrent)
    
    private let host = "https://api.openweathermap.org"
    
    static let session: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        let session = Session(configuration: config)
        return session
    }()
    
    func weatherForecastHourly(for city: String, completion: @escaping ([WeatherHourly]) -> Void) {
        
        let path = "/data/2.5/forecast"
        
        let parameters: Parameters = [
            "q": city,
            "units": "metric",
            "appid": "e93c85e5fb99101bb75e1572ff0ec887",
            "cnt": "9"
        ]
        
        NetworkService.session.request(host + path, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                    let weatherJSONs = json["list"].arrayValue
                    let weathers = weatherJSONs.map { WeatherHourly($0, city: city) }
                
                DispatchQueue.main.async {
                    completion(weathers)
                }
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    func weatherForecastDaily(for city: String, completion: @escaping ([WeatherDaily]) -> Void) {

        let path = "/data/2.5/forecast/daily"

        let parameters: Parameters = [
            "q": city,
            "units": "metric",
            "appid": "ea574594b9d36ab688642d5fbeab847e",
            "cnt": "7"
        ]

        NetworkService.session.request(host + path, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                DispatchQueue.global().async {
                    let weatherJSONs = json["list"].arrayValue
                    let weathers = weatherJSONs.map { WeatherDaily($0, city: city) }
                    DispatchQueue.main.async {
                        completion(weathers)
                    }
                }
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
}
