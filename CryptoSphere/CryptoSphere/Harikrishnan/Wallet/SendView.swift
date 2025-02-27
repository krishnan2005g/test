import SwiftUI
import Kingfisher

struct SendView: View {
    let userHolding: UserHolding
    @State var transferAddress: String = ""
    @State private var amount: String = ""
    @State private var isShowingScanner: Bool = false

    @State private var showPopup: Bool = false
    @State private var status: Bool?
    
    @Environment(\.globalViewModel) var globalViewModel
    var nameSpace: Namespace.ID
    
    @State private var isAnimating: Bool = false
    @State private var isProcessing: Bool = false
    
    var body: some View {
        ZStack{
            
            AngularGradient(colors: [.background, .white.opacity(0.6)], center: .topLeading)
                .ignoresSafeArea()
                .overlay(
                    GridPatternView()
                        .opacity(0.5)
                )
            
            VStack(spacing: 24) {
                // Header
                headerView()
                    .offset(y: isAnimating ? 0 : -50)
                    .opacity(isAnimating ? 1 : 0)
                
                // Coin Details
                coinDetailsView()
                    .rotation3DEffect(
                        .degrees(isAnimating ? 0 : 60),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.3
                    )
                    .opacity(isAnimating ? 1 : 0)
                
                VStack(spacing: 30){
                    // Transfer Address Input
                    addressInputView()
                        .onAppear {
                            if(globalViewModel.selectedCoin.coin.id != 0 && globalViewModel.selectedUser.username != ""){
                                transferAddress = xorEncrypt((globalViewModel.selectedUser.username) + "_" +  String(globalViewModel.selectedCoin.coin.id), key: "c")
                            }
                        }
                    // Amount Input
                    amountInputView()
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 50)
                .padding(.top, 40)
                
                // Confirm Button
                confirmButton()
                    .opacity(isAnimating ? 1 : 0)
                    .padding(.top, 40)
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isShowingScanner) {
                QRReaderView(scannedCode: $transferAddress)
                    .presentationDragIndicator(.visible)
            }
            
            if let status = status{
                if status{
                    TransactionSuccessView(isPresented: $showPopup)
                } else{
                    TransactionErrorView(isPresented: $showPopup)
                }
            }
            
            if isProcessing {
                ProcessingOverlayView()
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                isAnimating = true
            }
        }
    
    }
    
    // MARK: - Subviews
    
    private func headerView() -> some View {
        HStack {
            Text("Send \(userHolding.coin.coinSymbol)")
                .font(.custom("ZohoPuvi-Bold", size: 32))
                .foregroundStyle(.font)
            Spacer()
        }
    }
    
    private func coinDetailsView() -> some View {
        HStack(spacing: 12) {
            SymbolWithNameView(coin: userHolding.coin, searchText: "", nameSpace: nameSpace)
            
            Spacer()
        }
        .padding()
        .background(Color("GrayButtonColor"))
        .cornerRadius(12)
    }
    
    private func addressInputView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipient Address")
                .font(.custom("ZohoPuvi-Semibold", size: 20))
                .foregroundStyle(.font)
                .padding(.bottom, 10)
            
            HStack {
                TextField("Enter wallet address", text: $transferAddress)
                    .font(.custom("ZohoPuvi-Semibold", size:18))
                    .autocapitalization(.none)
                    .foregroundStyle(.secondaryFont)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color("GrayButtonColor"))
                    .cornerRadius(8)
                
                Button(action: { isShowingScanner = true }) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 35))
                        .padding(6)
                        .background(Color("GrayButtonColor"))
                        .foregroundStyle(Color("primaryTheme"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func amountInputView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.custom("ZohoPuvi-Semibold", size: 18))
                .foregroundColor(.font)
            
            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor((Double(amount) ?? 0) > userHolding.quantity ? .red : .font)
                .overlay(
                    Text(userHolding.coin.coinSymbol)
                        .font(.custom("ZohoPuvi-Semibold", size: 18))
                        .foregroundColor(.secondaryFont)
                    , alignment: .trailing
                )
                .onChange(of: amount) { _, newValue in
                    amount = newValue.filter { "0123456789.".contains($0) }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("GrayButtonColor"))
                .cornerRadius(8)

        
            HStack{
                Text("Available: \(userHolding.quantity, specifier: "%.4f") \(userHolding.coin.coinSymbol)")
                    .font(.custom("ZohoPuvi-Regular", size: 14))
                    .foregroundColor(.secondaryFont)
                Spacer()
                Button("MAX") {
                    amount = String(format: "%.4f", userHolding.quantity)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .font(.custom("ZohoPuvi-Bold", size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.primaryTheme)
            }
        }
    }
    
    private func confirmButton() -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task{
                await confirmTransfer()
                showPopup = true
            }
            
        } label: {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                }
                
                Text(isProcessing ? "Processing..." : "Confirm Transfer")
                    .font(.custom("ZohoPuvi-Bold", size: 20))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color("primaryTheme").opacity(0.8), Color("primaryTheme")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(14)
                .shadow(color: Color("primaryTheme").opacity(0.4), radius: 16, y: 8)
            )
            .foregroundColor(.white)
            .scaleEffect(isProcessing ? 0.95 : 1)
        }
        .disabled(transferAddress.isEmpty || amount.isEmpty || (Double(amount) ?? 0) > userHolding.quantity || isProcessing)
        .opacity((transferAddress.isEmpty || amount.isEmpty || (Double(amount) ?? 0) > userHolding.quantity) ? 0.6 : 1)
        .animation(.spring(), value: isProcessing)
    }
    
    // MARK: - Actions
    
    private func confirmTransfer() async {
        let address = String(describing: xorDecrypt(transferAddress, key: "c") ?? ".")
        isProcessing = true
        Task{
            await WebSocketManager.shared.sendMessage(to: String(address.split(separator: "_")[0]), message: "@payment,\(globalViewModel.selectedCoin.coin.id),\(amount),\(address)") { completion in
                status = completion
            }
        }
        isProcessing = false
    }
}

// MARK: - Preview

#Preview {
    SendView(userHolding: UserHolding(
        email: "",
        coin: CoinDetails(
            id: 1,
            coinName: "Bitcoin",
            coinSymbol: "BTC",
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        ),
        quantity: 5
    ), nameSpace: Namespace().wrappedValue)
}


struct GridPatternView: View {
    var body: some View {
        Canvas { context, size in
            let horizontalSteps = Int(size.width / 40)
            let verticalSteps = Int(size.height / 40)
            
            for x in 0...horizontalSteps {
                let path = Path { path in
                    let xPos = CGFloat(x) * 40
                    path.move(to: CGPoint(x: xPos, y: 0))
                    path.addLine(to: CGPoint(x: xPos, y: size.height))
                }
                context.stroke(path, with: .color(.gray.opacity(0.1)), lineWidth: 1)
            }
            
            for y in 0...verticalSteps {
                let path = Path { path in
                    let yPos = CGFloat(y) * 40
                    path.move(to: CGPoint(x: 0, y: yPos))
                    path.addLine(to: CGPoint(x: size.width, y: yPos))
                }
                context.stroke(path, with: .color(.gray.opacity(0.1)), lineWidth: 1)
            }
        }
    }
}

struct ProcessingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.white)
                
                Text("Verifying Transaction")
                    .font(.custom("ZohoPuvi-Bold", size: 20))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
        }
    }
}
