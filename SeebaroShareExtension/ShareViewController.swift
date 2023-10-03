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
                if let url = item as? NSURL, let urlString = url.absoluteString {
                    if storage.token != nil {
                        Task { [weak self] in
                            guard let self else { return }
                            try await signer.getCredentials()
                            let signed_flag = zsign(
                                urlString,
                                self.storage.cert.url.absoluteString,
                                self.storage.p12.url.absoluteString,
                                self.storage.profile.url.absoluteString,
                                signer.p12Password
                            )
                            print(signed_flag)
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
