//
//  WeatherForecastViewController.swift
//  Weather
//
//  Created by Сергей Горячев on 07.09.2021.
//

import UIKit
import RealmSwift

class WeatherForecastViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionView: NSLayoutConstraint!
    
    var city: String = ""
    let networkService = NetworkService()
    
    private lazy var weathersDaily = try? Realm().objects(WeatherDaily.self).filter("city == %@", city).filter("date >= %@", Date()).sorted(byKeyPath: "id")
    private lazy var weathersHourly = try? Realm().objects(WeatherHourly.self).filter("city == %@", city).filter("date >= %@", Date()).sorted(byKeyPath: "id")
    
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        constraintAnimation()
        
        self.title = city
        
        networkService.weatherForecastDaily(for: city) { weathersDaily in
            try? RealmProvider.save(items: weathersDaily)
        }
        
        networkService.weatherForecastHourly(for: city) { weathersHourly in
            try? RealmProvider.save(items: weathersHourly)
        }
        
        collectionNotification()
        
        settingBackground()
        
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        
        self.collectionView.layer.cornerRadius = 10
        self.collectionView.layer.masksToBounds = true
        
        tableView.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.reuseIdentifier)
        collectionView.register(HourlyWeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.reuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationToken = weathersDaily?.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.update(deletions: deletions, insertions: insertions, modifications: modifications)
            case .error(let error):
                self.show(error)
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToken?.invalidate()
    }
    
    private func collectionNotification() {
        
        notificationToken = weathersHourly?.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
            case .initial:
                self.collectionView.reloadData()
            case .update:
                self.collectionView.reloadData()
            case .error(let error):
                self.show(error)
            }
        }
    }
    
    private func constraintAnimation() {
        constraintCollectionView.isActive = true
        
        UIView.animate(withDuration: 2.0, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func settingBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "cities")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        let imageTable = UIImage(named: "backgroundTable")
        let imageTableView = UIImageView(image: imageTable)
        self.tableView.backgroundView = imageTableView
        imageTableView.alpha = 0.8
        
        let imageCollection = UIImage(named: "backgroundCollection")
        let imageCollectionView = UIImageView(image: imageCollection)
        self.collectionView.backgroundView = imageCollectionView
        imageCollectionView.alpha = 0.8
    }
}

// MARK: - Collection view data source, delegate methods

extension WeatherForecastViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weathersHourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCollectionViewCell", for: indexPath) as! HourlyWeatherCollectionViewCell
        
        guard let weatherHourly = weathersHourly?[indexPath.row] else { return cell}
        cell.configure(with: weatherHourly)
        return cell
    }
}

// MARK: - Table view data source, delegate methods

extension WeatherForecastViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weathersDaily?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        guard let weatherDaily = weathersDaily?[indexPath.row] else { return cell }
        cell.configure(with: weatherDaily)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}
