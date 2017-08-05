//
//  DroppablePin.swift
//  PixelCity
//
//  Created by Kyle on 8/5/17.
//  Copyright © 2017 Kyle Aquino. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
        
    }
}
