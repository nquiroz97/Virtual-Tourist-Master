//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumView: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    // Pin
    var selectedPin: Pin?
    // FlickrPhotos
    var photos: [Photo] = [Photo]()
    // Data Stack
    var dataController: DataController?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        _ = sceneDelegate.dataController
        
        initMap()
        
        if (selectedPin?.photos?.count)! <= 0 {
            loadPhotos()
        } else {
            photos = (selectedPin?.photos)!.allObjects as! [Photo]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photosCollectionView?.reloadData()
    }
    
    
    // MARK: Initializers
    func initMap() {
        mapView.delegate = self
        mapView.addAnnotation(selectedPin!)
        mapView.centerCoordinate = selectedPin!.coordinate
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    // MARK: Fetch Photos
    func loadPhotos() {
        FlickrAPIClient.sharedInstance().getLocationPhotos(pin: selectedPin!, latitude: selectedPin!.latitude, longitude: selectedPin!.longitude) { (_ result: [Photo]?, _ error: NSError?) in
            self.photos = result!
            performUIUpdatesOnMain {
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    // MARK: IBAction
    @IBAction func newCollection(_ sender: Any) {
        for photo in photos {
            dataController?.context.delete(photo)
        }
        photos = [Photo]()
        photosCollectionView.reloadData()
        loadPhotos()
    }
}

// MARK: MKMapViewDelegate
extension PhotoAlbumView {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}


extension PhotoAlbumView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        let flickrPhoto = photos[indexPath.row]
        let photoUrl = flickrPhoto.flickrUrl
        cell.photo.image = UIImage(named: "placeholder")
        
        if let data = flickrPhoto.data {
            let image = UIImage(data: data as Data)
            cell.photo.image = image
            cell.hideLoading()
        } else {
            cell.showLoading()
            let _ = FlickrAPIClient.sharedInstance().taskForGETImage(filePath: photoUrl!, completionHandlerForImage: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    performUIUpdatesOnMain {
                        cell.hideLoading()
                        flickrPhoto.data = imageData! as NSData
                        try? self.dataController?.context.save()
                        cell.photo.image = image
                    }
                } else {
                    debugPrint("Error loading image: \(String(describing: error))")
                }
            })
            
        }
        print("cell")
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        dataController?.context.delete(photo)
        photos.remove(at: indexPath.row)
        photosCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
}



