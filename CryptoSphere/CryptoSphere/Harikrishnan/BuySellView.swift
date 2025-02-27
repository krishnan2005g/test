import SwiftUI
import Kingfisher
import AudioToolbox

struct BuySellView: View {
    
    let mot: String
    let coin: CoinDetails
    
    let balanceUSD: Double = 0.0
    
    @State var marketPrice: Double = 0.0
    @State private var isTextFieldVisible: Bool = true
    
    @FocusState private var isFocused: Bool
    
    var options:[String]
    
    @State private var selectedOption = ""
    
    @State private var value: KeyPadValue = .init()
    
    @State private var isShowingAlert: Bool = false
    @State private var alertStaus: Bool = true
    
    @Namespace private var nameSpace
    
    init(mot: String, coin: CoinDetails) {
        self.mot = mot
        self.coin = coin
        
        self.options = ["\(mot) in \(coin.coinSymbol.replacingOccurrences(of: "USDT", with: ""))", "\(mot) in USD"]
        _selectedOption = State(initialValue: options.first ?? "")
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: UIFont(name: "ZohoPuvi-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)],
            for: .normal
        )
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.orange
        UISegmentedControl.appearance().backgroundColor = UIColor.black
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    SymbolWithNameView(coin: coin, searchText: "", nameSpace: nameSpace)
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Market Price")
                            .font(.custom("ZohoPuvi-Medium", size: 16))
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        Text("\(marketPrice, format: .currency(code: "USD"))")
                            .font(.custom("ZohoPuvi-Semibold", size: 18))
                    }
                }
                .padding(.top, 10)
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
            
                Picker("Select Option", selection: $selectedOption) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.custom("ZohoPuvi-Bold", size: 18))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 30)
                
                Spacer()
                
                if isTextFieldVisible {
                    TextFieldInput(selectedBuyOption: $selectedOption, selectedSellOption: $selectedOption, coinImage: coin.imageUrl, value: $value, mot: mot)
                        .transition(.scale(scale: 0, anchor: .center))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .onAppear {
                Task {
                    await fetchPrice()
                }
            }
            
            Text("Balance: \(balanceUSD.formatted(.currency(code: "USD")))")
                .font(.custom("ZohoPuvi-Semibold", size: 20))
                .foregroundStyle(.white)
                .padding(.top, -60)
            
            Button(action: {
                actionHandler()
            }) {
                Text(mot)
                    .font(.custom("ZohoPuvi-Bold", size: 27))
                    .frame(width: 250, height: 46)
                    .background(Color(.primaryTheme))
                    .cornerRadius(25)
            }
            .padding(.top, 50)
            .disabled(value.stringValue.isEmpty || Double(value.stringValue) == nil || Double(value.stringValue)! <= 0)
            
            if isShowingAlert {
                if alertStaus {
                    TransactionSuccessView(isPresented: $isShowingAlert)
                        .onDisappear {
                                isTextFieldVisible = true
                        }
                } else {
                    TransactionErrorView(isPresented: $isShowingAlert)
                        .onDisappear {
                            withAnimation {
                                isTextFieldVisible = true
                            }
                        }
                }
            }
        }
    }
    
    func actionHandler() {
        guard !value.isEmpty else { return }
        
        // Animate text field out before showing alert
        withAnimation(.easeInOut(duration: 0.3)) {
            isTextFieldVisible = false
        }
        
        let inputValue = value.stringValue

        if selectedOption == options.first {
            ServerResponce.shared.buySellCoin(buySell: mot.lowercased(), coinId: coin.id, quantity: Double(inputValue) ?? 0.0, completion: { c in alertStaus = c })
            
            print("\(mot) \(inputValue) of \(coin.coinName)")
        } else {
            ServerResponce.shared.buySellCoin(buySell: mot.lowercased(), coinId: coin.id, quantity: ((Double(inputValue) ?? 0) / marketPrice), completion: { c in alertStaus = c })
            isShowingAlert = true
            print("\(mot) \((Double(inputValue) ?? 0) / marketPrice) of \(coin.coinName)")
        }
        
        value = .init()
        

        isShowingAlert = true
    }
    
    func fetchPrice() async {
        let price = try? await CryptoSphere.fetchPrice(coinName: coin.coinSymbol).result.list[0].lastPrice
        marketPrice = Double(price ?? "0")!
    }
}

#Preview {
    BuySellView(
        mot: "Buy",
        coin: CoinDetails(
            id: 325,
            coinName: "Bitcoin",
            coinSymbol: "BTCUSDT",
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        )
    )
}

#Preview {
    BuySellView(
        mot: "Buy",
        coin: CoinDetails(
            id: 325,
            coinName: "Bitcoin",
            coinSymbol: "BTCUSDT",
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        )
    )
}
