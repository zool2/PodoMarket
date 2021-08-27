//
//  WebViewController.swift
//  PodoMarket
//
//  Created by TJ on 19/08/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var mainVC: FindTownViewController? = nil
    var townName: String?
    
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestUrlandLoadWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func loadView() {
        
        let webConfiguration = WKWebViewConfiguration() // 웹 뷰를 초기화할 property 들의 collection
        
        let contentController = WKUserContentController() // JavaScript가 메시지를 게시하고 웹 보기에 사용자 스크립트를 주입하는 방법 제공
        
        let userScript = WKUserScript(source: "javascript:sample2_execDaumPostcode()",
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true) // WKUserScript 개체는 웹 페이지에 주입할 수 있는 스크립트를 나타냄
        
        contentController.addUserScript(userScript)
        contentController.add(self as WKScriptMessageHandler, name: "callback")
        
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    func requestUrlandLoadWebView() {
        // 우편번호 서비스가 구현된 웹페이지 URL
        guard let url = URL(string: "http://jurije46.dothome.co.kr/daum.html") else { return }
        
        let request = URLRequest(url: url)
        
        webView.navigationDelegate = self
        webView?.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("loaded")
    }

    // 웹 페이지에서 스크립트 메시지를 수신할 때 호출됨.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let response = message.body as? String else { return }
        
        let address: String = response
        
        townName = seperateTownNameFromAddress(address: address)
        
        if let vc = self.mainVC {
            vc.recieveTownName = townName!
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func seperateTownNameFromAddress(address: String ) -> String {

        let addressArr = address.components(separatedBy: "(")
        let stringAddress1: String = addressArr[1]

        let myTown = stringAddress1.trimmingCharacters(in: [")"])
        print("myTown: \(myTown)")
        
        return myTown
    }

    
}
