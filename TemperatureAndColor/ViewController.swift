//
//  ViewController.swift
//  TemperatureAndColor
//
//  Created by Aditi on 18/09/18.
//  Copyright © 2018 Aditi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, WeatherGetterDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var weather: WeatherGetter!
    var handle: DatabaseHandle!
    
    var temp: Double?
    var red: Int?
    var green: Int?
    var blue:Int?
    
    var imageList = [UIImage]()
    
    var databaseRef = Database.database().reference().child("raspio")
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    
    @IBAction func updateWeather(_ sender: Any) {
        if  currentLocation == nil {
            displayErrorMessage("Please Open Your Location for weather service.")
            return
        }
        weather.getWeather(lat: (currentLocation?.latitude)!, long: (currentLocation?.longitude)!)
    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
        } catch {
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather = WeatherGetter(delegate: self)
        weatherLabel.textAlignment = NSTextAlignment.left
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //retrieve data from database
        databaseRef.observe(.value, with: { (snapshot) in
            if(snapshot.exists()) {
                let array: NSArray = snapshot.children.allObjects as NSArray
                
                
                for obj in array {
                    let snapshot: DataSnapshot = obj as! DataSnapshot
                    if let childSnapshot = snapshot.value as? [String : AnyObject]
                    {
                        if let temp1 = childSnapshot["Thermometer:celsius"] {
                            self.temp = temp1 as? Double
                        }
                        if let red1 = childSnapshot["Red"] {
                            self.red = red1 as? Int
                        }
                        if let green1 = childSnapshot["Green"] {
                            self.green = green1 as? Int
                        }
                        if let blue1 = childSnapshot["Blue"] {
                            self.blue = blue1 as? Int
                        }
                    }
                }
                
                if (self.temp != nil) {
                    let temp = Double(round(Double(self.temp!)*100)/100)
                    self.temperatureLabel.text = String(temp) + "°C"
                }
                if (self.red != nil && self.green != nil && self.blue != nil) {
                    self.drawSun()
             
                }
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    //draw sun
    func drawSun(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        let red = Double(round(Double(self.red!)/65535*100)/100)
        let green = Double(round(Double(self.green!)/65535*100)/100)
        let blue = Double(round(Double(self.blue!)/65535*100)/100)
        let circleColor=UIColor(red:CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        //change the fill color
        shapeLayer.fillColor = circleColor.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = circleColor.cgColor

        shapeLayer.lineWidth = 100.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    
    func didGetWeather(weather: String){
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the code
        // that updates all the labels in a dispatch_async() call.
        DispatchQueue.main.async() {
            self.weatherLabel.text = weather
        }
        
    }
    
    func didNotGetWeather(error: NSError) {
        displayErrorMessage("\(error)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let loc: CLLocation = locations.last!
        currentLocation = loc.coordinate
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

