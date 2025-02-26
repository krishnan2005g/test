import UIKit

class TradeActionSheetViewController: UIViewController {
    
    let buyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Buy", for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    let sellButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sell", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSheetPresentation()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        let stackView = UIStackView(arrangedSubviews: [buyButton, sellButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupSheetPresentation() {
        if let sheet: UISheetPresentationController = sheetPresentationController {
            sheet.detents = [.large()] // Allows the sheet to be draggable between medium & large
            sheet.prefersGrabberVisible = true // Adds a drag indicator at the top
            sheet.preferredCornerRadius = 50
        }
    }
}


class SheetViewController: UIViewController {
    
    let openSheetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Open Trade Sheet", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(openSheetButton)
        openSheetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            openSheetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openSheetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            openSheetButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        openSheetButton.addTarget(self, action: #selector(openTradeSheet), for: .touchUpInside)
    }
    
    @objc private func openTradeSheet() {
        let tradeVC = TradeActionSheetViewController()
        if let sheet = tradeVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // Makes it draggable
            sheet.prefersGrabberVisible = true // Show the grabber at the top
            sheet.preferredCornerRadius = 40
        }
        present(tradeVC, animated: true)
    }
}

#Preview {
    SheetViewController()
}
