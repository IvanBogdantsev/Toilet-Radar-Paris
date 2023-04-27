//
//  ScheduleFormatter.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 10.03.2023.
//

import Foundation
import UIKit
/// 
final class ScheduleFormatter {
    typealias Hour = Int
    
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private lazy var aroundClock: NSAttributedString = {
        NSAttributedString(string: Strings.works_24_7,
                           color: UIColor.prlGreen)
    }()
    
    private lazy var undefined: NSAttributedString = {
        NSAttributedString(string: Strings.undefined,
                           color: UIColor.lightGray)
    }()
    
    private var today: Date {
        Date()
    }
    
    private func attributeStatusColor(open: Hour, closed: Hour) -> UIColor {
        guard let openDate = calendar.date(bySettingHour: open, minute: 0, second: 0, of: today),
              var closeDate = calendar.date(bySettingHour: closed, minute: 0, second: 0, of: today),
              let now = calendar.date(bySetting: .second, value: 0, of: today) else { return .lightGray }
        
        if openDate.compare(closeDate) == .orderedDescending { closeDate.addTimeInterval(86400) }
        if now.compare(openDate) == .orderedAscending { return .red }
        if now.compare(closeDate) == .orderedDescending { return .red }
        return .prlGreen
    }
    
    func schedule(from string: String) -> NSAttributedString {
        let rawHours = string.extractDigits()
        let components = rawHours.map { DateComponents(hour: $0) }
        guard components.isDistinct() else { return aroundClock }
        
        let hours = components.compactMap { calendar.date(from:$0) }
        guard hours.count == 2 else { return undefined }
        
        let color = attributeStatusColor(open: rawHours[0], closed: rawHours[1])
        let schedule = hours.map { formatter.string(from: $0) }.joined(separator: " - ")
        return NSAttributedString(string: schedule, color: color)
    }
    
}
