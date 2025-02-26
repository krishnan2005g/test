//
//  WalletView.swift
//  Real app
//
//  Created by Harikrishnan V on 2025-02-06.
//

import SwiftUI

struct WalletView: View {
    
    @State private var balance: Double = 0
    @State private var coins: [UserHolding] = []
    @State private var searchText: String = ""
    @State private var searchTextsheet: String = ""
    @State private var isSendActionSheetPresented = false
    @State private var isReceiveActionSheetPresented = false
    @Environment(\.globalViewModel) private var globalViewModel
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 16) {
                walletData()
                    .onAppear {
                        fillcoins()
                        Task{
//                            await WebSocketManager.shared.connect()
                        }
                    }
                    .padding(.horizontal)
                
                CoinHoldingListView(hasNavigate: false)
                
                Spacer()
                
            }
        }
        .refreshable { fillcoins() }
        .sheet(isPresented: $isSendActionSheetPresented) {
            CoinHoldingListView(hasNavigate: true)
                .presentationDragIndicator(.visible)
        }
        
        .sheet(isPresented: $isReceiveActionSheetPresented) {
            CoinsListView(dismiss: false, isMarket: false)
                .presentationDragIndicator(.visible)
        }
    }
    
    func walletData() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "wallet.bifold")
                    .font(.title)
                    .bold()
                Text("Your Balance")
                    .font(.custom("ZohoPuvi-Semibold", size: 22))
            }
            
            Text("\(balance, format: .currency(code: "USD"))")
                .font(.custom("ZohoPuvi-Bold", size: 28))
                .padding(.vertical, 10)
                actionButtons()
        }
    }
    
    private func actionButtons() -> some View {
        HStack(spacing: 16) {
            Button(action: { isSendActionSheetPresented = true }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                    Text("Send")
                        .font(.custom("ZohoPuvi-Bold", size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("primaryTheme"))
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: Color("primaryTheme").opacity(0.3), radius: 10, y: 5)
            }
            
            Button(action: { isReceiveActionSheetPresented = true }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                    Text("Receive")
                        .font(.custom("ZohoPuvi-Bold", size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("GrayButtonColor"))
                .foregroundColor(.font)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            }
        }
    }
        
    
    func fillcoins(){
        Task {
            balance = 0.0
            do {
                coins = try await ServerResponce.shared.fetchuserholdings()
                for i in coins{
                    let price = try await fetchPrice(coinName: i.coin.coinSymbol).result.list[0].lastPrice
                    balance += i.quantity * (Double(price) ?? 0)
                }
                animateBalanceUpdate(to: balance)
            } catch {
                print("Failed to fetch coins: \(error.localizedDescription)")
            }
        }
    }
    

    
    func animateBalanceUpdate(to newBalance: Double) {
        let duration: Double = 2
        let steps = 50
        let stepInterval = duration / Double(steps)
        
        var currentStep = 0
        let startBalance = balance
        
        // Timer to animate the balance update smoothly over steps
        Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { timer in
            let progress = Double(currentStep) / Double(steps)
            balance = startBalance + (newBalance - startBalance) * progress
            currentStep += 1
            
            if currentStep > steps {
                timer.invalidate()
            }
        }
    }
}


#Preview {
    WalletView()
}

