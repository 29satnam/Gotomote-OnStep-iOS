//
//  ReadMeViewController.swift
//  Gotomote
//
//  Created by Satnam on 11/29/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import WebKit

class ReadMeViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ABOUT"
        //webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "readme", ofType: "html")!)))
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "readme", ofType: "html")!)
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}
