import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    private let getCryptocurrency = GetCryptocurrency()
    private var refreshTimer: Timer?
    
    // MARK: - UI Elements
    private let profileImageView: ProfileHeaderView = {
        let view = ProfileHeaderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(with: "Osama Bin Laden", imageURL: "https://assets.editorial.aetnd.com/uploads/2009/12/islamic-extremist-osama-bin-laden.jpg")
        return view
    }()
    
    private let portfolioView: PortfolioView = {
        let view = PortfolioView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(balance: "$5,271.39", profit: "+$2,979.23", percentage: "(130.62%)", profitColor: .green)
        return view
    }()
    
    private let myFundsLabel: UILabel = {
        let label = UILabel()
        label.text = "My Funds"
        label.font = Fonts.getPuviFont("light", 16)
        label.textColor = .font
        label.layer.opacity = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("View All >", for: .normal)
        button.setTitleColor(.font, for: .normal)
        button.titleLabel?.font = Fonts.getPuviFont("medium", 18)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var fundsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myFundsLabel, viewAllButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let addFundsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .secondaryFont
        button.backgroundColor = .grayButton
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let myFundsCollectionView: FundsCollectionView = {
        let collectionView = FundsCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var cryptoTableLikeView: CryptoTableLikeView = {
        let view = CryptoTableLikeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingView: UIView = {
        let view = CustomLoadingView()
        return view
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
//        startRefreshingData()
        loadCryptoData()
        
        for family in UIFont.familyNames {
            print("Font family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family) {
                print("-- Font: \(font)")
            }
        }

        
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Data Loading
//    private func startRefreshingData() {
//        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
//            self?.loadCryptoData()
//        }
//        refreshTimer?.fire() // Load data immediately
//    }
    
    private func loadCryptoData() {
        loadingView.isHidden = false // Show loading view before starting

        Task {
            let mostPopular = await fetchCryptos(symbols: ["SOLUSDT", "ETHUSDT", "BTCUSDT"])
            let trending = await fetchCryptos(symbols: ["ADAUSDT", "DOTUSDT", "TRUMPUSDT"])
            let recommended = await fetchCryptos(symbols: ["AVAXUSDT", "LINKUSDT", "MATICUSDT"])

            await MainActor.run {
                cryptoTableLikeView.configure(mostPopular: mostPopular, trending: trending, recommended: recommended)
            }

            let allCryptos = await fetchCryptos(symbols: ["BTCUSDT", "ETHUSDT", "SOLUSDT", "ADAUSDT", "DOTUSDT", "XRPUSDT"])
            await MainActor.run {
                myFundsCollectionView.configure(with: allCryptos)
                self.loadingView.isHidden = true // Hide loading view when done
            }
        }
    }

    
    private func fetchCryptos(symbols: [String]) async -> [Cryptocurrency] {
        await withTaskGroup(of: Cryptocurrency?.self) { group in
            symbols.forEach { symbol in
                group.addTask { await self.getCryptocurrency.getData(symbol: symbol) }
            }
            
            var results: [Cryptocurrency] = []
            for await result in group {
                if let crypto = result {
                    results.append(crypto)
                }
            }
            return results
        }
    }



    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(portfolioView)
        view.addSubview(fundsStackView)
        view.addSubview(addFundsButton)
        view.addSubview(myFundsCollectionView)
        view.addSubview(cryptoTableLikeView)
        view.addSubview(loadingView) // Add loading view
        
        myFundsCollectionView.delegate = self
        
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(loadingView) // Ensure it appears on top\
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: nil)
    }

    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Profile Image View
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            
            // Portfolio View
            portfolioView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portfolioView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            portfolioView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            
            // Funds Stack View
            fundsStackView.topAnchor.constraint(equalTo: portfolioView.bottomAnchor, constant: 16),
            fundsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            fundsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Add Funds Button
            
            // My Funds Collection View
            myFundsCollectionView.topAnchor.constraint(equalTo: fundsStackView.bottomAnchor, constant: 4),
            myFundsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            myFundsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -2),
            myFundsCollectionView.heightAnchor.constraint(equalToConstant: 180),
            
            addFundsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            addFundsButton.topAnchor.constraint(equalTo: fundsStackView.bottomAnchor, constant: 8),
            addFundsButton.widthAnchor.constraint(equalToConstant: 44),
            addFundsButton.heightAnchor.constraint(equalToConstant: 180),
            
            
            // Crypto Table Like View
            cryptoTableLikeView.topAnchor.constraint(equalTo: myFundsCollectionView.bottomAnchor),
            cryptoTableLikeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cryptoTableLikeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cryptoTableLikeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        if let profileHeaderView = profileImageView as? ProfileHeaderView {
            profileHeaderView.tapAction = { [weak self] in
                self?.profileTapped()
            }
        }
    }
    
    // MARK: - Gradient Background
    private func setGradientBackground(view: UIView, percentage: NSNumber = 0.2) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.greyBackgroundDarkMode.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, percentage]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        print(offsetX)
        UIView.animate(withDuration: 0.2) {
            if offsetX == 0 {
                self.addFundsButton.transform = .identity // Show at original position
                self.addFundsButton.alpha = 1
            } else {
                self.addFundsButton.transform = CGAffineTransform(translationX: -60, y: 0) // Slide left
                self.addFundsButton.alpha = 0
            }
        }
    }

    // MARK: - Profile Tapped
    @objc private func profileTapped() {
        let actionSheetVC = UIViewController()
        actionSheetVC.modalPresentationStyle = .automatic
        actionSheetVC.view.backgroundColor = .background
        actionSheetVC.sheetPresentationController?.prefersGrabberVisible = true
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        actionSheetVC.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: actionSheetVC.view.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: actionSheetVC.view.centerYAnchor)
        ])
        
        present(actionSheetVC, animated: true)
    }
}

#Preview {
    HomeViewController()
}
