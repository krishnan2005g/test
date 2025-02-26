import Foundation

func xorEncrypt(_ text: String, key: String) -> String {
    let textBytes = Array(text.utf8)
    let keyBytes = Array(key.utf8)
    
    // XOR encryption
    let encryptedBytes = textBytes.enumerated().map { $0.element ^ keyBytes[$0.offset % keyBytes.count] }
    
    // Convert to Base64 twice to make it longer
    let base64Once = Data(encryptedBytes).base64EncodedString()
    let base64Twice = Data(base64Once.utf8).base64EncodedString()
    
    return base64Twice
}

func xorDecrypt(_ encryptedText: String, key: String) -> String? {
    // Decode Base64 twice
    guard let decodedOnceData = Data(base64Encoded: encryptedText),
          let decodedOnceString = String(data: decodedOnceData, encoding: .utf8),
          let decodedData = Data(base64Encoded: decodedOnceString) else { return nil }
    
    let textBytes = Array(decodedData)
    let keyBytes = Array(key.utf8)
    
    // XOR decryption
    let decryptedBytes = textBytes.enumerated().map { $0.element ^ keyBytes[$0.offset % keyBytes.count] }
    
    return String(bytes: decryptedBytes, encoding: .utf8)
}
