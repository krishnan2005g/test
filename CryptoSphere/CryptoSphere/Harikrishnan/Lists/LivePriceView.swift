//
//  LivePrice.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-25.
//

import SwiftUI
import Combine

struct LivePriceView: View {
    var coinSymbol: String
    @State private var price: Double = 0.0
    @State private var previousPrice: Double = 0.0
    @State private var change24h: String = "0.00"
    @State private var cancellable: AnyCancellable?
    @State private var changeCancellable: AnyCancellable?

    var body: some View {
        VStack (alignment: .trailing, spacing: 8){
            Text(price == 0.0 ? "..." : price.formatted(.currency(code: "USD").precision(.fractionLength(1))))
                .font(.custom("ZohoPuvi-Medium", size: 16))
                .foregroundStyle(priceColor)

            Text(change24h)
                .font(.custom("ZohoPuvi-Medium", size: 13))
        }
        .onAppear {
            startFetching()
        }
        .onDisappear {
            cancellable?.cancel()
            changeCancellable?.cancel()
        }
    }

    var priceColor: Color {
        if price > previousPrice {
            return .green
        } else if price < previousPrice {
            return .red
        } else {
            return .font
        }
    }
    
    var changeColor: Color {
        if let changeValue = Double(change24h.replacingOccurrences(of: "%", with: "")) {
            if changeValue >= 1.0 {
                return .green
            } else {
                return .red
            }
        }
        return .font
    }

    func startFetching() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in fetchPrice() }
            .receive(on: DispatchQueue.main)
            .sink { newPrice in
                previousPrice = price
                price = newPrice
            }
        
        changeCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in fetchChange24h() }
            .receive(on: DispatchQueue.main)
            .sink { change in
                change24h = change
            }
    }

    func fetchPrice() -> Future<Double, Never> {

        return Future { promise in
            Task {
                do {
                    if let newPrice = try await CryptoSphere.fetchPrice(coinName: coinSymbol).result.list.first?.lastPrice {
                        let priceValue = Double(newPrice) ?? 0.0
                        promise(.success(priceValue))
                    } else {
                        promise(.success(price)) // Keep previous price if fetch fails
                    }
                } catch {
                    print("Error fetching price: \(error)")
                    promise(.success(price))
                }
            }
        }
    }
    
    func fetchChange24h() -> Future<String, Never> {
        return Future { promise in
            Task {
                let now = Int(Date().timeIntervalSince1970 * 1000)
                let start = Int(Calendar.current.date(byAdding: .hour, value: -24, to: Date())!.timeIntervalSince1970 * 1000)
                let intervals = [1, 3, 5, 15, 30, 60, 120, 240, 360, 720]
                let interval = String(intervals.first { $0 >= Int((Double(now - start) / (1000 * 60 * 25)).rounded(.up)) } ?? intervals.last!)
                
                do {
                    let previousPrices = try await PreviousPriceResponse().fetchPreviousPrice(coinName: coinSymbol == "ZOINUSDT" ? "BTCUSDT" : coinSymbol, from: start, to: now, interval: interval).reversed()
                    
                    if let firstPrice = previousPrices.first?.close {
                        let change = ((price - firstPrice) / firstPrice) * 100
                        promise(.success(String(format: "%.2f%%", change)))
                    } else {
                        promise(.success("0.00%"))
                    }
                } catch {
                    print("Error fetching change: \(error)")
                    promise(.success("0.00%"))
                }
            }
        }
    }
}

#Preview {
    LivePriceView(coinSymbol: "ZOINUSDT")
}
