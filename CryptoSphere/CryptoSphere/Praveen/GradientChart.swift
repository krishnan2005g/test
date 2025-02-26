import UIKit

class GradientChartView: UIView {

    struct Configuration {
        var dataPoints: [CGFloat]
        var timeLabels: [String]
        var lineColor: UIColor
        var gridColor: UIColor
        var textColor: UIColor
        var minValue: CGFloat
        var maxValue: CGFloat
        var isGradientEnabled: Bool
        var showGridLines: Bool
        var lineWidth: CGFloat
        var fontSize: CGFloat
        
        static var `default`: Configuration {
            return Configuration(
                dataPoints: [],
                timeLabels: [],
                lineColor: .black,
                gridColor: .gray,
                textColor: .black,
                minValue: 0,
                maxValue: 0,
                isGradientEnabled: false,
                showGridLines: true,
                lineWidth: 1.0,
                fontSize: 12.0
            )
        }
    }
    
    var config: Configuration
    private var selectedTimeIndex = 0
    private var priceLabels: [String] = []
    private var originalDataPoints: [CGFloat] = []
    
//    private lazy var timeSegmentControl: UISegmentedControl = {
//        let control = UISegmentedControl(items: config.timeLabels)
//        control.selectedSegmentIndex = selectedTimeIndex
//        control.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
//        control.selectedSegmentTintColor = UIColor.darkGray
//        control.setTitleTextAttributes([.foregroundColor: config.textColor], for: .normal)
//        control.setTitleTextAttributes([.foregroundColor: config.textColor], for: .selected)
//        control.translatesAutoresizingMaskIntoConstraints = false
//        control.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
//        return control
//    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(frame: CGRect = .zero, configuration: Configuration = .default) {
        self.config = configuration
        self.originalDataPoints = configuration.dataPoints
        super.init(frame: frame)
        setupView()
        animateChart()
    }
    
    required init?(coder: NSCoder) {
        self.config = .default
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with configuration: Configuration) {
        self.config = configuration
        self.originalDataPoints = configuration.dataPoints
        setupView()
        animateChart()
    }

    
    private func setupView() {
        backgroundColor = .background
        
//        addSubview(timeSegmentControl)
        addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
//            timeSegmentControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            timeSegmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            timeSegmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            timeSegmentControl.heightAnchor.constraint(equalToConstant: 40),
//
            priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    private func animateChart() {

            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.config.dataPoints = self.originalDataPoints
                self.setNeedsDisplay()
            }, completion: nil)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !config.dataPoints.isEmpty else { return }
        
        let chartRect = CGRect(x: 0,
                             y: 0,
                             width: bounds.width,
                             height: bounds.height - 10)
        
        if config.showGridLines {
            drawGrid(in: chartRect, context: context)
        }
        
        drawChartLine(in: chartRect, context: context)
    }
    
    private func drawGrid(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(config.gridColor.cgColor)
        context.setLineWidth(0.2)
        
        let verticalSpacing = rect.width / CGFloat(5)
        for i in 0...5 {
            let x = rect.minX + verticalSpacing * CGFloat(i)
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        
        let horizontalSpacing = rect.height / CGFloat(5)
        for i in 0...5 {
            let y = rect.minY + horizontalSpacing * CGFloat(5 - i)
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            
            let value = config.minValue + (config.maxValue - config.minValue) * CGFloat(i) / 5
            let label = String(format: "$%.2f", value)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: config.textColor,
                .font: UIFont.systemFont(ofSize: config.fontSize)
            ]
            let labelSize = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: rect.maxX - 0,
                                   y: y - labelSize.height/2),
                       withAttributes: attributes)
        }

        
        context.strokePath()
    }
    
    private func drawChartLine(in rect: CGRect, context: CGContext) {

        let valueRange = config.maxValue - config.minValue
        guard valueRange > 0 else { return }

        let xStep = rect.width / CGFloat(config.dataPoints.count - 1)
        let scaleFactor = rect.height / valueRange

        let points = config.dataPoints.enumerated().map { index, value in
            CGPoint(
                x: rect.minX + CGFloat(index) * xStep,
                y: rect.maxY - (value - config.minValue) * scaleFactor
            )
        }
            
        guard let minValue = config.dataPoints.min(), let maxValue = config.dataPoints.max() else { return }
        let minIndex = config.dataPoints.firstIndex(of: minValue)!
        let maxIndex = config.dataPoints.firstIndex(of: maxValue)!

        let minPoint = points[minIndex]
        let maxPoint = points[maxIndex]

        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        context.setLineWidth(config.lineWidth)
        context.setStrokeColor(config.lineColor.cgColor)
        path.stroke()

        if config.isGradientEnabled {
            context.saveGState()

            let fillPath = path.cgPath.mutableCopy()!
            fillPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            fillPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            fillPath.closeSubpath()

            context.addPath(fillPath)
            context.clip()

            let colors = [
                config.lineColor.withAlphaComponent(0.5).cgColor,
                config.lineColor.withAlphaComponent(0).cgColor
            ]
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            )!

            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: rect.minY),
                end: CGPoint(x: 0, y: rect.maxY),
                options: []
            )

            context.restoreGState()
        }

        drawDot(at: minPoint, context: context)
        drawDot(at: maxPoint, context: context)

        annotatePoint(minPoint, value: minValue, context: context, isMax: false)
        annotatePoint(maxPoint, value: maxValue, context: context, isMax: true)
    }

    private func drawDot(at point: CGPoint, context: CGContext) {
        let dotRadius: CGFloat = 5.0
        let dotRect = CGRect(
            x: point.x - dotRadius + 1,
            y: point.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        
        context.setFillColor(config.lineColor.cgColor)
        context.fillEllipse(in: dotRect)
    }

    private func annotatePoint(_ point: CGPoint, value: CGFloat, context: CGContext, isMax: Bool) {
        let text = String(format: "$%.2f", value)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: config.textColor.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: config.fontSize, weight: .bold)
        ]
        let textSize = text.size(withAttributes: attributes)

        var yOffset: CGFloat = isMax ? -textSize.height - 8 : 8

        if isMax && point.y - textSize.height - 8 < bounds.minY {
            yOffset = 8
        } else if !isMax && point.y + textSize.height + 8 > bounds.maxY {
            yOffset = -textSize.height - 8
        }

        let textPosition = CGPoint(
            x: max(bounds.minX, min(point.x - textSize.width / 2, bounds.maxX - textSize.width)),
            y: point.y + yOffset
        )

        text.draw(at: textPosition, withAttributes: attributes)
    }


    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        selectedTimeIndex = sender.selectedSegmentIndex
        setNeedsDisplay()
    }
}


class GradientChartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let defaultChartView = GradientChartView(configuration: GradientChartView.Configuration.default)

        let configuration = GradientChartView.Configuration(
            dataPoints: [83.28, 78.5, 75.8, 32.78, 72.5, 50.2, 70.29, 71.5, 72.76, 53.8],
            timeLabels: defaultChartView.config.timeLabels,
            lineColor: .orange,
            gridColor: UIColor.gray.withAlphaComponent(0.1),
            textColor: .white,
            minValue: 0,
            maxValue: 100,
            isGradientEnabled: true,
            showGridLines: true,
            lineWidth: 1000,
            fontSize: 12.0
        )
        
        let chartView = GradientChartView(configuration: configuration)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
            
        ])
    }
}

#Preview{
    GradientChartViewController()
}
