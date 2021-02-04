//
//  MapView.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/17/20.
//

import UIKit
import MapKit
import CoreData

class MapView: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    // Annotations
    var annotations: [MKAnnotation] = [MKAnnotation]()
    // Pins
    var pins: [Pin] = [Pin]()
    var selectedPin: Pin?
    // Stack
    var dataController: DataController?
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pins = fetchPins()
        
        mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapView.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        populateMap()
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            let collectionVC = segue.destination as! PhotoAlbumView
            collectionVC.selectedPin = self.selectedPin
        }
    }
    
    // MARK: Pin and Annotations
    func populateMap() {
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    func createPin(_ location: CLLocationCoordinate2D) -> Pin {
        let pin: Pin = Pin(latitude: location.latitude, longitude: location.longitude, dataController!.context)
        try? dataController!.context.save()
        return pin
    }
    
    func fetchPins() -> [Pin] {
        var pins = [Pin]()
        
        
        do {
            let results = try dataController?.context.fetch(fetchRequest) as! [Pin]
            pins = results
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)")
        }
        
        return pins
    }
    
}

extension MapView {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        selectedPin = view.annotation as? Pin
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    }
    
}

extension MapView {
    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizer.State.began {
            return
        }
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        mapView.addAnnotation(createPin(touchCoordinate))
    }
}
