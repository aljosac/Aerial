//
//  time.swift
//  Aerial
//
//  Created by Aljosa Cucak on 10/29/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

import Foundation
import CoreLocation

class Time:NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    func radtodeg (x:Double) -> Double {
        return (x * 180) / M_PI
    }
    func degtorad (x:Double) -> Double {
        return (x * M_PI) / 180.0
    }
    
    // returns the Julian Date in seconds
    func julianDate() -> Double {
        let julianSecTo1970 = 1445729957.0
        let currentTime = NSDate()
        return julianSecTo1970 + currentTime.timeIntervalSince1970
    }

    // returns the Julian day
    func currentJulianDay() -> Int {
        let currentDate = julianDate()
        return Int(currentDate - 2451545.0 + 0.0008)
    }
    
    // returns the current Longitude: west of meridian is positive and east is negitive
    func currentLong() -> Double{
        if (CLLocationManager.authorizationStatus() == .Authorized){
            return -1 * (locationManager.location?.coordinate.longitude)!
        }
        return 0.0
    }
    
    func currentLat() -> Double {
        if (CLLocationManager.authorizationStatus() == .Authorized){
            return 1.0 * (locationManager.location?.coordinate.latitude)!
        }
        return 0.0
    }
    
    func meanSolarNoon() -> Double {
        return (currentLong()/360) + Double(currentJulianDay())
    }
    
    // return value is in Degrees
    func solarMeanAnomaly() -> Double {
        return (357.5291 + 0.98560028 * meanSolarNoon()) % 360
    }
    
    func equationOfTheCenter() -> Double {
        let m = degtorad(solarMeanAnomaly())
        return 1.9148 * sin(m) + 0.02 * sin(2*m) + 0.0003 * sin(3 * m)
    }
    
    func eclipticLongitude() -> Double {
        return (solarMeanAnomaly() + equationOfTheCenter() + 180 + 102.9372) % 360
    }
    
    func solarTransit() -> Double {
        let m = degtorad(solarMeanAnomaly())
        return 2451545 + meanSolarNoon() + 0.0053 * sin(m) - 0.0069 * sin(2 * degtorad(eclipticLongitude()))
    }
    
    func declinationOfSun() -> Double {
        let dos = sin(degtorad(eclipticLongitude())) * sin(degtorad(23.44))
        return asin(dos)
    }
    
    func hourAngle() -> Double {
        let lat = currentLat()
        let a = (sin(degtorad(-0.83)) - sin(lat)*sin(declinationOfSun()))/cos(lat)*cos(declinationOfSun())
        return acos(a)
    }
    
    // returns the julian date as sunrise
    func getSunrise() -> Double {
        return solarTransit() - (radtodeg(hourAngle())/360)
    }
    
    // return the julian date as sunset
    func getSunSet() -> Double {
        return solarTransit() + (radtodeg(hourAngle())/360)
    }
    
    func isDay() -> Bool {
        let rise = getSunrise()
        let set = getSunSet()
        let current = julianDate()
        
        return rise < current && current < set
    }
    
    
}