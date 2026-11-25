import UIKit
import WebKit

/// 怀旧游戏厅 WebView 壳
/// - 加载 Bundle 内的 index.html（本地 file:// 页面，离线可用）
/// - 游戏页依赖 history 返回，iOS 没有系统返回键，这里注入一个悬浮「返回大厅」按钮
/// - 屏蔽长按弹窗/文字选择，避免误操作
class RootViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private var webView: WKWebView!
    private let homeName = "index.html"

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // JS -> Swift 桥：悬浮返回按钮点击后调用 goBack
        let cc = WKUserContentController()
        cc.add(self, name: "arcadeBack")
        config.userContentController = cc

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.backgroundColor = UIColor(red: 0.055, green: 0.067, blue: 0.09, alpha: 1)
        wv.scrollView.bounces = false
        wv.scrollView.isScrollEnabled = false
        if #available(iOS 11.0, *) {
            wv.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView = wv
        view = wv
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHome()
    }

    private func loadHome() {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Games") else {
            let lbl = UILabel(frame: view.bounds)
            lbl.text = "游戏资源未找到"
            lbl.textColor = .white
            lbl.textAlignment = .center
            view.addSubview(lbl)
            return
        }
        // 允许访问 Bundle 目录，游戏页间跳转用相对路径
        webView.loadFileURL(url, allowingReadAccessTo: Bundle.main.bundleURL)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成后注入悬浮返回键（首页不注入）
        let isHome = webView.url?.lastPathComponent == homeName
        let js = isHome ? removeBackButtonJS() : injectBackButtonJS()
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 只允许加载 App Bundle 内的本地文件，拦截一切外链（无广告、无联网）
        if let url = navigationAction.request.url, url.isFileURL {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "arcadeBack" {
            backToHome()
        }
    }

    private func backToHome() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            loadHome()
        }
    }

    // MARK: - 注入脚本

    /// 游戏页：右上角悬浮「返回大厅」按钮
    private func injectBackButtonJS() -> String {
        return """
        (function(){
          var id='__arcade_back_btn__';
          if(document.getElementById(id)) return;
          var b=document.createElement('div');
          b.id=id;
          b.textContent='‹ 大厅';
          b.setAttribute('style',
            'position:fixed;right:12px;top:12px;z-index:99999;'+
            'padding:9px 14px;border-radius:12px;'+
            'background:rgba(24,29,39,.92);color:#5ad6c8;'+
            'border:1px solid #2b3444;font-size:14px;font-weight:700;'+
            'box-shadow:0 4px 16px rgba(0,0,0,.4);-webkit-tap-highlight-color:transparent;');
          b.addEventListener('click',function(e){
            e.preventDefault();
            try{window.webkit.messageHandlers.arcadeBack.postMessage('back');}catch(err){history.back();}
          });
          (document.body||document.documentElement).appendChild(b);
        })();
        """
    }

    private func removeBackButtonJS() -> String {
        return "var b=document.getElementById('__arcade_back_btn__');if(b)b.remove();"
    }

    // MARK: - 状态栏 / 方向

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
    override var shouldAutorotate: Bool { return true }
}
