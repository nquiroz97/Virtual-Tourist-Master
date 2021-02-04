//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import Foundation
import UIKit

class FlickrAPIClient: NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    var dataController: DataController!
    
    // MARK: Init
    override init() {
        super.init()
    }
    
    // MARK: GET
    func taskForGETMethod(_ method: String, parameters: [String : AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        var parametersWithApiKey = parameters
        parametersWithApiKey[FlickrAPIClient.ParameterKeys.Method] = method as AnyObject
        parametersWithApiKey[FlickrAPIClient.ParameterKeys.Callback] = "1" as AnyObject
        parametersWithApiKey[FlickrAPIClient.ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject
        
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parametersWithApiKey, withPathExtension: ""))
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: GET Image
    func taskForGETImage(filePath: String, completionHandlerForImage: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) -> URLSessionTask {
        let url = URL(string: filePath)!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImage(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForImage(data, nil)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = FlickrAPIClient.Constants.ApiScheme
        components.host = FlickrAPIClient.Constants.ApiHost
        components.path = FlickrAPIClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrAPIClient {
        struct Singleton {
            static var sharedInstance = FlickrAPIClient()
        }
        return Singleton.sharedInstance
    }
    
}
extension FlickrAPIClient{
    func getLocationPhotos(pin: Pin, latitude: Double, longitude: Double, _ completionHandlerForSearch: @escaping (_ result: [Photo]?, _ error: NSError?) -> Void) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        let stack = sceneDelegate.dataController
        
        let boxLatLeft = latitude - 1
        let boxLngLeft = longitude - 1
        let boxLatRight = latitude + 1
        let boxLngRight = longitude + 1
        let bBox = "\(boxLngLeft),\(boxLatLeft),\(boxLngRight),\(boxLatRight)"
        
        let randomNum: UInt32 = arc4random_uniform(10)
        let randomPage: Int = Int(randomNum)
        
        let parameters = [
            ParameterKeys.PerPage: 10,
            ParameterKeys.BBox: bBox,
            ParameterKeys.Format: "json",
            ParameterKeys.Page: randomPage
        ] as [String : Any]
        let method: String = Methods.Search
        
        let _ = taskForGETMethod(method, parameters: parameters as [String:AnyObject]) {(results, error) in
            if let error = error {
                completionHandlerForSearch(nil, error)
            } else {
                if let results = results as? [String:AnyObject] {
                    let flickrPhotos = FlickrPhoto.flickrPhotosFrom(results)
                    var photos: [Photo] = [Photo]()
                    for flickrPhoto in flickrPhotos {
                        let photo = Photo(title: flickrPhoto.title, flickrId: String(flickrPhoto.id),  flickrUrl: flickrPhoto.photoUrl, data: nil, stack.context)
                        photo.pin = pin
                        photos.append(photo)
                    }
                    completionHandlerForSearch(photos, nil)
                } else {
                    completionHandlerForSearch(nil, NSError(domain: "search parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse FlickrPhotos"]))
                }
            }
        }
    }
}
