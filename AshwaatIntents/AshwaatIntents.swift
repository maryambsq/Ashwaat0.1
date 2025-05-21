//
//  AshwaatIntents.swift
//  AshwaatIntents
//
//  Created by Maryam Amer Bin Siddique on 20/11/1446 AH.
//

import AppIntents

struct AshwaatIntents: AppIntent {
    static var title: LocalizedStringResource { "AshwaatIntents" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
