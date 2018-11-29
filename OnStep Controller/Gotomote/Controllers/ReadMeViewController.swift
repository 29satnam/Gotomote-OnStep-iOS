//
//  ReadMeViewController.swift
//  Gotomote
//
//  Created by Satnam on 11/29/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit

class ReadMeViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.navigationItem.title = "ABOUT"
        webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "readme", ofType: "html")!)))
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == UIWebView.NavigationType.linkClicked {
            UIApplication.shared.open(request.url!)
        }
        return true

    }
}
