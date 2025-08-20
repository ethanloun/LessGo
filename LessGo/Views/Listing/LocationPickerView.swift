import SwiftUI
import MapKit

struct LocationPickerView: UIViewControllerRepresentable {
    let onLocationSelected: (Location) -> Void
    
    func makeUIViewController(context: Context) -> LocationPickerViewController {
        let controller = LocationPickerViewController()
        controller.onLocationSelected = onLocationSelected
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LocationPickerViewController, context: Context) {}
}

class LocationPickerViewController: UIViewController {
    var onLocationSelected: ((Location) -> Void)?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let confirmButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup navigation
        title = "Select Location on Map"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a location"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup map view
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)
        
        // Setup confirm button
        confirmButton.setTitle("Confirm Location", for: .normal)
        confirmButton.backgroundColor = UIColor.label
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmLocationTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add tap gesture to map
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func confirmLocationTapped() {
        let center = mapView.centerCoordinate
        
        // Reverse geocode to get actual address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: center.latitude, longitude: center.longitude)) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let location = Location(
                        latitude: center.latitude,
                        longitude: center.longitude,
                        address: placemark.thoroughfare ?? "Selected Location",
                        city: placemark.locality ?? "Unknown",
                        state: placemark.administrativeArea ?? "Unknown",
                        zipCode: placemark.postalCode ?? "Unknown"
                    )
                    self?.onLocationSelected?(location)
                } else {
                    // Fallback location if geocoding fails
                    let location = Location(
                        latitude: center.latitude,
                        longitude: center.longitude,
                        address: "Selected Location",
                        city: "Unknown",
                        state: "Unknown",
                        zipCode: "Unknown"
                    )
                    self?.onLocationSelected?(location)
                }
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Selected Location"
        mapView.addAnnotation(annotation)
    }
}

// MARK: - UISearchResultsUpdating
extension LocationPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                if let response = response {
                    self?.mapView.setRegion(response.boundingRegion, animated: true)
                    
                    // Add annotation for first result
                    if let firstItem = response.mapItems.first {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = firstItem.placemark.coordinate
                        annotation.title = firstItem.name
                        annotation.subtitle = firstItem.placemark.title
                        
                        self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                        self?.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "LocationPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }
}

#Preview {
    LocationPickerView { _ in }
}
