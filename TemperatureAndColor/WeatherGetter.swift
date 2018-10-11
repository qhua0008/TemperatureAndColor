//
//  File.swift
//  TemperatureAndColor
//
//  Created by Qianyi Huang on 20/9/18.
//  Copyright © 2018 Aditi. All rights reserved.
//

import Foundation
protocol WeatherGetterDelegate {
    func didGetWeather(weather: String)
    func didNotGetWeather(error: NSError)
}
class WeatherGetter {
    
    private let openWeatherMapBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "aae40c6b6e2e10f9b0a0b5890c30c2c2"
    private var delegate: WeatherGetterDelegate
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    func getWeather(lat: Double, long: Double) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(long)")!
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL){
            (data, response, error) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                self.delegate.didNotGetWeather(error: error as NSError)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                print("Human-readable data:\n\(dataString!)")
                do {
                    // Try to convert that data into a Swift dictionary
                    let json = try JSONSerialization.jsonObject(
                        with: data!,
                        options: []) as! [String:Any]
                    let weather = json["weather"] as! [[String:Any]]
                    let weatherMain = weather[0]
                    print(weatherMain["main"] ?? "Weather service failed")
                    self.delegate.didGetWeather(weather: weatherMain["main"]! as! String)
                    
                }catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(error: jsonError)
                }
        }
        }
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
}
