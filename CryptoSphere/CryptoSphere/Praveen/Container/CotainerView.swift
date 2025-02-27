import UIKit
import SwiftUI

class FundsCollectionView: UICollectionView {
    private var cryptos: [Cryptocurrency] = []
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 184, height: 180)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(FundsCollectionViewCell.self, forCellWithReuseIdentifier: "CryptoCell")
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with cryptos: [Cryptocurrency]) {
        self.cryptos = cryptos
        reloadData()
    }
}

extension FundsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cryptos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CryptoCell", for: indexPath) as! FundsCollectionViewCell
        let crypto = cryptos[indexPath.item]
        cell.configure(with: crypto)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(cryptos[indexPath.item].name)")
    }
}

class FundsCollectionViewCell: UICollectionViewCell {
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let config = UIImage.SymbolConfiguration(pointSize: 45, weight: .regular)

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.zohoPuviBoldFont
        label.textColor = .font
        return label
    }()
    
    let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.getPuviFont("bold", 12)
        label.textColor = .font
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.getPuviFont("medium", 20)
        label.textColor = .font
        return label
    }()
    
    let valueChangeLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.getPuviFont("bold", 12)
        label.textColor = .font
        return label
    }()
    
    let percentageChangeLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.getPuviFont("light", 12)
        label.textColor = .font
        return label
    }()

    var chartHostingController: UIHostingController<ChartViews>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white.withAlphaComponent(0.1)
        layer.cornerRadius = 30
        
        addSubview(logoImageView)
        addSubview(nameLabel)
        addSubview(symbolLabel)
        addSubview(priceLabel)
        addSubview(valueChangeLabel)
        addSubview(percentageChangeLabel)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        valueChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageChangeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor, constant: -8),
            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 8),

            symbolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            symbolLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            priceLabel.bottomAnchor.constraint(equalTo: valueChangeLabel.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: valueChangeLabel.leadingAnchor),
            
            valueChangeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            valueChangeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            percentageChangeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            percentageChangeLabel.leadingAnchor.constraint(equalTo: valueChangeLabel.trailingAnchor, constant: 6),
        ])
    }

    func configure(with cryptocurrency: Cryptocurrency) {
        nameLabel.text = cryptocurrency.name
        symbolLabel.text = cryptocurrency.symbol
        priceLabel.text = "$" + cryptocurrency.price
        valueChangeLabel.text = cryptocurrency.change24hValue
        percentageChangeLabel.text = "(" + cryptocurrency.change24hPercent + "%)"
                    
        let changeColor: UIColor = cryptocurrency.change24hPercent.contains("-") ? .red : .green
            valueChangeLabel.textColor = changeColor
            percentageChangeLabel.textColor = changeColor

        Task {
            if let url = URL(string: cryptocurrency.logo) {
                if let data = try? await URLSession.shared.data(from: url).0, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.logoImageView.image = image
                    }
                }
            }
        }

        addChartView(for: cryptocurrency.symbol)
    }

    private func addChartView(for coin: String) {
        if let chartHostingController = chartHostingController {
            chartHostingController.view.removeFromSuperview()
            chartHostingController.removeFromParent()
        }

        let chartView = ChartViews(coin: coin)
        let hostingController = UIHostingController(rootView: chartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        addSubview(hostingController.view)
        chartHostingController = hostingController

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            hostingController.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 168),
            hostingController.view.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -8),
            hostingController.view.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}


class JsonViewController: UIViewController {
    
    private var cryptos: [Cryptocurrency] = [
        Cryptocurrency(
            name: "Bitcoin",
            symbol: "BTCUSDT",
            price: "$43,567.89",
            logo: "https://cryptologos.cc/logos/bitcoin-btc-logo.png",
            change24hPercent: "+5.67%",
            change24hValue: "+2345.67"
        ),
        Cryptocurrency(
            name: "Ethereum",
            symbol: "ETHUSDT",
            price: "$2,345.67",
            logo: "https://cryptologos.cc/logos/ethereum-eth-logo.png",
            change24hPercent: "-2.34%",
            change24hValue: "-56.78"
        ),
        Cryptocurrency(
            name: "Solana",
            symbol: "SOLUSDT",
            price: "$98.76",
            logo: "https://cryptologos.cc/logos/solana-sol-logo.png",
            change24hPercent: "+10.23%",
            change24hValue: "+9.23"
        ),
        Cryptocurrency(
            name: "Cardano",
            symbol: "ADAUSDT",
            price: "$1.23",
            logo: "https://cryptologos.cc/logos/cardano-ada-logo.png",
            change24hPercent: "+3.45%",
            change24hValue: "+0.04"
        ),
        Cryptocurrency(
            name: "Polkadot",
            symbol: "DOTUSDT",
            price: "$18.92",
            logo: "https://cryptologos.cc/logos/polkadot-new-dot-logo.png",
            change24hPercent: "-1.23%",
            change24hValue: "-0.23"
        ),
        Cryptocurrency(
            name: "Ripple",
            symbol: "XRPUSDT",
            price: "$0.89",
            logo: "https://cryptologos.cc/logos/xrp-xrp-logo.png",
            change24hPercent: "+7.82%",
            change24hValue: "+0.06"
        ),
        Cryptocurrency(
            name: "Avalanche",
            symbol: "AVAXUSDT",
            price: "$76.54",
            logo: "https://cryptologos.cc/logos/avalanche-avax-logo.png",
            change24hPercent: "+4.56%",
            change24hValue: "+3.78"
        ),
        Cryptocurrency(
            name: "Chainlink",
            symbol: "LINKUSDT",
            price: "$15.67",
            logo: "https://cryptologos.cc/logos/chainlink-link-logo.png",
            change24hPercent: "-0.89%",
            change24hValue: "-0.14"
        ),
        Cryptocurrency(
            name: "Polygon",
            symbol: "MATICUSDT",
            price: "$1.45",
            logo: "https://cryptologos.cc/logos/polygon-matic-logo.png",
            change24hPercent: "+6.78%",
            change24hValue: "+0.09"
        ),
        Cryptocurrency(
            name: "Cosmos",
            symbol: "ATOMUSDT",
            price: "$21.34",
            logo: "https://cryptologos.cc/logos/cosmos-atom-logo.png",
            change24hPercent: "-3.21%",
            change24hValue: "-0.67"
        )
    ]


    private var fundsCollectionView: FundsCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupFundsCollectionView()
    }
    
    private func setupFundsCollectionView() {
        fundsCollectionView = FundsCollectionView()
        fundsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fundsCollectionView)
        
        NSLayoutConstraint.activate([
            fundsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            fundsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fundsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fundsCollectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        fundsCollectionView.configure(with: cryptos)
    }
}

#Preview {
    JsonViewController()
}
