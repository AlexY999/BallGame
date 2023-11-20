import UIKit
import WebKit

class ResultViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    
    private var webView: WKWebView!
    
    var isWinner: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWebView()
        loadWebViewContent()
    }

    private func configureWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }

    private func loadWebViewContent() {
        if isWinner, let winnerURL = UserDefaultsManager.getWinnerURL() {
            self.loadURLInWebView(winnerURL)
        } else if !isWinner, let loserURL = UserDefaultsManager.getLoserURL() {
            self.loadURLInWebView(loserURL)
        } else {
            print("Invalid JSON format")
            setDefaultResult()
        }
    }

    private func loadURLInWebView(_ url: URL) {
        let request = URLRequest(url: url)
        DispatchQueue.main.async { [weak self] in
            self?.webView.load(request)
            self?.setupExitButton()
        }
    }
    
    private func setupExitButton() {
        let exitButton = UIButton(type: .custom)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.backgroundColor = .cyan
        exitButton.layer.cornerRadius = 6
        exitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        exitButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Adjust the values as needed
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)

        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func setDefaultResult() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let resultText = isWinner ? "You won!" : "You lost!"
            resultLabel.text = resultText
            webView.isHidden = true
        }
    }

    @objc private func exitButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Web view failed to load: \(error.localizedDescription)")
        // Handle error as needed
    }
    
    @IBAction func onExitButtonClick(_ sender: Any) {
        exitButtonTapped()
    }
}
