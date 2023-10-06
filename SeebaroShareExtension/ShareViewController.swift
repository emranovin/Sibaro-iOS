//
//  ShareViewController.swift
//  SeebaroShareExtension
//
//  Created by AminRa on 7/10/1402 AP.
//
import UIKit
import Social
import ZSign
import UniformTypeIdentifiers
import DependencyFactory
import CryptoKit

class ShareViewController: UIViewController, ObservableObject {
    
    @Injected(\.storage) var storage
    @Injected(\.authRepository) var auth
    @Injected(\.signer) var signer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: dsign a proper view for share extension
        // https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view/25706250
        
        // only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled == false {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        // Check if object is of type text
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] (item, error) in
                guard let self else { return }
                if let error = error {
                    print("URL-Error: \(error.localizedDescription)")
                }
                if let url = item as? URL {
                    if storage.token != nil {
                        let signedURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.seebaro.app")!.appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.copyItem(at: url, to: signedURL)
                        Task { [weak self] in
                            guard let self else { return }
                            let properties = await signer.getCredentialsAndSign(sourceIPAURL: url, signedIPAURL: signedURL)
                            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                        }
                    } else {
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                } else {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
                
            }
        } else {
            print("Error: No url or text found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
