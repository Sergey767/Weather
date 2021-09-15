//
//  MainWeatherViewController.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 29.08.2021.
//

import UIKit
import RealmSwift

class MainWeatherViewController: UIViewController, CitiesSendingDelegateProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var citiesWeatherLabel: UILabel!
    
    private let networkService = NetworkService()
    private var weathersHourly: Results<WeatherHourly>?
    private var weathersDaily: Results<WeatherDaily>?
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Погода"
        
        sendCitiesDataToMainVC(cities: UserDefaults.standard.string(forKey: "cities") ?? "")
        
        settingBackground()
        
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
        
        settingShadow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToken?.invalidate()
    }
    
    func sendCitiesDataToMainVC(cities: String) {
        
        UserDefaults.standard.set(cities, forKey: "cities")
        
        weathersDaily = try? Realm().objects(WeatherDaily.self).filter("city == %@", cities).filter("date >= %@", Date()).sorted(byKeyPath: "id")
        
        weathersHourly = try? Realm().objects(WeatherHourly.self).filter("city == %@", cities).filter("date >= %@", Date()).sorted(byKeyPath: "id")
        
        networkService.weatherForecastDaily(for: cities) { weathersDaily in
            try? RealmProvider.save(items: weathersDaily)
        }
        
        networkService.weatherForecastHourly(for: cities) { weathersHourly in
            try? RealmProvider.save(items: weathersHourly)
        }
    
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
        
        if (cities.isEmpty) {
            self.citiesWeatherLabel.isHidden = true
        } else {
            self.citiesWeatherLabel.isHidden = false
        }
        
        self.citiesWeatherLabel.text =  "Ваш город: \(cities)"
        self.citiesWeatherLabel.textColor = UIColor(red: 224/255, green: 255/255, blue: 255/255, alpha: 0.8)
    }
    
    // MARK: - Settings
    
    func settingBackground() {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func settingShadow() {
        
        let containerCollectionView:UIView = UIView(frame:self.collectionView.frame)
        containerCollectionView.backgroundColor = UIColor.white
        containerCollectionView.layer.cornerRadius = 10
        containerCollectionView.layer.shadowColor = UIColor.white.cgColor
        containerCollectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerCollectionView.layer.shadowOpacity = 1
        containerCollectionView.layer.shadowRadius = 5
        self.view.addSubview(containerCollectionView)
        self.view.addSubview(collectionView)
        self.collectionView.layer.cornerRadius = 15
        self.collectionView.layer.masksToBounds = true

        let containerTableView:UIView = UIView(frame:self.tableView.frame)
        containerTableView.backgroundColor = UIColor.white
        containerTableView.layer.cornerRadius = 10
        containerTableView.layer.shadowColor = UIColor.white.cgColor
        containerTableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerTableView.layer.shadowOpacity = 1
        containerTableView.layer.shadowRadius = 5
        self.view.addSubview(containerTableView)
        self.view.addSubview(tableView)
        self.tableView.layer.cornerRadius = 15
        self.tableView.layer.masksToBounds = true
        
        guard let weathersDaily = weathersDaily else { return }
        if (weathersDaily.isEmpty) {
            self.tableView.isHidden = true
            containerCollectionView.isHidden = true
        } else {
            self.tableView.isHidden = false
            containerCollectionView.isHidden = false
        }
        
        guard let weathersHourly = weathersHourly else { return }
        if (weathersHourly.isEmpty) {
            self.collectionView.isHidden = true
            containerTableView.isHidden = true
        } else {
            self.collectionView.isHidden = false
            containerTableView.isHidden = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCities" {
            if let destinationVC = segue.destination as? CitiesTableViewController {
                destinationVC.delegate = self
            }
        }
    }
}

// MARK: - Collection view data source, delegate methods

extension MainWeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weathersHourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCollectionViewCell", for: indexPath) as! HourlyWeatherCollectionViewCell
        guard let weatherHourly = weathersHourly?[indexPath.row] else { return cell }
        cell.configure(with: weatherHourly)
        return cell
    }
}

// MARK: - Table view data source, delegate methods

extension MainWeatherViewController: UITableViewDataSource, UITableViewDelegate {

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
