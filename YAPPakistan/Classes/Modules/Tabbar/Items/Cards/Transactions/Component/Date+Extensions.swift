//
//  Date+Extensions.swift
//  YAPKit
//
//  Created by Zain on 19/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

extension Date {
    var appReadableString: String {
        return DateFormatter.appReadableDateFormatter.string(from: self)
    }
    
    var serverReadableString: String {
        return DateFormatter.serverReadableDateFromatter.string(from: self)
    }
    
    var userReadableDateString: String {
        return DateFormatter.userReadableDateFromatter.string(from: self)
    }
    
    func yearsSince(_ date: Date) -> Int? {
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: date, to: self)
        return ageComponents.year
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func date(byAddingMonths months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    var transactionSectionReadableDate: String {
        let dateFormatter = DateFormatter()
        let day: String
        let dayName: String
        if Date().startOfDay == self.startOfDay {
            day = "Today, "
            dayName = ""
        } else if Date().startOfDay.addingTimeInterval(-1 * 24 * 60 * 60) == self.startOfDay {
            day = "Yesterday, "
            dayName = ""
        } else {
            day = ""
            dayName = "EEEE, "
        }
        
        dateFormatter.dateFormat = dayName + "MMMM dd"
        return day + dateFormatter.string(from: self)
    }
 
    var transactionDetailsReadableDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy '・' hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: self)
    }
    
    var transactonNoteUserReadableDateString: String {
        DateFormatter.transactionNoteUserReadableDateFormatter.string(from: self)
    }
    
    func timeAgoSinceDate(numericDates: Bool = false) -> String {
           let calendar = NSCalendar.current
           let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
           let now = Date()
           let earliest = now < self ? now : self
           let latest = (earliest == now) ? self : now
           let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)
           
           if components.year! >= 2 {
               return "\(components.year!) " + "years ago"
           } else if components.year! >= 1 {
               if numericDates {
                   return "1 year ago"
               } else {
                   return "Last year"
               }
           } else if components.month! >= 2 {
               return "\(components.month!) " + "months ago"
           } else if components.month! >= 1 {
               if numericDates {
                   return "1 month ago"
               } else {
                   return "Last month"
               }
           } else if components.weekOfYear! >= 2 {
               return "\(components.weekOfYear!) " + "weeks ago"
           } else if components.weekOfYear! >= 1 {
               if numericDates {
                   return "1 week ago"
               } else {
                   return "Last week"
               }
           } else if components.day! >= 2 {
               return "\(components.day!) " + "days ago"
           } else if components.day! >= 1 {
               if numericDates {
                   return "1 day ago"
               } else {
                   return "Yesterday"
               }
           } else if components.hour! >= 2 {
               return "\(components.hour!) " + "hours ago"
           } else if components.hour! >= 1 {
               if numericDates {
                   return "1 hour ago"
               } else {
                   return "An hour ago"
               }
           } else if components.minute! >= 2 {
               return "\(components.minute!) " + "minutes ago"
           } else if components.minute! >= 1 {
               if numericDates {
                   return "1 minute ago"
               } else {
                   return "A minute ago"
               }
           } else if components.second! >= 3 {
               return "\(components.second!) " + "seconds ago"
           } else {
               return "Just now"
           }
       }
    
    var refferalTimeString: String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    var leanPlumDateAndTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GST")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    var leanPlumDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GST")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    var householdServerDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GST")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func localizedStringOfDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd, yyyy"
        return dateFormatter.string(from: self)
    }
}
