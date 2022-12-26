//
//  ViewController.swift
//  MyWKWebView
//
//  Created by Juan Pablo Ariza on 12/22
//

import UIKit
import WebKit

final class ViewController: UIViewController, UINavigationBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    // MARK: - Private
    private let searchBar = UISearchBar()
    private var webView: WKWebView!
    private let refreshControl = UIRefreshControl()
    private let baseUrl = "http://www.google.com"
    private let searchPath = "/search?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.delegate = self
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = UIColor.red
            navigationController?.navigationBar.standardAppearance = barAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        }
        
        // Navigation buttons
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        // Search bar
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        // Web view
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        
        // 3: Create your local storage data
        let localStorageData: [String: Any] = [
            "key1": "holi",
            "key2": "name USer"
        ]
        
        if JSONSerialization.isValidJSONObject(localStorageData),
            let data = try? JSONSerialization.data(withJSONObject: localStorageData, options: []),
            let value = String(data: data, encoding: .utf8) {
            let script = WKUserScript(
                source: "Object.assign(window.localStorage, \(value));",
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
            // 5: Add created WKUserScript variable into the configuration
            webViewConf.userContentController.addUserScript(script)
        }
        
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.keyboardDismissMode = .onDrag
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        view.bringSubview(toFront: refreshControl)
        
        // Load url
        load(url: baseUrl)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    
    // MARK: - Private methods
    
    private func load(url: String) {
        
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")!
        }
        webView.load(URLRequest(url: urlToLoad))
    }
    
    @objc private func reload() {
        webView.reload()
    }
    
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        load(url: searchBar.text ?? "")
    }
    
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    
    // Finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        refreshControl.endRefreshing()
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        view.bringSubview(toFront: refreshControl)
        
        
    // Change "key" to your local storage's key that you want to check its value
      webView.evaluateJavaScript("localStorage.getItem(\"key1\")") { (value, error) in
          print(value)
      }

    }
    
    // Start
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString
    }
    
    // Error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        refreshControl.beginRefreshing()
        view.bringSubview(toFront: refreshControl)
    }
    
}

