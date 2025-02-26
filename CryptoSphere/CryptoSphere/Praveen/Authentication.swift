import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    let gracePeriod: TimeInterval = 300 // 5 minutes
    var lastAuthTime: Date?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }
    
    func checkAuthentication() {
        if let lastAuth = lastAuthTime, Date().timeIntervalSince(lastAuth) < gracePeriod {
            // Within grace period, no need to authenticate
            print("Within grace period, skipping authentication.")
            return
        }
        authenticateUser()
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful
                        self.lastAuthTime = Date()
                        print("Authentication successful!")
                    } else {
                        // Authentication failed, show lock screen
                        self.showLockedScreen()
                    }
                }
            }
        } else {
            // Biometrics not available, fallback to passcode
            print("Biometrics unavailable, falling back to passcode.")
            showLockedScreen()
        }
    }
    
    func showLockedScreen() {
        let alert = UIAlertController(title: "Locked", message: "You must authenticate to continue.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.authenticateUser()
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.logout()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func logout() {
        // Redirect to login screen
        print("Logging out...")
        // Example: Perform navigation to login screen here
    }
}
