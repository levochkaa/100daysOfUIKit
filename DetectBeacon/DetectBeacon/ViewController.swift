// ViewController.swift

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?

    @IBOutlet var distanceReading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }

    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            print("Distance: \(distance)")
            switch distance {
                case .unknown:
                    self.view.backgroundColor = UIColor.gray
                    self.distanceReading.text = "UNKNOWN"
                case .far:
                    self.view.backgroundColor = UIColor.blue
                    self.distanceReading.text = "FAR"
                case .near:
                    self.view.backgroundColor = UIColor.orange
                    self.distanceReading.text = "NEAR"
                case .immediate:
                    self.view.backgroundColor = UIColor.red
                    self.distanceReading.text = "RIGHT HERE"
                default:
                    self.view.backgroundColor = UIColor.gray
                    self.distanceReading.text = "UNKNOWN"
            }
        }
    }

    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconIndetityConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "Beacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconIndetityConstraint)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Beacons: \(beacons)")
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations: \(locations)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}

