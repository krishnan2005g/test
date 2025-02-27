//
//  SceneDelegate.swift
//  CryptoSphere
//
//  Created by Praveenkumar Narayanamoorthy on 30/01/25.
//

import UIKit
import SwiftUI
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var modelContainer: ModelContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
//        let navController = UINavigationController(rootViewController: CryptoDetailViewController())
////        let navController = UINavigationController(rootViewController: CalculatorViewController())
//        window.rootViewController = navController
//        self.window = window
//        window.makeKeyAndVisible()
        
        let tabBarController = UITabBarController()
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let marketsVC = UINavigationController(rootViewController: TradeViewController())
        marketsVC.tabBarItem = UITabBarItem(title: "Markets", image: UIImage(systemName: "chart.bar.fill"), tag: 1)

        let tradeVC = UINavigationController(rootViewController: HomeViewController())
        let tradeImage = UIImage(systemName: "arrow.left.arrow.right.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))
            .withTintColor(.orange, renderingMode: .alwaysOriginal)
        
        tradeVC.tabBarItem = UITabBarItem(title: nil, image: tradeImage, tag: 2)
        tradeVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -6, right: 0)

        let walletVC = UINavigationController(rootViewController: TradeViewController())
        walletVC.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(systemName: "wallet.pass.fill"), tag: 3)

        let accountVC = UINavigationController(rootViewController: HomeViewController())
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "gearshape.fill"), tag: 4)
        
        tabBarController.viewControllers = [homeVC, marketsVC, tradeVC, walletVC, accountVC]
        tabBarController.tabBar.barTintColor = .clear
        tabBarController.tabBar.tintColor = .font
        
        tabBarController.delegate = tabBarController
        
        // Remove background color
        UITabBar.appearance().backgroundColor = .clear
        tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.tabBar.shadowImage = UIImage()
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)


//        window.rootViewController = tabBarController
        window.rootViewController = UIHostingController(rootView: ChatListView().modelContainer(for: MessageModel.self))
        
        self.window = window
        window.makeKeyAndVisible()

        
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

extension UITabBarController: @retroactive UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view,
              let toView = viewController.view,
              let fromIndex = viewControllers?.firstIndex(of: selectedViewController!),
              let toIndex = viewControllers?.firstIndex(of: viewController),
              fromIndex != toIndex else {
            return true
        }
        
        let direction: CGFloat = toIndex > fromIndex ? 1 : -1
        
        toView.frame = fromView.frame.offsetBy(dx: direction * fromView.frame.width, dy: 0)
        tabBarController.view.insertSubview(toView, aboveSubview: fromView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            fromView.frame = fromView.frame.offsetBy(dx: -direction * fromView.frame.width, dy: 0)
            toView.frame = fromView.frame
        } completion: { finished in
            if finished {
                fromView.frame = fromView.frame
            }
        }
        return true
    }
}

