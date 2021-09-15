//
//  CitiesTableViewController.swift
//  WeatherHourly
//
//  Created by Сергей Горячев on 01.09.2021.
//

import UIKit

protocol CitiesSendingDelegateProtocol {
    func sendCitiesDataToMainVC(cities: String)
}

class CitiesTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cities = [CitiesData]()
    var filteredCities = [CitiesData]()
    
    var delegate: CitiesSendingDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Города"
        
        cities = DataManager.shared.cities
        
        settingSearchVC()

        self.tableView.register(CitiesTableViewCell.nib(), forCellReuseIdentifier: CitiesTableViewCell.reuseIdentifier)
        self.tableView.reloadData()
    }
    
    @objc func tappedWeatherForecastButton(sender: UIButton) {
        performSegue(withIdentifier: "ShowForecast", sender: sender.tag)
    }
    
    // MARK: - UISearchController
    
    private func settingSearchVC() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder =  "Найти город"
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.barTintColor = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 0.5)
        searchController.searchBar.searchTextField.backgroundColor = UIColor.white
        definesPresentationContext = true
    }
    
    private func filterCities(for searchText: String) {
      filteredCities = cities.filter { city in
        return city.cityName.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier == "ShowForecast" {
           let destinationVC = segue.destination as! WeatherForecastViewController
           let selectedIndex = sender as! Int
            let city: String
            if searchController.isActive && searchController.searchBar.text != "" {
                city = filteredCities[selectedIndex].cityName
            } else {
                city = cities[selectedIndex].cityName
            }
            destinationVC.city = city
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCities.count
          }
          return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let citiesList: CitiesData
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesTableViewCell", for: indexPath) as! CitiesTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
          citiesList = filteredCities[indexPath.row]
        } else {
          citiesList = cities[indexPath.row]
        }
        
        cell.configure(with: citiesList)
        cell.weatherForecastDetailButton.tag = indexPath.row
        cell.weatherForecastDetailButton.addTarget(self, action: #selector(tappedWeatherForecastButton), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow (at: indexPath, animated: true)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            delegate?.sendCitiesDataToMainVC(cities: filteredCities[indexPath.row].cityName)
        } else {
            delegate?.sendCitiesDataToMainVC(cities: cities[indexPath.row].cityName)
        }
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        dismiss(animated: true, completion: nil)
    }
}

extension CitiesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterCities(for: searchController.searchBar.text ?? "")
    }
}
