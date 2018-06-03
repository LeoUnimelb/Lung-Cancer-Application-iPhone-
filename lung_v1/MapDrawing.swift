import UIKit
import MapKit

class MapDrawing: UIViewController {
  
  weak var Map: MKMapView!
  
  var exercise: Exercise!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadMap()
  }
  
  private func loadMap() {
    guard
      let locations = exercise.locations,
      locations.count > 0,
      let region = mapRegion()
      else {
        let alert = UIAlertController(title: "Error",
                                      message: "Sorry, this exercise has no locations saved",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
        return
    }
    
    Map.setRegion(region, animated: true)
    Map.add(polyLine())
  }
  
  
  private func mapRegion() -> MKCoordinateRegion? {
    guard
      let locations = exercise.locations,
      locations.count > 0
    else {
      return nil
    }
    
    let latitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.latitude
    }
    
    let longitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.longitude
    }
    
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
    
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                        longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                longitudeDelta: (maxLong - minLong) * 1.3)
    return MKCoordinateRegion(center: center, span: span)
  }
  
  private func polyLine() -> MKPolyline {
    guard let locations = exercise.locations else {
      return MKPolyline()
    }
    
    let coords: [CLLocationCoordinate2D] = locations.map { location in
      let location = location as! Location
      return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    return MKPolyline(coordinates: coords, count: coords.count)
  }
}

