//
//  ViewController.swift
//  PokeFinder
//
//  Created by Stephan Dowless on 2/2/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var selectedPokemon: Int!
    var pokeLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
        
        if let location = pokeLocation, let poke = selectedPokemon {
            createSighting(forLocation: location, withPokemon: poke)
            showSightingsOnMap(location: location)
            centerMapOnLocation(location: location)
        }
    }
    
    
    //Function that determines enabled status of location services
    //If enabled -> show user location = true 
    //Else -> Request user location when in use
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //Define coordinate region then set coordinate region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Function used to update user location.
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if  mapHasCenteredOnce == false {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    //function to create custom user location icon
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        let annoIdentifier = "Poke"
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    //Creates sighting for pokemon with a location and corresponding pokemon id, which is used as a key
    func createSighting(forLocation location: CLLocation, withPokemon pokeID: Int) {
        
        geoFire.setLocation(location, forKey: "\(pokeID)")
    }
    
    //Functions that grabs the location and key for that location from createSighting, runs a query at that location with
    //a given radius, creates annotation and adds that annotation to the map view. Annotation is then defined based on
    //mapView forAnnotation function
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let key = key, let location = location {
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                self.mapView.addAnnotation(anno)
            }
            
        })
    }
    
    //Updates mapview when region is changed
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PokeAnnotation {
            
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
        
    }
    
    @IBAction func spotRandomPokemon(_ sender: UIButton) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        pokeLocation = loc
        
        performSegue(withIdentifier: "PokemonSelect", sender: pokeLocation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonSelect" {
            let destination = segue.destination as! PokemonSelectVC
            if let pokeLoc = sender as? CLLocation {
                destination.pokeLocation = pokeLoc
            }
        }
    }

}



