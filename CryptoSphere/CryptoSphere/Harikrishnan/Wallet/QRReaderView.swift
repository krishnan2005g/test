import SwiftUI
import AVFoundation

struct QRReaderView: View {
    @Binding var scannedCode:String
    @State private var showError = false
    
    @State var isScaning:Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 26))
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Place the QR code inside the frame")
                .font(.custom("ZohoPuvi-Bold", size: 20))
                .padding(.top, 40)
            
            Text("Scanning will automatically begin")
                .font(.custom("ZohoPuvi-Medium", size: 16))
                .foregroundStyle(.gray)
                .padding(.top, 10)
            
            Spacer()
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(0...3, id: \.self) { index in  // 0...3 for four corners
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            .trim(from: 0.60, to: 0.65)
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(Color("primaryTheme"))
                            .rotationEffect(.degrees(Double(index * 90)))
                            .offset(x: (index == 0 || index == 3) ? -16 : 16,
                                    y: (index == 0 || index == 1) ? -20 : 20)
                    }


                    QRScannerView { code in
                        scannedCode = code
                        dismiss()
                    } onError: { error in
                        showError = true
                    }
                    .cornerRadius(20)
                }
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2, style: .circular)
                        .frame(height: 2)
                        .foregroundStyle(.primaryTheme)
                        .shadow(color: Color("primaryTheme").opacity(0.35),radius: 8, x:0, y: isScaning ? 20 : -20)
                        .offset(y: isScaning ? geometry.size.height : 0)
                }

                .frame(width: geometry.size.width, height: geometry.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 240, height: 240)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).delay(0.2).repeatForever()){
                    isScaning = true
                }
            }

            
            Spacer(minLength: 15)
            
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 45))
                .bold()
                .foregroundStyle(Color("primaryTheme"))
        }
        .alert("Error", isPresented: $showError) {
            Button("error") { showError = false }
        }
        .padding(16)
    }
}

struct QRScannerView: UIViewRepresentable {
    let onCodeScanned: (String) -> Void
    let onError: (String) -> Void
    
    func makeUIView(context: Context) -> ScannerView {
        let view = ScannerView()
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: ScannerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned, onError: onError)
    }
    
    class Coordinator: NSObject, ScannerViewDelegate {
        let onCodeScanned: (String) -> Void
        let onError: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
            self.onError = onError
        }
        
        func codeDidScan(_ code: String) { onCodeScanned(code) }
        func scanningDidFail(_ error: String) { onError(error) }
    }
}

protocol ScannerViewDelegate: AnyObject {
    func codeDidScan(_ code: String)
    func scanningDidFail(_ error: String)
}

class ScannerView: UIView {
    weak var delegate: ScannerViewDelegate?
    private var captureSession: AVCaptureSession?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            delegate?.scanningDidFail("Camera unavailable")
            return
        }
        
        let session = AVCaptureSession()
        self.captureSession = session
        
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            delegate?.scanningDidFail("Could not add video input")
            return
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        } else {
            delegate?.scanningDidFail("Could not add metadata output")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        Task{
            session.startRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let previewLayer = layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = layer.bounds
        }
    }
    
    deinit {
        captureSession?.stopRunning()
    }
}

extension ScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        captureSession?.stopRunning()
        delegate?.codeDidScan(code)
    }
}

#Preview {
    QRReaderView(scannedCode: .constant(""))
}
