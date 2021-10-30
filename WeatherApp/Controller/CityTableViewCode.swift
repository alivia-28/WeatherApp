//
//  CityTableViewCode.swift
//  WeatherApp
//
//  Created by Alivia Guin on 10/29/21.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currWeatherOfCity = arrCurrentWeather[indexPath.row]
               
       let cell = Bundle.main.loadNibNamed("CityTableViewCell", owner: self, options: nil)?.first as! CityTableViewCell
       cell.lblCityName.text = "\(currWeatherOfCity.cityInfoName)"
       cell.lblTemperature.text = "\(currWeatherOfCity.temp)°C"
       cell.lblWeather.text = "\(currWeatherOfCity.weatherText)"
       cell.lblImage.image = UIImage(named: "\(currWeatherOfCity.emoji)")
       
       return cell
    }
}
