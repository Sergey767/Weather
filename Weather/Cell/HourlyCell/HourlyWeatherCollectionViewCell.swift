//
//  HourlyWeatherCollectionViewCell.swift
//  Weather
//
//  Created by Сергей Горячев on 04.09.2021.
//

import UIKit
import Kingfisher

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "HourlyWeatherCollectionViewCell"
    
    @IBOutlet private weak var timeWeatherLabel: UILabel!
    @IBOutlet private weak var iconWeatherImageView: UIImageView!
    @IBOutlet private weak var temperatureHourlyLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
        let dF = DateFormatter()
        dF.dateFormat = "HH:mm"
        return dF
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyWeatherCollectionViewCell", bundle: nil)
    }
    
    func configure(with weatherHourly: WeatherHourly) {
        let temperature = weatherHourly.temperature
        temperatureHourlyLabel.text = String(format: "%.0f℃", temperature)
        
        let time = weatherHourly.date
        timeWeatherLabel.text = dateFormatter.string(from: time)
        
        let url = URL(string: "https://api.openweathermap.org/img/w/\(weatherHourly.icon).png")
        iconWeatherImageView.kf.setImage(with: url)
    }
}
