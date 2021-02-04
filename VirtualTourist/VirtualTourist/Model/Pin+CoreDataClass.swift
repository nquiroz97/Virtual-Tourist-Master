//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/17/20.
//

import Foundation
import CoreData
import MapKit


@objc(Pin)
public class Pin: NSManagedObject, MKAnnotation {
    convenience init(latitude: Double = 0, longitude: Double = 0, _ context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
