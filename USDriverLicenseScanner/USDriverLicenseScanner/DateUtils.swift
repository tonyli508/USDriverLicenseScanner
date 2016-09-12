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
    static func defaultTimeZone() -> NSTimeZone? {
        return NSTimeZone.localTimeZone()
    }
    
    /**
     Get current selected timeZone
     
     try to use specified first
     if not set then use defaultTimeZone func one
     if not set then use localTimeZone
     
     - parameter timeZone: NSTimeZone
     
     - returns: NSTimeZone
     */
    static func selectedTimeZone(timeZone: NSTimeZone?) -> NSTimeZone {
        return timeZone ?? defaultTimeZone() ?? NSTimeZone.localTimeZone()
    }
    
    /**
    Format date into string with specified format
    
    - parameter date:         date need to format
    - parameter formatString: formatting string
    
    - returns: String
    */
    static func stringFromDate(date: NSDate?, Format formatString: String = "MMddyyyy", TimeZone timeZone: NSTimeZone? = nil, Locale locale: NSLocale? = nil) -> String {
        let formatter = NSDateFormatter()
        formatter.timeZone = selectedTimeZone(timeZone)
        formatter.dateFormat = formatString
        if locale != nil {
            formatter.locale = locale!
        }
        
        var string = ""
        
        if let _date = date {
            string = formatter.stringFromDate(_date)
        }
        
        return string
    }
    
    static func stringFromDate(date: NSDate?, Format format: DateFormats, TimeZone timeZone: NSTimeZone? = nil, Locale locale: NSLocale? = nil) -> String {
        return stringFromDate(date, Format: format.rawValue, TimeZone: timeZone, Locale: locale)
    }
    
    /**
    Format string into NSDate with specified format
    
    - parameter dateString:   date in string format
    - parameter formatString: formatting string
    
    - returns: NSDate
    */
    static func dateFromString(dateString: String, Format formatString: String = "MMddyyyy", TimeZone timeZone: NSTimeZone? = nil) -> NSDate? {
        
        let formatter = NSDateFormatter()
        formatter.timeZone = selectedTimeZone(timeZone)
        formatter.dateFormat = formatString
        
        if !dateString.isEmpty {
            if let date = formatter.dateFromString(dateString) {
                return date
            }
        }
        
        return nil
    }
    
    static func dateFromString(dateString: String, Format format: DateFormats, TimeZone timeZone: NSTimeZone? = nil) -> NSDate? {
        return dateFromString(dateString, Format: format.rawValue, TimeZone: timeZone)
    }
}