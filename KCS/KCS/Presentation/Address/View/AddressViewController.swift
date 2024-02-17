//
//  AddressViewController.swift
//  KCS
//
//  Created by 김영현 on 2/18/24.
//

import WebKit

final class AddressViewController: UIViewController {
    
    private let loadIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private lazy var addressContentController: WKUserContentController = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callBackHandler")
        
        return contentController
    }()
    
    private lazy var addressConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = addressContentController
        
        return configuration
    }()
    
    private lazy var addressWebView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: addressConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUIComponents()
        configureConstraints()
        setWebView()
    }
}

private extension AddressViewController {
    
    func addUIComponents() {
        view.addSubview(addressWebView)
        view.addSubview(loadIndicator)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            addressWebView.topAnchor.constraint(equalTo: view.topAnchor),
            addressWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addressWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            loadIndicator.centerXAnchor.constraint(equalTo: addressWebView.centerXAnchor),
            loadIndicator.centerYAnchor.constraint(equalTo: addressWebView.centerYAnchor)
        ])
    }
    
    func setWebView() {
        guard let url = URL(string: "https://korea-certified-store.github.io/KakaoAddressWeb/") else { return }
        addressWebView.load(URLRequest(url: url))
        loadIndicator.startAnimating()
    }
    
}

extension AddressViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any],
              let address = data["roadAddress"] as? String else { return }
        
        // TODO: address 주소 사용 코드 작성 필요
    }
    
}

extension AddressViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadIndicator.stopAnimating()
    }
    
}
