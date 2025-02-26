import SwiftUI
import Kingfisher
import Lottie

struct BuySellView: View {
    let mot: String
    let coin: CoinDetails
    let balanceUSD: Double = 1000.0 // Example balance
    
    @State private var marketPrice: Double = 0.0
    @State private var value: String = ""
    @State private var selectedOption: String
    @State private var isProcessing: Bool = false
    @State private var showSuccess: Bool = false
    @State private var inputBorderColor: Color = .gray.opacity(0.5)
    @FocusState private var isInputFocused: Bool
    
    private var options: [String]
    private var isBuy: Bool { mot == "Buy" }
    
    init(mot: String, coin: CoinDetails) {
        self.mot = mot
        self.coin = coin
        
        let symbol = coin.coinSymbol.replacingOccurrences(of: "USDT", with: "")
        self.options = isBuy ?
            ["Buy in \(symbol)", "Buy in USD"] :
            ["Sell in \(symbol)", "Sell in USD"]
        
        _selectedOption = State(initialValue: self.options.first ?? "")
    }
    
    var body: some View {
        ZStack {
            // Background
            AngularGradient(colors: [Color("DarkBackground"), Color.background], center: .topLeading)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                headerSection()
                
                // Picker
                CustomSegmentedControl(options: options, selectedOption: $selectedOption)
                    .padding(.vertical, 16)
                
                // Input Section
                inputSection()
                
                Spacer()
                
                // Action Button
                actionButton()
                    .padding(.bottom, 40)
            }
            .padding(.horizontal)
            
            // Success Overlay
            successOverlay()
        }
        .onAppear { fetchMarketPrice() }
        .onChange(of: value) { validateInput() }
    }
    
    // MARK: - Components
    
    private func headerSection() -> some View {
        HStack(spacing: 16) {
            KFImage(URL(string: coin.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Material.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.coinName)
                    .font(.custom("ZohoPuvi-Semibold", size: 22))
                
                Text("Market Price: \(marketPrice.formatted(.currency(code: "USD")))")
                    .font(.custom("ZohoPuvi-Medium", size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.top, 24)
    }
    
    private func inputSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Amount")
                    .font(.custom("ZohoPuvi-Semibold", size: 18))
                
                Spacer()
                
                Text("Balance: \(balanceUSD.formatted(.currency(code: "USD")))")
                    .font(.custom("ZohoPuvi-Medium", size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                ZStack(alignment: .trailing) {
                    TextField("0", text: $value)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(inputBorderColor == .red ? .red : .primary)
                        .focused($isInputFocused)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(inputBorderColor, lineWidth: 2)
                        )
                        .onTapGesture { isInputFocused = true }
                    
                    Text(selectedUnit)
                        .font(.custom("ZohoPuvi-Semibold", size: 16))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 16)
                }
                
                Button("MAX") {
                    value = String(format: "%.2f", maxAmount)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .buttonStyle(PillButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.ultraThickMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
    
    private func actionButton() -> some View {
        Button {
            handleTransaction()
        } label: {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                }
                
                Text(isProcessing ? "Processing..." : mot)
                    .font(.custom("ZohoPuvi-Bold", size: 20))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color("primaryTheme"), Color("DarkPrimaryTheme")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(14)
                .shadow(color: Color("primaryTheme").opacity(0.4), radius: 16, y: 8)
            )
            .foregroundColor(.white)
            .scaleEffect(isProcessing ? 0.95 : 1)
        }
        .disabled(!isValidInput || isProcessing)
    }
    
    private func successOverlay() -> some View {
        Group {
            if showSuccess {
                VStack(spacing: 24) {
                    LottieView(name: "success-animation", loopMode: .playOnce)
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Text("Transaction Successful")
                            .font(.custom("ZohoPuvi-Bold", size: 24))
                        
                        Text("\(value) \(selectedUnit) \(isBuy ? "bought" : "sold")")
                            .font(.custom("ZohoPuvi-Medium", size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Material.ultraThickMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccess = false
                            value = ""
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var selectedUnit: String {
        selectedOption.contains("USD") ? "USD" : coin.coinSymbol
    }
    
    private var maxAmount: Double {
        selectedUnit == "USD" ? balanceUSD : balanceUSD / marketPrice
    }
    
    private var isValidInput: Bool {
        guard let amount = Double(value), amount > 0 else { return false }
        return amount <= maxAmount
    }
    
    private func validateInput() {
        guard let amount = Double(value) else {
            inputBorderColor = .gray.opacity(0.5)
            return
        }
        
        inputBorderColor = amount > maxAmount ? .red : Color("primaryTheme")
    }
    
    private func handleTransaction() {
        guard !isProcessing else { return }
        
        isProcessing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                isProcessing = false
                showSuccess = true
            }
        }
    }
    
    private func fetchMarketPrice() {
        // Simulated price fetch
        marketPrice = 45000.00 // Example price
    }
}

// MARK: - Custom Components

struct CustomSegmentedControl: View {
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .font(.custom("ZohoPuvi-Semibold", size: 16))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selectedOption == option {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("primaryTheme"))
                                    .shadow(color: Color("primaryTheme").opacity(0.3), radius: 4)
                                    .matchedGeometryEffect(id: "selector", in: Namespace().wrappedValue)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedOption = option
                        }
                    }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("GrayButtonColor"))
                .padding(2)
        )
    }
}

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("ZohoPuvi-Bold", size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color("primaryTheme").opacity(0.2))
            .foregroundColor(Color("primaryTheme"))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

// MARK: - Preview

#Preview {
    BuySellView(
        mot: "Buy",
        coin: CoinDetails(
            id: 1,
            coinName: "Bitcoin",
            coinSymbol: "BTCUSDT",
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        )
    )
}
