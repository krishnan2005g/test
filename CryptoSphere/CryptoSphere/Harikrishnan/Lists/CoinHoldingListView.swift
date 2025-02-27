//
//  UsersListView 2.swift
//  Real app
//
//  Created by Harikrishnan V on 2025-02-06.
//

import SwiftUI
import Kingfisher
import SwiftData

struct CoinHoldingListView: View {
    
    @State private var userHoldings: [UserHolding] = []
    @State private var coinValues: [String: Double] = [:]
    @State private var searchText: String = ""
    @State private var isLoading = false
    
    @Namespace var nameSpace
    @Environment(\.globalViewModel) var globalViewModel
    
    @State var selectedCoin: UserHolding? = nil
    
    var hasNavigate: Bool
    
    var filteredUserHolding: [UserHolding] {
        searchText.isEmpty ? userHoldings : userHoldings.filter { $0.coin.coinSymbol.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack{
            Group {
                 if isLoading {
                     LoadingView()
                 } else {
                     contentView
                 }
             }
            .onAppear {
                fetchCoins()
            }
             .transition(.opacity)
            
            if let selectedCoin = selectedCoin, hasNavigate {
                NavigationStack{
                    SendView(userHolding: selectedCoin, nameSpace: nameSpace)
                        .zIndex(1)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back") {
                                    withAnimation {
                                        self.selectedCoin = nil
                                    }
                                }
                            }
                        }
                }
            }
        }
        .background(.black)
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                SearchBar(searchText: $searchText)
                    .padding(.horizontal)
                
                ForEach(filteredUserHolding, id: \.self) { userHolding in
                    CoinCardView(userHolding: userHolding)
                        .onTapGesture { handleSelection(userHolding) }
                        .matchedGeometryEffect(id: userHolding.coin.id, in: nameSpace)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .padding(.vertical)
        }
        .overlay(
            Group {
                if filteredUserHolding.isEmpty && !isLoading {
                    EmptyStateView()
                }
            }
        )
    }
    
    private func CoinCardView(userHolding: UserHolding) -> some View {
        HStack(spacing: 16) {
            SymbolWithNameView(coin: userHolding.coin, searchText: "", nameSpace: nameSpace)
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\((userHolding.quantity * (coinValues[userHolding.coin.coinSymbol] ?? 0.0)).formatted(.currency(code: "USD")))")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                Spacer()
                HStack {
                    Text("Units:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(userHolding.quantity.formatted(.number.precision(.fractionLength(2))))
                        .font(.system(.subheadline, design: .monospaced).weight(.medium))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding(.horizontal)
    }
    
    private func handleSelection(_ holding: UserHolding) {
        globalViewModel.selectedCoin = holding
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring()) {
            selectedCoin = holding
        }
    }
    
    private func fetchCoins() {
        isLoading = true
        Task {
            defer { isLoading = false }
            userHoldings = try await ServerResponce.shared.fetchuserholdings()
            
            for userHolding in userHoldings {
                coinValues[userHolding.coin.coinSymbol] = await getPrice(coinSymbol: userHolding.coin.coinSymbol)
            }
        }
    }
    
    private func getPrice(coinSymbol: String) async -> Double {
        do {
            return try await Double(fetchPrice(coinName: coinSymbol).result.list[0].lastPrice) ?? 0.0
        } catch {
            print("Error fetching price: \(error)")
            return 0.0
        }
    }
    
}

struct SymbolWithNameView: View {
    
    var coin: CoinDetails
    @State var searchText: String
    var nameSpace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 8) {
            KFImage(URL(string: coin.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .matchedGeometryEffect(id: "i\(coin.imageUrl)", in: nameSpace)
            
            
            VStack(alignment: .leading, spacing: 4) {
                highlightedUsername(coin.coinName)
                    .matchedGeometryEffect(id: "cn\(coin.coinName)", in: nameSpace)
                    .font(.custom("ZohoPuvi-Semibold", size: 20))
                    .foregroundColor(.primary)
                highlightedUsername(coin.coinSymbol == "ZOINUSDT" ? "ZOIN" : coin.coinSymbol)
                    .matchedGeometryEffect(id: "cs\(coin.coinSymbol)", in: nameSpace)
                    .font(.custom("ZohoPuvi-Semibold", size: 12))
                    .foregroundColor(.secondary)
            }

        }
        .transition(.slide)
    }
    
    private func highlightedUsername(_ username: String) -> Text {
        guard let range = username.lowercased().range(of: searchText.lowercased()) else {
            return Text(username)
        }
        
        let before = Text(String(username[..<range.lowerBound]))
        let highlighted = Text(String(username[range])).foregroundColor(Color("primaryTheme"))
        let after = Text(String(username[range.upperBound...]))
        
        return before + highlighted + after
    }
    
}

#Preview {
    CoinHoldingListView(hasNavigate: true)
}



struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            TextField("Search coins...", text: $searchText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 36)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("GrayButtonColor"))
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 12)
                        )
                )
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No Holdings Found",
            systemImage: "bitcoinsign.bank.building.fill"
        )
    }
}


struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.primaryTheme)
            
            Text("Loading Holdings...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
