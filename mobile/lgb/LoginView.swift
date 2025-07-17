//
//  LoginView.swift
//  lgb
//
//  Created by Charlie on 7/15/25.
//

import GoogleSignIn
import GoogleSignInSwift
import Inject
import SwiftUI

struct LoginView: View {
    @ObserveInjection var inject;
    var body: some View {
        VStack {
            GoogleSignInButton(action: handleSignInButton)
        }.padding(.vertical, 80)
            .enableInjection()
    }
}

func handleSignInButton() {
    if let rootViewController = getRootViewController() {
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController)
        { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }

            signInResult.user.refreshTokensIfNeeded { user, error in
                guard error == nil else { return }
                guard let user = user else { return }

                let idToken = user.idToken
                // Send ID token to backend (example below).
                tokenSignInExample(idToken: idToken?.tokenString ?? "")
            }
        }
    }
}

#Preview {
    LoginView()
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from viewController: UIViewController) -> UIViewController? {
    if let nav = viewController as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = viewController as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = viewController.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    return viewController
}

private func tokenSignInExample(idToken: String) {
    guard let authData = try? JSONEncoder().encode(["id_token": idToken]) else {
        return
    }
    let url = URL(string: "http://127.0.0.1:4000/api/v1/auth/google")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.uploadTask(with: request, from: authData) { _, _, _ in
        // Handle response from your backend.
    }
    task.resume()
}
