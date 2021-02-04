//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/17/20.
//

import Foundation

struct FlickrPhoto {
    public let id: Int
    public let title: String
    public let photoUrl: String
    
    init(dictionary: [String:AnyObject]) {
        if let id = dictionary[FlickrAPIClient.JSONResponseKeys.PhotoId] as? String {
            debugPrint("--- ID: \(id)")
            self.id = Int(id)!
        } else {
            self.id = 0
            debugPrint("--- ID is NIL!")
        }
        if let title = dictionary[FlickrAPIClient.JSONResponseKeys.PhotoTitle] as? String {
            debugPrint("--- Title: \(title)")
            self.title = title
        } else {
            self.title = ""
            debugPrint("--- Title is NIL!")
        }
        
        let farm = dictionary[FlickrAPIClient.JSONResponseKeys.PhotoFarm] as! Int
        let server = dictionary[FlickrAPIClient.JSONResponseKeys.PhotoServerId] as! String
        let secret = dictionary[FlickrAPIClient.JSONResponseKeys.PhotoSecret] as! String
        
        self.photoUrl = "https://farm\(farm).staticflickr.com/\(server)/\(self.id)_\(secret).jpg"
        debugPrint(self.photoUrl)
    }
    
    static func flickrPhotosFrom(_ results: [String:AnyObject]) -> [FlickrPhoto] {
        var flickrPhotos = [FlickrPhoto]()
        
        if let photosObject = results[FlickrAPIClient.JSONResponseKeys.Photos] as? [String:AnyObject] {
            if let photosArray = photosObject[FlickrAPIClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                for result in photosArray {
                    debugPrint("\(result)")
                    flickrPhotos.append(FlickrPhoto(dictionary: result))
                }
            }
        }
        
        return flickrPhotos
    }
}
