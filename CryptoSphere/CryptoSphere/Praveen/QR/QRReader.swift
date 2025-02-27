import UIKit
import AVFoundation

class GPayScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var scannedQRCode: String?

    // MARK: - UI Elements
    private let snapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .orange
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let flashlightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .orange
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .orange
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let greyTint: UIView = {
        let imageView = UIView()
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to access camera: \(error)")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Failed to add camera input")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Failed to add metadata output")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black

        // Add buttons
        view.addSubview(snapButton)
        view.addSubview(flashlightButton)
        view.addSubview(galleryButton)
        view.addSubview(greyTint)

        // Add constraints
        NSLayoutConstraint.activate([
            // Snap Button
            snapButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            snapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapButton.widthAnchor.constraint(equalToConstant: 60),
            snapButton.heightAnchor.constraint(equalToConstant: 60),

            // Flashlight Button
            flashlightButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            flashlightButton.centerYAnchor.constraint(equalTo: snapButton.centerYAnchor),
            flashlightButton.widthAnchor.constraint(equalToConstant: 50),
            flashlightButton.heightAnchor.constraint(equalToConstant: 50),

            // Gallery Button
            galleryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            galleryButton.centerYAnchor.constraint(equalTo: snapButton.centerYAnchor),
            galleryButton.widthAnchor.constraint(equalToConstant: 50),
            galleryButton.heightAnchor.constraint(equalToConstant: 50),
            
            greyTint.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            greyTint.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
        ])

        // Add button actions
        snapButton.addTarget(self, action: #selector(snapButtonTapped), for: .touchUpInside)
        flashlightButton.addTarget(self, action: #selector(flashlightButtonTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
    }

    // MARK: - Button Actions
    @objc private func snapButtonTapped() {
        print("Snap button tapped")
        animateSnapButton()
    }

    @objc private func flashlightButtonTapped() {
        print("Flashlight button tapped")
        toggleFlashlight()
    }

    @objc private func galleryButtonTapped() {
        print("Gallery button tapped")
        openGallery()
    }

    // MARK: - Flashlight Logic
    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("Failed to toggle flashlight: \(error)")
        }
    }

    // MARK: - Gallery Logic
    private func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    // MARK: - QR Code Handling
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue {
            scannedQRCode = stringValue
            print("Scanned QR Code: \(stringValue)")
            animateSnapButton()
        }
    }

    // Function to return scanned QR code
    func getScannedQRCode() -> String? {
        return scannedQRCode
    }

    // MARK: - Snap Button Animation
    private func animateSnapButton() {
        snapButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        snapButton.tintColor = .white

        UIView.animate(withDuration: 0.1, animations: {
            self.snapButton.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.snapButton.alpha = 1.0
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.snapButton.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
                    self.snapButton.tintColor = .white
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension GPayScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if info[.originalImage] is UIImage {
            print("Selected image from gallery")
            // Add logic to process the selected image (e.g., detect QR code)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

#Preview {
    GPayScannerViewController()
}
