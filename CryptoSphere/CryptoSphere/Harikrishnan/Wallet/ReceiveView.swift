import SwiftUI
import Kingfisher
import EFQRCode
import AudioToolbox

struct ReceiveView: View {
    let coin: CoinDetails
    @State var address: String?
    @Environment(\.globalViewModel) var globalViewModel
    var logoAnimation: Namespace.ID
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(white: 0.1), Color(white: 0.05), Color(white: 0.1)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .blur(radius: 10)
                    .frame(width: 260, height: 260)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [
                            .primaryTheme,
                            Color.clear,
                            Color.clear,
                            .primaryTheme,
                            Color.clear,
                            Color.clear,
                            .primaryTheme,
                            Color.clear,
                            Color.clear,
                            .primaryTheme, // Light Gray
                        ]), center: .center, angle: .degrees(rotationAngle))
                        , lineWidth: 3
                    )
                    .frame(width: 260, height: 260)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                
                if let qrImage = generateQRCode(from: address ?? "") {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                
                VStack{
                    KFImage(URL(string: coin.imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.black))
                        .clipShape(Circle())
                        .matchedGeometryEffect(id: "i\(coin.imageUrl)", in: logoAnimation)
                        .offset(y: 20)
                        
                    Spacer()
                }
            }
            .frame(width: 300, height: 360)
            
            if let address = address {
                HStack {
                    Image(systemName: "wallet.bifold")
                        .foregroundColor(.white)
                    Text(address)
                        .font(.custom("ZohoPuvi-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(12)
                .padding(.horizontal, 6)
                .background(.gray.opacity(0.25).gradient)
                .cornerRadius(12)
                .padding(.top, 10)
                
            } else {
                
                Text("Address Unavailable")
                    .font(.custom("ZohoPuvi-SemiBold", size: 18))
                    .foregroundColor(.orange)
            }
            
            
            Spacer()
            
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                
                Text("Only send \(coin.coinName) (\(coin.coinSymbol)) to this address")
                    .font(.custom("ZohoPuvi-SemiBold", size: 14))
                    .foregroundColor(.gray) // Softer color for better readability
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 6)

            
            Button(action: {
                copyToClipboard()
            }) {
                HStack {
                    Image(systemName: "square.on.square")
                    Text("Copy Address")
                }
                .font(.custom("ZohoPuvi-SemiBold", size: 20))
                .foregroundColor(.font)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.primaryTheme)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .onTapGesture {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            .disabled(address == nil)
        }
        .onAppear {
            self.address = xorEncrypt("\(globalViewModel.session.username)_\(coin.id)", key: "c")
        }
        .background(.black)
        .ignoresSafeArea()
        
        Spacer()
        
    }
    
    func copyToClipboard() {
        if let address {
            UIPasteboard.general.string = address
        }
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        if let cgImage = EFQRCode.generate(
            for: string,
            backgroundColor: UIColor.clear.cgColor,  // Transparent background
            foregroundColor: UIColor.white.withAlphaComponent(0.8).cgColor,  // White QR code
            watermark: UIImage(named: "logo")?.cgImage,  // Logo overlay (ensure high error correction)
            pointStyle: .square // Stylish QR pattern
        ) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}

#Preview {
    ReceiveView(coin: CoinDetails(
        id: 1,
        coinName: "Bitcoin",
        coinSymbol: "BTC",
        imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579"
    ), logoAnimation: Namespace().wrappedValue)
}
