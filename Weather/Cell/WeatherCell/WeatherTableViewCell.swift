//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Сергей Горячев on 04.09.2021.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    static let reuseIdentifier = "WeatherTableViewCell"
    
    @IBOutlet private weak var dateWeatherLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var minTemperatureLabel: UILabel!
    @IBOutlet private weak var dayTemperatureLabel: UILabel!
    @IBOutlet private weak var maxTemperatureLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
        let dF = DateFormatter()
        dF.dateFormat = "EEEE"
        return dF
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configure(with weatherDaily: WeatherDaily) {
        let temperatureMin = weatherDaily.temperatureMin
        minTemperatureLabel.text = String(format: "%.0f℃", temperatureMin)
        
        let temperatureDay = weatherDaily.temperatureDay
        dayTemperatureLabel.text = String(format: "%.0f℃", temperatureDay)
        
        let temperatureMax = weatherDaily.temperatureMax
        maxTemperatureLabel.text = String(format: "%.0f℃", temperatureMax)
        
        let dateWeather = weatherDaily.date
        dateWeatherLabel.text = dateFormatter.string(from: dateWeather)
        
        let url = URL(string: "https://api.openweathermap.org/img/w/\(weatherDaily.icon).png")
        iconImageView.kf.setImage(with: url)
    }
}
