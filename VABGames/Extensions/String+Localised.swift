//
//  String+Localised.swift
//  VABGames
//
//  Created by user245948 on 1/21/25.
//

import Foundation

extension String {
    func localised(using languageCode: String = "en") -> String {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
