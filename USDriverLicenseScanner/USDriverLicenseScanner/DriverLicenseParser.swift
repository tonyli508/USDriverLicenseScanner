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
        
        if let range = codeString.rangeOfString("@[^A-Za-z0-9]+ANSI", options: .RegularExpressionSearch) {
            startIndex = codeString.startIndex.distanceTo(range.startIndex)
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
    
    private func readLines(string: String) -> [String] {
        return string.componentsSeparatedByString("\n")
    }
    
    private func readPairFromLine(line: String) {
        if line.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > KEY_LENGTH {
            let index = line.startIndex.advancedBy(KEY_LENGTH)
            let key = line.substringToIndex(index)
            let value = line.substringFromIndex(index)
            
            pairs[key] = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }
}
