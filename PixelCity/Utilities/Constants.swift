//
//  Constants.swift
//  PixelCity
//
//  Created by Kyle on 8/5/17.
//  Copyright © 2017 Kyle Aquino. All rights reserved.
//

import UIKit



// Distance Constants
let REGION_RAD: Double = 1000
let REGION_DIAM: Double = REGION_RAD * 2.0
let VIEW_SIZE: CGFloat = 300

// API STUFF
let API_KEY = "8a2e2ea63ef5e61e8717aa95badf6abd"
let SECRET = "8d8accf150789e04"


func FLICKR_URL(forApiKey key: String, withAnnotation annotation: DroppablePin, numberOfPhotos number: Int ) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

// Reuse Identifiers
let DROP_PIN = "droppablePin"
let PHOTO_CELL = "photoCell"

// Completion Handler
typealias CompletionHandler = (_ status: Bool) -> ()
