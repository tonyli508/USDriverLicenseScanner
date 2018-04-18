//
//  DriverLicensePaser.swift
//  Ridepool
//
//  Created by Li Jiantang on 11/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation

/// Parse driver license string into data model
public class DriverLicenseParser: NSObject {
    
    private var pairs = [String: String]()
    
    // static US driver license barcode key length
    private let KEY_LENGTH = 3
    
    /**
     Check if given string is US dirver license format string
     
     - parameter codeString: codeString String
     
     - returns: whether string is a driver license format or not
     */
    public static func isDriverLicenseFormat(codeString: String) -> Bool {
        
        var startIndex = -1
        
        if let range = codeString.range(of: "@[^A-Za-z0-9]+ANSI", options: .regularExpression, range: nil, locale: nil) {
            startIndex = codeString.distance(from: codeString.startIndex, to: range.lowerBound)
        }
        
        return startIndex == 0
    }
    
    public init(SerialString string: String) {
        
        super.init()
        
        let lines = self.readLines(string)
        
        for line in lines {
            self.readPairFromLine(line)
        }
    }
    
    /**
     Give back basic driver info
     
     - returns: DriverInfo
     */
    public func driverInfo() -> DriverLicense? {
        return DriverLicense(FromScanedInfoPairs: pairs)
    }
    
    private func readLines(_ string: String) -> [String] {
        return string.components(separatedBy: "\n")
    }
    
    private func readPairFromLine(_ line: String) {
        if line.lengthOfBytes(using: .utf8) > KEY_LENGTH {
            let index = line.index(line.startIndex, offsetBy: KEY_LENGTH)
            
            let key = String(line[..<index])
            let value = String(line[index...])
            
            pairs[key] = value.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
    }
}
