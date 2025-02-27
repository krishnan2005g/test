import UIKit
import SwiftUI

class UIKitViewController: UIViewController {
    
    let changePageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Hello", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        // Correctly reference `button` instead of `changePageButon`
        button.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(changePageButton)
        
        changePageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changePageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func changePage() {
        let swiftUIView = SwiftUIView()
        let hostingController = UIHostingController(rootView: swiftUIView)
//        hostingController.modalPresentationStyle = .fullScreen // Covers entire screen
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true, completion: nil)
//        navigationController?.pushViewController(hostingController, animated: true)
    }
}

struct SwiftUIView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Text("Welcome to SwiftUI!")
                .font(.title)
                .foregroundColor(.white)
                .padding()
        }
    }
}


#Preview {
    UIKitViewController()
}
