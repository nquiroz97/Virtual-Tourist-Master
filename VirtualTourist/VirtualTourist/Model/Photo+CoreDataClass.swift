//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/17/20.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(title: String, flickrId: String, flickrUrl: String, data: NSData?, _ context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.flickrId = flickrId
            self.flickrUrl = flickrUrl
            self.data = data
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
