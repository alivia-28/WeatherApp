//
//  ViewController.swift
//  WeatherApp
//
//  Created by Alivia Guin on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let arr = ["Seattle WA, USA 54 ℉", "Delhi DL, India, 75℉"]
    
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentCondition()
    }
    
    func loadCurrentCondition() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
                // for each city info het the city key and make a NW call to current weather condition
                // wait for all the promises to be fulfilled
                // Once all the promises are fulfilled fill the arrCurrentWeather array
                // call for reload of tableView
                
             do{
                  let realm = try Realm()
                  let cities = realm.objects(CityInfo.self)
                  self.arrCityInfo.removeAll()
                  if cities.isEmpty {return}
                    
                  getAllCurrentWeather(Array(cities)).done { currentWeather in
                       self.arrCurrentWeather.append(contentsOf: currentWeather)
                       self.tblView.reloadData()
                  }
                  .catch { error in
                       print(error)
                  }
              } catch {
                   print("Error in reading Database \(error)")
              }
                
    }
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
                
        var promises: [Promise< CurrentWeather>] = []
        
        for i in 0 ... cities.count - 1 {
            promises.append( getCurrentWeather(cities[i].key) )
        }
        
        return when(fulfilled: promises)
        
    }
    
    func getCityNameFromDb(_ cityKey : String) -> String?{
       do{
           let realm = try Realm()
           let city = realm.object(ofType: CityInfo.self, forPrimaryKey: cityKey)
           return city?.localizedName
       }
       catch{
           print("Error in reading Database \(error)")
       }
       return "Unnamed"
    }
        
        
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
        return Promise<CurrentWeather> { seal -> Void in
            let url = "\(currentConditionURL)\(cityKey)?apikey=\(apiKey)" 
            
            AF.request(url).responseJSON { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let weatherJSON = JSON(response.data!).array
                print(weatherJSON)
                
                guard let firstWeather = weatherJSON!.first else {seal.fulfill(CurrentWeather())
                    return
                }
                
                let currentWeather = CurrentWeather()
                currentWeather.cityKey = cityKey
                //getCityNameFromDb("")
                //currentWeather.cityInfoName = self.getCityNameFromDB(cityKey) ?? "Unnamed"
                currentWeather.weatherText = firstWeather["WeatherText"].stringValue
                currentWeather.epochTime = firstWeather["EpochTime"].intValue
                currentWeather.isDayTime = firstWeather["IsDayTime"].boolValue
                currentWeather.temp = firstWeather["Temperature"]["Metric"]["Value"].intValue
                currentWeather.emoji = firstWeather["WeatherIcon"].intValue
                seal.fulfill(currentWeather)
                print(currentWeather.weatherText)
                
            }
        }
    }


}

