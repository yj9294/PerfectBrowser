//
//  HomeVC.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/10.
//

import UIKit
import WebKit
import AppTrackingTransparency
import MobileCoreServices

class HomeVC: UIViewController {
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tabButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var settingView: UIView!
    
    @IBOutlet weak var cleanView: UIView!
    
    var date: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        collection.register(UINib(nibName: "HomeItemCell", bundle: .main), forCellWithReuseIdentifier: "HomeItemCell")
        Task{
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                ATTrackingManager.requestTrackingAuthorization(){ _ in }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BrowserUtil.shared.addedWebView(from: self)
        refreshStatus()
        FirebaseUtil.log(event: .homeShow)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BrowserUtil.shared.removeWebView()
    }
    
    override func viewDidLayoutSubviews() {
        BrowserUtil.shared.frame = contentView.frame
    }
    
}

extension HomeVC {
    
    @IBAction func searchAction() {
        view.endEditing(true)
        if let text = textField.text, text.count > 0 {
            FirebaseUtil.log(event: .webStart)
            BrowserUtil.shared.loadUrl(text, from: self)
            FirebaseUtil.log(event: .navigaSearch, params: ["lig": text])
        } else {
            alert("Please enter your search content.")
        }
    }
    
    @IBAction func stopSearchAction() {
        view.endEditing(true)
        textField.text = ""
        BrowserUtil.shared.stopLoad()
    }
    
    @IBAction func lastActionAction() {
        BrowserUtil.shared.goBack()
    }
    
    @IBAction func nextAction() {
        BrowserUtil.shared.goForword()
    }
    
    @IBAction func cleanAction() {
        hiddenCleanView()
        let vc = CleanVC()
        vc.modalPresentationStyle = .fullScreen
        vc.completionHandle = { [weak self] in
            self?.alert("Cleaned")
            FirebaseUtil.log(event: .cleanSuccess)
            FirebaseUtil.log(event: .cleanAlert)
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func tabAction() {
        let vc = ListVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func settingAction() {
        showSettingView()
    }
    
    @IBAction func shareAction() {
        hiddenSettingView()
        var url = "https://itunes.apple.com/cn/app/id6446871195"
        if !BrowserUtil.shared.item.isNavigation, let text = BrowserUtil.shared.item.webView.url?.absoluteString {
            url = text
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(vc, animated: true)
        FirebaseUtil.log(event: .shareClick)
    }
    
    @IBAction func copyAction() {
        hiddenSettingView()
        if !BrowserUtil.shared.item.isNavigation, let text = BrowserUtil.shared.item.webView.url?.absoluteString {
            UIPasteboard.general.setValue(text, forPasteboardType: kUTTypePlainText as String)
            self.alert("Copy successed.")
        } else {
            UIPasteboard.general.setValue("", forPasteboardType: kUTTypePlainText as String)
            self.alert("Copy successed.")
        }
        FirebaseUtil.log(event: .copyClick)
    }
    
    @IBAction func newAction() {
        hiddenSettingView()
        BrowserUtil.shared.add()
        refreshStatus()
        FirebaseUtil.log(event: .tabNew, params: ["lig": "setting"])
    }
    
    @IBAction func termsAction() {
        hiddenSettingView()
        let vc = TermsVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func privacyAction() {
        hiddenSettingView()
        let vc = PrivacyVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func rateAction() {
        hiddenSettingView()
        if let url = URL(string: "https://itunes.apple.com/cn/app/id6446871195") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func showCleanViewAction() {
        FirebaseUtil.log(event: .cleanClick)
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanView.alpha = 1
        }
    }
    
    @IBAction func hiddenCleanView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanView.alpha = 0
        }
    }
    
}

extension HomeVC {
    
    func showSettingView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.settingView.alpha = 1
        }
    }
    
    @IBAction func hiddenSettingView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.settingView.alpha = 0
        }
    }
}

extension HomeVC {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            self.refreshStatus()
        }
    }
    
    func refreshStatus() {
        stopButton.isHidden = !BrowserUtil.shared.isLoading
        searchButton.isHidden = BrowserUtil.shared.isLoading
        tabButton.setTitle("\(BrowserUtil.shared.count)", for: .normal)
        tabButton.setTitleColor(.black, for: .normal)
        tabButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -17, bottom: 0, right: 0)
        tabButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        textField.text = BrowserUtil.shared.url
        progressView.progress = Float(BrowserUtil.shared.progrss)
        nextButton.isEnabled = BrowserUtil.shared.canGoForword
        lastButton.isEnabled = BrowserUtil.shared.canGoBack
        BrowserUtil.shared.delegate = self
        BrowserUtil.shared.uiDelegate = self
        if BrowserUtil.shared.progrss > 0, BrowserUtil.shared.progrss < 1.0 {
            progressView.isHidden = false
        } else {
            progressView.isHidden = true
        }
        if BrowserUtil.shared.url == nil  {
            BrowserUtil.shared.removeWebView()
        }
        if BrowserUtil.shared.progrss == 0.1 {
            date = Date()
        }
        
        if BrowserUtil.shared.progrss == 1.0 {
            let time = Date().timeIntervalSince1970 - date.timeIntervalSince1970
            FirebaseUtil.log(event: .webSuccess, params: ["lig": "\(ceil(time))"])
            stopButton.isHidden = true
            searchButton.isHidden = false
        }
    }
    
}

extension HomeVC: UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction()
        return true
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /// 打开新的窗口
        lastButton.isEnabled = webView.canGoBack
        nextButton.isEnabled = webView.canGoForward

        webView.load(navigationAction.request)
        
        lastButton.isEnabled = webView.canGoBack
        nextButton.isEnabled = webView.canGoForward
        FirebaseUtil.log(event: .webStart)
        return nil
    }
    
}


extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        HomeItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemCell", for: indexPath)
        if let cell = cell as? HomeItemCell {
            cell.item = HomeItem.allCases[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (width ?? 375.0 - 40) / 4
        return CGSize(width: w, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = HomeItem.allCases[indexPath.row]
        let url = item.url
        textField.text = url
        FirebaseUtil.log(event: .navigaClick, params: ["lig": item.title])
        if let text = textField.text, text.count > 0 {
            FirebaseUtil.log(event: .webStart)
            BrowserUtil.shared.loadUrl(text, from: self)
        } else {
            alert("Please enter your search content.")
        }
    }
    
}


enum HomeItem: String, CaseIterable {
    case facebook, google, youtube, twitter, instagram, amazon, gmail, yahoo
    var title: String {
        return self.rawValue.capitalized
    }
    var icon: UIImage {
        return UIImage(named: "home_\(self.rawValue)") ?? UIImage()
    }
    var url: String {
        return "https://www.\(self.rawValue).com"
    }
}
