//
//  SupportEmail.swift
//  PopupLog
//
//  Created by 김정윤 on 9/28/24.
//

import Foundation
import SwiftUI

struct SupportEmail {
    let email: String // 개발자 이메일
    let title: String // 제목
    var body: String { """
        앱을 사용하던 중에 문제가 생겼거나 건의하실 사항이 있으신가요?
        모두 최대한 서술해서 보내주세요
        사용자분들의 의견은 언제나 많은 도움이 됩니다
        감사합니다 :)
    """
    }
    
    // openURL
    func send(openURL: OpenURLAction) {
        let urlString = "mailto:\(email)?subject=\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        openURL(url) { accepted in
            if !accepted {
                print("ERROR: 현재 기기는 이메일을 지원하지 않습니다.")
            }
        }
    }
}
