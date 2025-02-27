//
//  GlobalViewModel.swift
//  Real app
//
//  Created by Harikrishnan V on 2025-02-07.
//

import Foundation
import Observation
import SwiftUI

@Observable
class GlobalViewModel {
    var selectedCoin: UserHolding = UserHolding(email: "", coin: CoinDetails(id: 0, coinName: "Bitcoin", coinSymbol: "BTCUSDT", imageUrl: ""), quantity: 2)
    var selectedUser: User = User(email: " ", username: "", password: "" , profilePicture: "")
    var session: User = User(email: " ", username: preview, password: "" , profilePicture: "")
}

struct GlobalViewModelKey: EnvironmentKey {
    static var defaultValue: GlobalViewModel = GlobalViewModel()
}

extension EnvironmentValues {
    var globalViewModel: GlobalViewModel {
        get { self[GlobalViewModelKey.self] }
        set { self[GlobalViewModelKey.self] = newValue }
    }
}
