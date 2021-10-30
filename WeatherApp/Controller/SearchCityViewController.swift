//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Alivia Guin on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift
import PromiseKit

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource {

    var arrCityInfo : [CityInfo] = [CityInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count < 3
        {
            return
        }
        print(searchText)
        getCitiesFromSearch(searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let city = arrCityInfo[indexPath.row]
        cell.textLabel?.text = "\(city.localizedName) \(city.administrativeID), \(city.countryLocalizedName)"
        return cell
    }
    
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        
        let url = getSearchURL(searchText)
        print(url)
        
    
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error!)
            }
            
            let citiesArr = JSON( response.data! ).array
            print(citiesArr!)
            
            
            for city in citiesArr! {
                let cityInfo = CityInfo()
                cityInfo.key = city["Key"].stringValue
                cityInfo.type = city["Type"].stringValue
                cityInfo.localizedName = city["LocalizedName"]["ID"].stringValue
                cityInfo.countryLocalizedName = city["Country"].stringValue
                cityInfo.administrativeID = city["AdministrativeArea"]["ID"].stringValue
                               
                self.arrCityInfo.append(cityInfo)
             }
                           
            self.tblView.reloadData()
        }
            
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cityDetail = arrCityInfo[indexPath.row]
        addCityInDB(cityDetail)
               
        navigationController?.popViewController(animated: true)
    }
    
    func addCityInDB(_ cityInfo : CityInfo){
        do{
            let realm = try Realm()
            try realm.write({
                realm.add(cityInfo, update: .modified)
            })
        } catch {
            print("Error getting values from DB \(error)")
        }
    }
}
