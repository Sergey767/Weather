//
//  CitiesTableViewCell.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 01.09.2021.
//

import UIKit

class CitiesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var citiesNameLabel: UILabel!
    @IBOutlet weak var weatherForecastDetailButton: UIButton!
    
    static let reuseIdentifier = "CitiesTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CitiesTableViewCell", bundle: nil)
    }
    
    func configure(with city: CitiesData) {
        let cityName = city.cityName
        citiesNameLabel.text = cityName
    }
}
