//
//  Credentials.swift
//  simple-p2p
//
//  Created by Wayne Carter on 4/29/23.
//

import Foundation

// NOTE: This is a convenience class for loading the client Identity and
// Certificate Authority for authenticating peers and securing communication.
// To simplify the demo this pulls the identity and CA certificate from files
// embedded in the app. In a realworld use-case the identity would more than
// likely come from the keychain instead of embedding it in the app.
class Credentials {
    static func async(_ async: @escaping (SecIdentity, SecCertificate) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            async(identity, ca)
        }
    }
    
    private static let identity: SecIdentity = {
        let url = Bundle.main.url(forResource: "client_key", withExtension: "p12")!
        let data = try! Data(contentsOf: url)
        
        var result: CFArray?
        let options: [String: Any] = [kSecImportExportPassphrase as String: ""]
        // NOTE: This method is not supposed to be called on the main
        // thread. That is why the get function is async.
        let status = SecPKCS12Import(data as CFData, options as NSDictionary, &result)
        let items = result as! [[String: Any]]
        let item = items.first!
        let identity = item[kSecImportItemIdentity as String] as! SecIdentity
        
        return identity
    }()
    
    private static let ca: SecCertificate = {
        let url = Bundle.main.url(forResource: "ca_cert", withExtension: "der")!
        let data = try! Data(contentsOf: url)
        let ca = SecCertificateCreateWithData(nil, data as CFData)!
        
        return ca
    }()
}
