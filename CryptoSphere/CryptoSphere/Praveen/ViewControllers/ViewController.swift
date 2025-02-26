//
//import UIKit
//import Foundation
//
//struct CryptoResponse2: Decodable {
//    let bitcoin: CryptoPrice?
//    let ethereum: CryptoPrice?
//}
//
//struct CryptoPrice: Codable{
//    let usd: Double
//}
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd")!
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let error = error {
//            print("❌ Error:", error.localizedDescription)
//            return
//        }
//
//        guard let data = data else {
//            print("❌ No data received")
//            return
//        }
//
//        do {
//            // ✅ Decode JSON
//            let decodedData = try JSONDecoder().decode(CryptoResponse.self, from: data)
//            
//            // ✅ Access the parsed data
//            if let bitcoinPrice = decodedData.bitcoin?.usd {
//                print("Bitcoin Price: $\(bitcoinPrice)")
//            }
//            
//            if let ethereumPrice = decodedData.ethereum?.usd {
//                print("Ethereum Price: $\(ethereumPrice)")
//            }
//
//        } catch {
//            print("❌ JSON Decoding Error:", error.localizedDescription)
//        }
//    }
//
//    // 🔥 Start the request
//    task.resume()
//
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")
//    
//    let task = URLSession.share.dataTask(with: url) { data, response, error in
//        if let error = error {
//                print("❌ Error:", error.localizedDescription)
//                return
//        }
//        guard let data = data else {
//            print("❌ No data returned.")
//            return
//        }
//        do{
//            if let jsonString = try String(data: data, encoding: .utf8), case let try jsonObject = JSONDecoder().decode(self, from: jsonString) {
//                
//            }
//        }
//    }
//}
//
