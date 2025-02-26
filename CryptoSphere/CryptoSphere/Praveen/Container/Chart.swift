import SwiftUI
import Charts
import Combine

struct ChartViews: View {
    let coin: String
    let lineWidth: Int
    init(coin: String, lineWidth: Int){
        self.coin = coin
        self.lineWidth = lineWidth
    }
    
    init(coin: String){
        self.coin = coin
        self.lineWidth = 3
    }
    
    @State private var progress: CGFloat = 0
    @State private var chartData: [PreviousData] = []
    @State private var cancellable: AnyCancellable?
    @State private var lineColor: Color = .gray
    
    static var chartColor: Color = .gray

    var body: some View {
        VStack {
            if !chartData.isEmpty {
                AnimatedChart()
                    .shadow(color: lineColor.opacity(0.6), radius: 6, x: 0, y: 5)
                    .shadow(color: lineColor.opacity(0.4), radius: 7, x: 0, y: 10)
                    .shadow(color: lineColor.opacity(0.1), radius: 8, x: 0, y: 20)
                    .shadow(color: lineColor.opacity(0.08), radius: 9, x: 0, y: 30)
                    .shadow(color: lineColor.opacity(0.05), radius: 10, x: 0, y: 40)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await getData()
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        Chart {
            ForEach(chartData) { data in
                LineMark(x: .value("Time", data.formattedTime, unit: .second),
                          y: .value("Price", data.close ))
                .foregroundStyle(lineColor)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: CGFloat(lineWidth)))
            }
        }
        .padding(4)
        .mask(Rectangle().scaleEffect(x: progress, anchor: .leading))
        .chartYScale(domain: yAxisDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden) // Hide Y axis
        .onAppear {
            setLineColor()
            Task{
                await getData()
            }
            withAnimation(.easeOut(duration: 0.5)) { progress = 1 }
        }
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        let closes = chartData.map { $0.close }
        guard let minClose = closes.min(), let maxClose = closes.max() else {
            return 0...0
        }
        return minClose...maxClose
    }
    
    func getData() async {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        let start = Int(Calendar.current.date(byAdding: .hour, value: -24, to: Date())!.timeIntervalSince1970 * 1000)
        let intervals = [1, 3, 5, 15, 30, 60, 120, 240, 360, 720]
        let interval = String(intervals.first { $0 >= Int((Double(now - start) / (1000 * 60 * 25)).rounded(.up)) } ?? intervals.last!)
        
        do {
            chartData = try await PreviousPriceResponse().fetchPreviousPrice(coinName: coin, from: start, to: now, interval: interval).reversed()
            setLineColor()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func updateData() async {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await getData()
                }
            }
    }
    
    func setLineColor() {
        let first = chartData.first?.close ?? 0
        let last = chartData.last?.close ?? 0
        lineColor = last > first ? .green : last < first ? .red : .gray
        ChartViews.chartColor = lineColor
    }
}

#Preview {
    ChartViews(coin: "ZOINUSDT")
        .padding(60)
}
