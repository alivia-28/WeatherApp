//
//  CityTableViewCell.swift
//  WeatherApp
//
//  Created by Alivia Guin on 10/29/21.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCityName: UILabel!
    
    @IBOutlet weak var lblWeather: UILabel!
    
    @IBOutlet weak var lblTemperature: UILabel!
    
    @IBOutlet weak var lblImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
