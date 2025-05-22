//
//  LapModel.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//

import Foundation

struct LapModel: Codable, Identifiable {
    let id = UUID()
    let lapNumber: Int        // ✅ عدد الأشواط
    let lapTime: String       // ✅ الوقت الكلي بصيغة "MM:SS"
    let steps: Int            // ✅ عدد الخطوات
    let distance: Double      // ✅ المسافة بالمتر
}
