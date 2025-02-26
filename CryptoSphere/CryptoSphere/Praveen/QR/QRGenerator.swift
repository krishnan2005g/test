import UIKit
import CoreImage.CIFilterBuiltins

class QRCodeView: UIView {
    // MARK: - UI Elements
    private let qrImageView = UIImageView()
    private let value: String

    // MARK: - Initializers
    init(_ value: String) {
        self.value = value
        super.init(frame: .zero)
        setupUI()
        generateQRCode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        // Configure the UIImageView
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(qrImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            qrImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 200),
            qrImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    // MARK: - QR Code Generation
    private func generateQRCode() {
        if let qrImage = generateQRCodeImage(from: value) {
            qrImageView.image = qrImage
        } else {
            print("Failed to generate QR code")
        }
    }

    private func generateQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            return UIImage(ciImage: transformedImage)
        }
        return nil
    }
}

// MARK: - ViewController
class QRCodeViewController: UIViewController {
    private let qrCodeView = QRCodeView("Hello, QR!")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRCodeView()
    }

    private func setupQRCodeView() {
        view.backgroundColor = .white
        view.addSubview(qrCodeView)
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qrCodeView.topAnchor.constraint(equalTo: view.topAnchor),
            qrCodeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrCodeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            qrCodeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

#Preview {
    QRCodeView("hellaao")
}

