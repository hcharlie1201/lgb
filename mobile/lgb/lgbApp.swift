//
//  lgbApp.swift
//  lgb
//
//  Created by Charlie on 7/15/25.
//

import GoogleSignIn
import Inject
import SwiftUI

@main
struct lgbApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
        }
    }
}
