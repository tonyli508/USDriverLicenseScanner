//
//  DateUtils.swift
//  Ridepool
//
//  Created by Li Jiantang on 12/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import UIKit

class DateUtils: NSObject {
    
    // We may put all common format in here and give them meaningful names, so can be eazily access
    enum DateFormats: String {
        case MMddyyyy = "MMddyyyy"
        case mediumStyle = "EEE d MMM h:mm a"
        case HighToLowStyle = "yyyy-MM-dd HH:mm:ss"
        case timeOnly = "h:mm a"
        case dateOnly = "EEE d MMM"
        case dateAndYear = "EEE d MMM yyyy"
    }
    
    /**
     Get current TimeZone for using DateUtils
     
     override this to change default timezone when subclass
     
     - returns: NSTImeZone or nil, If failed to specify one
     */
    static func defaultTimeZone() -> TimeZone? {
        return TimeZone.current
    }
    
    /**
     Get current selected timeZone
     
     try to use specified first
     if not set then use defaultTimeZone func one
     if not set then use localTimeZone
     
     - parameter timeZone: NSTimeZone
     
     - returns: NSTimeZone
     */
    static func selectedTimeZone(_ timeZone: TimeZone?) -> TimeZone {
        return timeZone ?? defaultTimeZone() ?? TimeZone.current
    }
    
    /**
    Format date into string with specified format
    
    - parameter date:         date need to format
    - parameter formatString: formatting string
    
    - returns: String
    */
    static func stringFromDate(_ date: Date?, Format formatString: String = "MMddyyyy", TimeZone timeZone: TimeZone? = nil, Locale locale: Locale? = nil) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = selectedTimeZone(timeZone)
        formatter.dateFormat = formatString
        if locale != nil {
            formatter.locale = locale!
        }
        
        var string = ""
        
        if let _date = date {
            string = formatter.string(from: _date)
        }
        
        return string
    }
    
    static func stringFromDate(date: Date?, Format format: DateFormats, TimeZone timeZone: TimeZone? = nil, Locale locale: Locale? = nil) -> String {
        return stringFromDate(date, Format: format.rawValue, TimeZone: timeZone, Locale: locale)
    }
    
    /**
    Format string into NSDate with specified format
    
    - parameter dateString:   date in string format
    - parameter formatString: formatting string
    
    - returns: NSDate
    */
    static func dateFromString(_ dateString: String, Format formatString: String = "MMddyyyy", TimeZone timeZone: TimeZone? = nil) -> Date? {
        
        let formatter = DateFormatter()
        formatter.timeZone = selectedTimeZone(timeZone)
        formatter.dateFormat = formatString
        
        if !dateString.isEmpty {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    static func dateFromString(_ dateString: String, Format format: DateFormats, TimeZone timeZone: TimeZone? = nil) -> Date? {
        return dateFromString(dateString, Format: format.rawValue, TimeZone: timeZone)
    }
}
