//
//  BundleIDs.swift
//  PopupLog
//
//  Created by 김정윤 on 11/18/25.
//

import Foundation

enum BundleIDs: String {
    case APIKey = "API_KEY"
    case BaseURL = "BASE_URL"
    case NClient = "N_CLIENT"
    case NSecret = "N_SECRET"
    case clientID = "CLIENT_ID"
}

@propertyWrapper
struct BundleWrapper {
    var key: BundleIDs
    
    var wrappedValue: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String else {
            fatalError("\(key) not found in Info.plist")
        }
        return value
    }
    
    init(_ type: BundleIDs) {
        key = type
    }
}
