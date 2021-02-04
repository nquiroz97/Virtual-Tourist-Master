//
//  TravelLocationsMapView.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add Gesture Recognizer to map
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.delegate = self
        
        // fetch request
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
        
    }
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude.magnitude
            pin.longitude = coordinate.longitude.magnitude
            do {
                try dataController.viewContext.save()
            }catch{
                print("error")
            }
            pins.append(pin)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func addAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the photoAlbumView
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumView
        destination!.coordinate = view.annotation?.coordinate
        
        for pin in pins {
            if pin.latitude.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                destination!.selectedPin = pin
            }
        }
        destination?.dataController = dataController
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    
}
