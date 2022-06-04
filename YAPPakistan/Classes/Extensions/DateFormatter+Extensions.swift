//
//  DateFormatter+Extensions.swift
//  YAPKit
//
//  Created by Zain on 22/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

extension DateFormatter {

    public static var appReadableDateFormat: String {
        return "dd/MM/yyyy"
    }

    public static var serverReadableDateFormat: String {
        return "yyyy-MM-dd"
    }
    
    public static var statementReadableDateFormat: String {
        return "dd-MM-yyyy"
    }

    public static var serverReadableDateTimeFormat: String {
        return "yyyy-MM-dd'T'HH:mm:ss"
    }

    public static var userReadableDateFormate: String {
        return "dd MMMM, yyyy"
    }

    private static func formatter(withDateFromate dateFormate: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormate
        return dateFormatter
    }

    public static var graphDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter
    }

    public static var graphMonthDateFormatter: DateFormatter {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMMM yyyy"
         return dateFormatter
     }

    public static var appReadableDateFormatter: DateFormatter {
        return formatter(withDateFromate: appReadableDateFormat)
    }

    public static var serverReadableDateFromatter: DateFormatter {
        return formatter(withDateFromate: serverReadableDateFormat)
    }

    public static var serverReadableDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = serverReadableDateTimeFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }

    public static var userReadableDateFromatter: DateFormatter {
        return formatter(withDateFromate: userReadableDateFormate)
    }

    public static var transactionDateFormatter: DateFormatter {
        let expiryDateFormatter = DateFormatter()
        expiryDateFormatter.dateFormat = serverReadableDateTimeFormat
        expiryDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return expiryDateFormatter
    }

    public static var transferDateFormatter: DateFormatter {
        let expiryDateFormatter = DateFormatter()
        expiryDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        expiryDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return expiryDateFormatter
    }

    public static var transactionNoteUserReadableDateFormatter: DateFormatter {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MMM dd, yyyy • hh:mm a"
        dateTimeFormatter.amSymbol = "AM"
        dateTimeFormatter.pmSymbol = "PM"
        return dateTimeFormatter
    }

    public static var referralsDateFormatter: DateFormatter {
        let expiryDateFormatter = DateFormatter()
        expiryDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        expiryDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return expiryDateFormatter
    }
}
