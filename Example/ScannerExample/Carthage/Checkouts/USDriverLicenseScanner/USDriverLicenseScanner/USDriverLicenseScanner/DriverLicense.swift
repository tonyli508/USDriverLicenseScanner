//
//  DriverInfo.swift
//  Ridepool
//
//  Created by Li Jiantang on 12/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation

/// Driver license info represent
public class DriverLicense: CustomStringConvertible {
    
    static private let FIRST_NAME_KEY = "DAC"
    static private let MIDDLE_NAME_KEY = "DAD"
    static private let LAST_NAME_KEY = "DCS"
    static private let GIVEN_NAMES_KEY = "DCT"
    static private let LICENSE_STATE_KEY = "DAJ"
    static private let LICENSE_NUMBER_KEY = "DAQ"
    static private let DATE_OF_BIRTH_KEY = "DBB"
    static private let DATE_OF_EXPIRY_KEY = "DBA"
    
    public var firstName: String?
    public var middleName: String?
    public var lastName: String?
    public var licenseNumber: String?
    public var licenseState: String?
    public var dateOfBirth: Date?
    public var dateOfExpiry: Date?
    public var licenseCheckStatus: String?
    public var country: String = "US"
    
    /**
     Init with driver license info dictoinary
     
     - parameter infoPairs: info dictionary
     */
    init(FromScanedInfoPairs infoPairs: [String: String]) {
        
        if let _firstName = infoPairs[DriverLicense.FIRST_NAME_KEY] {
            
            firstName = _firstName
            middleName = readStringFrom(infoPairs, forKey: DriverLicense.MIDDLE_NAME_KEY)
            
        } else {
            
            let names = readStringFrom(infoPairs, forKey: DriverLicense.GIVEN_NAMES_KEY)
            let namesArray = names.components(separatedBy: " ")
            
            if namesArray.count > 1 {
                firstName = namesArray[0]
                middleName = namesArray[1]
            }
        }

        lastName = readStringFrom(infoPairs, forKey: DriverLicense.LAST_NAME_KEY)
        licenseState = readStringFrom(infoPairs, forKey: DriverLicense.LICENSE_STATE_KEY)
        licenseNumber = readStringFrom(infoPairs, forKey: DriverLicense.LICENSE_NUMBER_KEY)
        
        if let birthString = infoPairs[DriverLicense.DATE_OF_BIRTH_KEY] {
            dateOfBirth = DateUtils.dateFromString(birthString)
        }
        
        if let expiryString = infoPairs[DriverLicense.DATE_OF_EXPIRY_KEY] {
            dateOfExpiry = DateUtils.dateFromString(expiryString)
        }
    }
    
    private func readStringFrom(_ pairs: [String: String], forKey: String) -> String {
        
        if let value = pairs[forKey] {
            return value
        }
        
        return ""
    }
    
    /**
     String format date of birth
     
     - returns: date of birth string
     */
    public func dateOfBirthString() -> String {
        return DateUtils.stringFromDate(dateOfBirth)
    }
    
    /**
     String format date of expiry
     
     - returns: expiry string
     */
    public func dateOfExpiryString() -> String {
        return DateUtils.stringFromDate(dateOfExpiry)
    }
    
    public var description: String {
        get {
            return "fristName: \(String(describing: firstName)), middleName: \(String(describing: middleName)), lastName: \(String(describing: lastName)), licenseNumber: \(String(describing: licenseNumber)), licenseState: \(String(describing: licenseState)), dateOfBirth: \(String(describing: dateOfBirth)), dateOfExpiry: \(String(describing: dateOfExpiry))"
        }
    }
}
