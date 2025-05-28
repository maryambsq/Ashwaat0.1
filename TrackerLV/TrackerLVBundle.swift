//
//  TrackerLVBundle.swift
//  TrackerLV
//
//  Created by Ashwaq on 27/11/1446 AH.
//

import WidgetKit
import SwiftUI

@main
struct TrackerLVBundle: WidgetBundle {
    var body: some Widget {
        TrackerLV()
        TrackerLVControl()
        TrackerLVLiveActivity()
    }
}
