//
//  DeinitDetector.swift
//  PopupLog
//
//  Created by 김정윤 on 9/25/24.
//

import Foundation

final class DeinitDetector<T> {
    
    deinit {
        var typeString = "\(type(of: T.self))"          /// "SomeView.Type"
        typeString.removeLast(5)                        /// "SomeView"
        print("🖐🖐🖐 \(typeString): \(#function)")      /// "🖐🖐🖐 NotificationView: deinit"
        
        deinitCompletion?()
    }

    private var deinitCompletion: (() -> Void)?
    public init(_ deinitCompletion: (() -> Void)? = nil) {
        self.deinitCompletion = deinitCompletion
    }
    
    public func setCompletion(_ deinitCompletion: (() -> Void)?) {
        self.deinitCompletion = deinitCompletion
    }

}
