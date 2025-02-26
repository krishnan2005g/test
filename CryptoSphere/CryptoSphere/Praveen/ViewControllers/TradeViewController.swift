import UIKit

class TradeViewController: UIViewController {

    struct CryptoData: Equatable {
        let symbol: String
        let currentPrice: String
        let priceChange24h: Double
        let percentageChange24h: Double
        let chartData: [PreviousData]
        let marketCap: String
        let circulatingSupply: String
        let maxSupply: String
        let totalSupply: String
        let issuePrice: String

        var formattedPercentage: String {
            return String(format: "%+.2f%%", percentageChange24h)
        }

        var formattedPriceChange: String {
            return String(format: "%+.2f (%@)", priceChange24h, formattedPercentage)
        }

        static let mock = CryptoData(
            symbol: "BTCUSDT",
            currentPrice: "23,693.04",
            priceChange24h: 0.34,
            percentageChange24h: 2.32,
            chartData: [],
            marketCap: "$45,093.618",
            circulatingSupply: "151,732,092",
            maxSupply: "230,000,000",
            totalSupply: "151,253,091",
            issuePrice: "$0.1"
        )
    }
    
    
    private let coinDetailsResponse = CoinDetailsResponse()

    private var cryptoData: CryptoData?
    private var updateTimer: Timer?
    private let symbol: String
    private var chartData: [PreviousData] = []
    private var currentInterval: String = "1"
    private var cachedLogoImage: UIImage?

    // MARK: - UI Components
    private var tradeTitleView: UILabel = {
        let label = UILabel()
        label.textColor = .font
        label.font = Fonts.getPuviFont("Medium", 18)
        label.text = "TRADE"
        label.textAlignment = .center
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .background
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true // Enable interaction
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chartView: GradientChartView = {
        let configuration = GradientChartView.Configuration.default
        let view = GradientChartView(configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let timeSegmentControl: UISegmentedControl = {
        let items = ["1D", "5D", "1M", "6M", "1Y", "All"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .primaryTheme
        control.setTitleTextAttributes(
            [.foregroundColor: UIColor.font], for: .normal)
        control.setTitleTextAttributes(
            [.foregroundColor: UIColor.font], for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let dataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let floatingButtonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a gradient layer for the background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.3).cgColor, // Top (transparent black)
            UIColor.black.withAlphaComponent(0.8).cgColor, // Center (darkest)
            UIColor.black.withAlphaComponent(0.3).cgColor  // Bottom (transparent black)
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0] // Middle is darkest

        // Add gradient to the view's layer
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Optional: Add blur effect if desired (as per your original code)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.opacity = 0.3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        // Constraints for the blur effect view
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }()


    private let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Buy", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryTheme
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let sellButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sell", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .greyButtonDarkMode
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let emptyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization
    init(symbol: String = "BTCUSDT") {
        self.symbol = symbol
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.symbol = "BTCUSDT"
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startDataUpdates()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .background
        
        navigationItem.titleView = tradeTitleView
        navigationItem.titleView?.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(symbolLabel)
        contentView.addSubview(logoImageView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(chartView)
        contentView.addSubview(timeSegmentControl)
        contentView.addSubview(dataStackView)
        contentView.addSubview(emptyView)

        view.addSubview(floatingButtonsContainer)
        floatingButtonsContainer.addSubview(buyButton)
        floatingButtonsContainer.addSubview(sellButton)

        setupConstraints()
        setupActions()

        // Set initial mock data while loading
        updateUI(with: CryptoData.mock)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),

            logoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            logoImageView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor, constant: -2),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),

            priceLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            changeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            chartView.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 24),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            chartView.heightAnchor.constraint(equalToConstant: 250),

            timeSegmentControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
            timeSegmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeSegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeSegmentControl.heightAnchor.constraint(equalToConstant: 35),

            dataStackView.topAnchor.constraint(equalTo: timeSegmentControl.bottomAnchor, constant: 24),
            dataStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dataStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dataStackView.bottomAnchor.constraint(equalTo: emptyView.topAnchor, constant: 0),

            floatingButtonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            floatingButtonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            floatingButtonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            floatingButtonsContainer.heightAnchor.constraint(equalToConstant: 80),

            sellButton.leadingAnchor.constraint(equalTo: floatingButtonsContainer.leadingAnchor, constant: 16),
            sellButton.bottomAnchor.constraint(equalTo: floatingButtonsContainer.bottomAnchor, constant: -16),
            sellButton.widthAnchor.constraint(equalToConstant: 180),
            sellButton.heightAnchor.constraint(equalToConstant: 50),

            buyButton.trailingAnchor.constraint(equalTo: floatingButtonsContainer.trailingAnchor, constant: -16),
            buyButton.bottomAnchor.constraint(equalTo: floatingButtonsContainer.bottomAnchor, constant: -16),
            buyButton.widthAnchor.constraint(equalTo: sellButton.widthAnchor, multiplier: 1),
            buyButton.heightAnchor.constraint(equalTo: sellButton.heightAnchor, multiplier: 1),
            
            emptyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    private func setupActions() {
        timeSegmentControl.addTarget(
            self, action: #selector(timeIntervalChanged), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(symbolLabelTapped))
            symbolLabel.addGestureRecognizer(tapGesture)
    }

    // MARK: - Data Management
    private func startDataUpdates() {
        // Initial updates
        Task {
            await updatePriceData()
            await updateChartData()
        }

        // Setup timer for periodic updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
        { [weak self] _ in
            Task {
                await self?.updatePriceData()
            }
        }
    }

    private func updatePriceData() async {
        do {
            let priceResponse = try await LivePriceResponse().fetchPrice(coinName: symbol)
            guard let ticker = priceResponse.result.list.first else { return }

            let priceChange24h =
                Double(ticker.lastPrice)! - Double(ticker.prevPrice24h)!
            let percentageChange = Double(ticker.price24hPcnt)!

            let data = CryptoData(
                symbol: ticker.symbol,
                currentPrice: ticker.lastPrice,
                priceChange24h: priceChange24h,
                percentageChange24h: percentageChange,
                chartData: chartData,
                marketCap: "$45,093.618",
                circulatingSupply: "151,732,092",
                maxSupply: "230,000,000",
                totalSupply: "151,253,091",
                issuePrice: "$0.1"
            )

            await MainActor.run {
                updateUI(with: data)
            }
        } catch {
            print("Error updating price data: \(error)")
        }
    }

    private func updateUI(with data: CryptoData) {
        guard cryptoData != data else { return }
        cryptoData = data

        symbolLabel.text = "\(data.symbol) ▼"
        priceLabel.text = "$\(data.currentPrice)"
        
        updateDataItems(with: data)

        if !data.chartData.isEmpty {
            chartData = data.chartData
            updateChart()
        }
        
        Task{
            if let url = try await URL(string: coinDetailsResponse.fetchOneCoinDetails(symbol: symbol).imageUrl){
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.logoImageView.image = image
                        }
                    }
                }
            }
        }
    }

    private func updateChartData() async {
        func getTimestamp(forDaysAgo days: Int) -> Int {
            return Int(
                Calendar.current.date(byAdding: .day, value: -days, to: Date())!
                    .timeIntervalSince1970 * 1000)
        }

        func getData(type: Calendar.Component, diff: Int) async -> [PreviousData] {
            let now = Int(Date().timeIntervalSince1970 * 1000)
            let intervals = [1, 3, 5, 30, 60, 120, 240, 360, 720]
            let start: Int
            let interval: String
            
            if diff == 100 {
                start = await Int(coinDetailsResponse.getGenesisDate(for: symbol) ?? 10)
                interval = "D"
            } else {
                start = Int(Calendar.current.date(byAdding: type, value: -diff, to: Date())!
                    .timeIntervalSince1970 * 1000)
                interval = String(
                    intervals.first {
                        $0 >= Int((Double(now - start) / (1000 * 60 * 300)).rounded(.up))
                    } ?? intervals.last!)
            }

            do {
                let previousPriceResponse = PreviousPriceResponse()
                let livePriceResponse = LivePriceResponse()
                
                var chartData = try await previousPriceResponse.fetchPreviousPrice(
                    coinName: symbol, from: start, to: now, interval: interval)
                let lastprice = try await livePriceResponse.fetchPrice(coinName: symbol).result.list[0].lastPrice
                
                chartData = chartData.reversed()
                
                chartData.append(
                    PreviousData(
                        time: now, open: 0, high: 0, low: 0,
                        close: Double(lastprice) ?? 0))
                
                return chartData
            } catch {
                print("Error fetching data: \(error)")
            }
            return []
        }
        
        switch currentInterval {
        case "1D":
            chartData = await getData(type: .day, diff: 1)
        case "5D":
            chartData = await getData(type: .day, diff: 5)
        case "1M":
            chartData = await getData(type: .month, diff: 1)
        case "6M":
            chartData = await getData(type: .month, diff: 6)
        case "1Y":
            chartData = await getData(type: .year, diff: 1)
        case "All":
            chartData = await getData(type: .year, diff: 100)
        default:
            chartData = await getData(type: .day, diff: 1)
        }

        await MainActor.run {
            updateChart()
        }
    }

    private func updateChart() {
        guard !chartData.isEmpty else { return }

        let closePrices = chartData.map { CGFloat($0.close) }
        let minPrice = closePrices.min() ?? 0
        let maxPrice = closePrices.max() ?? 0

        // Calculate the price change for the selected period
        let firstPrice = closePrices.first ?? 0
        let lastPrice = closePrices.last ?? 0
        
        // Calculate absolute and percentage changes
        let priceChange = lastPrice - firstPrice
        let percentageChange = ((lastPrice - firstPrice) / firstPrice) * 100
        
        // Update change label with the period-specific change
        let formattedChange = String(format: "%+.2f (%+.2f%%)",
                                   Double(priceChange),
                                   Double(percentageChange))
        
        changeLabel.text = formattedChange
        
        // Update color based on the period change
        let priceChangeColor = lastPrice >= firstPrice ?
            UIColor(red: 0, green: 0.8, blue: 0, alpha: 1.0) : // Green for increase
            UIColor(red: 0.8, green: 0, blue: 0, alpha: 1.0)   // Red for decrease
        
        changeLabel.textColor = priceChangeColor

        // Update the chart configuration with the new color
        let chartConfig = GradientChartView.Configuration(
            dataPoints: closePrices,
            timeLabels: ["1D", "5D", "1M", "6M", "1Y", "All"],
            lineColor: priceChangeColor,
            gridColor: UIColor.gray.withAlphaComponent(0.1),
            textColor: .font,
            minValue: minPrice * 0.992,
            maxValue: maxPrice * 1.006,
            isGradientEnabled: true,
            showGridLines: false,
            lineWidth: 2.0,
            fontSize: 12.0
        )

        // Animate the chart update
        UIView.transition(
            with: chartView,
            duration: 0.4,
            options: [.beginFromCurrentState, .transitionCrossDissolve, .curveEaseOut, .allowAnimatedContent],
            animations: {
                self.chartView.configure(with: chartConfig)
            },
            completion: nil
        )
    }

    private func updateDataItems(with data: CryptoData) {
        dataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let dataItems = [
            ("Market cap", data.marketCap),
            ("Circulating supply", data.circulatingSupply),
            ("Max supply", data.maxSupply),
            ("Total supply", data.totalSupply),
            ("Issue price", data.issuePrice),
        ]

        dataItems.forEach { title, value in
            let itemView = createDataItemView(title: title, value: value)
            dataStackView.addArrangedSubview(itemView)
        }
    }

    private func createDataItemView(title: String, value: String) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryFont
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .font
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 35),
        ])

        return container
    }

    // MARK: - Actions
    @objc private func timeIntervalChanged(_ sender: UISegmentedControl) {
        let intervals = ["1D", "5D", "1M", "6M", "1Y", "All"]
        currentInterval = intervals[sender.selectedSegmentIndex]
        Task {
            await updateChartData()
        }
    }
    
    @objc private func symbolLabelTapped() {
        let actionSheetVC = UIViewController()
        actionSheetVC.modalPresentationStyle = .automatic
        actionSheetVC.view.backgroundColor = .background
        actionSheetVC.sheetPresentationController?.prefersGrabberVisible = true
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissActionSheet), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        actionSheetVC.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: actionSheetVC.view.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: actionSheetVC.view.centerYAnchor)
        ])
        
        present(actionSheetVC, animated: true)
    }
    
    @objc private func dismissActionSheet() {
        dismiss(animated: true)
    }

    deinit {
        updateTimer?.invalidate()
    }
}

#Preview {
    TradeViewController(symbol: "BTCUSDT")
}
