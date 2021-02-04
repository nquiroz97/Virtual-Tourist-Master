//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/17/20.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var flickrId: String?
    @NSManaged public var flickrUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
