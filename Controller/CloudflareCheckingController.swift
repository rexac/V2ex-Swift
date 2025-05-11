//
//  CloudflareCheckingController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2021/2/18.
//  Copyright © 2021 Fin. All rights reserved.
//

import UIKit
import WebKit

class CloudflareCheckingController: UIViewController, WKNavigationDelegate {
    let webView:WKWebView = WKWebView()
    var completion: (() -> ())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.webView.customUserAgent = USER_AGENT
        self.webView.backgroundColor = self.view.backgroundColor
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self.view)
        }
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        _ = self.webView.load(URLRequest(url: URL(string: V2EXURL)!))
    }

    // Cloudflare 检查后设置 cookies
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let processCookies = { [weak self] (cookies: [HTTPCookie]) in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            if let _ = cookies.first(where: { $0.name == "V2EX_LANG" }) {
                self?.dismiss(animated: true) {
                    self?.completion?()
                }
            }
        }

        if #available(iOS 11.0, *) {
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies(processCookies)
        } else {
            if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: V2EXURL)!) {
                processCookies(cookies)
            }
        }
    }
}
