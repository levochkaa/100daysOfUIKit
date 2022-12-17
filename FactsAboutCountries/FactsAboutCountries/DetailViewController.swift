// DetailViewController.swift

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var country: Country?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let country = country else { return }

        let html = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        body {
            font-size: 150%;
        }
        </style>
        </head>
        <body>
            <h3><b>\(country.name)</b></h1>
            <p>\(country.shortDescription)</p>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}
