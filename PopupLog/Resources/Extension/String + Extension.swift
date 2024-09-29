//
//  String + Extension.swift
//  PopupLog
//
//  Created by 김정윤 on 9/29/24.
//

import Foundation

extension String {
    var isEmptyRemovedSpace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
