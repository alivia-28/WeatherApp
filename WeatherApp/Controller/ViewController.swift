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
    
    func getCityNameFromDB(_ cityKey : String) -> String?{
       do{
           let realm = try Realm()
           let city = realm.object(ofType: CityInfo.self, forPrimaryKey: cityKey)
           return city?.localizedName
       }
       catch{
           print("Error in reading Database \(error)")
       }
       return "value"
    }
        
        
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
        return Promise<CurrentWeather> { seal -> Void in
            let url = "\(currentConditionURL)\(cityKey)?apikey=\(apiKey)" 
            
            AF.request(url).responseJSON { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let weatherJSON = JSON(response.data!).array
                
                guard let firstWeather = weatherJSON!.first else {seal.fulfill(CurrentWeather())
                    return
                }
                
                let currentWeather = CurrentWeather()
                currentWeather.cityKey = cityKey
                currentWeather.cityInfoName = firstWeather["CityInfoName"].stringValue
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

