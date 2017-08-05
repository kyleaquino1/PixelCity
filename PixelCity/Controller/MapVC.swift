//
//  MapVC.swift
//  PixelCity
//
//  Created by Kyle on 8/4/17.
//  Copyright © 2017 Kyle Aquino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    // Variables
    let screenSize = UIScreen.main.bounds
    var imageURLArray = [String]()
    
    // Instances
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.delegate = self
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeight.constant = VIEW_SIZE
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func animateViewDown() {
        pullUpViewHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: ((screenSize.width / 2) - ((spinner?.frame.width)! / 2)), y: VIEW_SIZE / 2)
        spinner?.color = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLabel = UILabel()
        
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "12 out of 40 photos loaded"
        progressLabel?.adjustsFontSizeToFitWidth = true
        progressLabel?.minimumScaleFactor = 0.5
        collectionView?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUser()
        }
    }
    
}

// MARK: - MAPVIEW

extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUser() {
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, REGION_DIAM, REGION_DIAM)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removeSpinner()
        removeProgressLabel()
        clearPins()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
        
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, REGION_DIAM, REGION_DIAM)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (true) in
            
        }
    }
    
    func clearPins() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping CompletionHandler) {
        
        imageURLArray.removeAll()
        
        Alamofire.request(FLICKR_URL(forApiKey: API_KEY, withAnnotation: annotation, numberOfPhotos: 40)).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let json = response.result.value as? Dictionary<String, Any> else { return }
                if let photos = json["photos"] as? Dictionary<String, Any> {
                    
                    if let photoArray = photos["photo"] as? [Dictionary<String, Any>] {
                        
                        for photo in photoArray {
                            let postURL = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                            self.imageURLArray.append(postURL)
                        }
                        print(self.imageURLArray)
                        completion(true)
                    }
                    
                }
                
            }
            
            
        }
        
    }
}
// MARK: - LOCATION

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        
        // Checks to see if we are authorized for location services
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUser()
    }
    
}

// MARK: - COLLECTION VIEW

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // bumber of items in array
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
    
}



























