//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//


import UIKit

extension FlickrAPIClient {
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        static let ApiKey = "804ded95eb26ab1d6b1118b93c128e04"
    }
    
    struct Methods {
        // MARK: Search
        static let Search = "flickr.photos.search"
    }
    
    struct HeaderKeys {
    }
    
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let Callback = "nojsoncallback"
        static let Format = "format"
        static let BBox = "bbox"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    struct URLKeys {
        static let Id = "id"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let PhotoId = "id"
        static let PhotoTitle = "title"
        static let PhotoFarm = "farm"
        static let PhotoServerId = "server"
        static let PhotoSecret = "secret"
    }
    
}


