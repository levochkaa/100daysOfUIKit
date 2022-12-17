// DetailViewController.swift

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var city: String!

    let wikiUrl = "https://en.wikipedia.org/wiki/"

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        city = city.replacingOccurrences(of: " ", with: "_")
        let url = URL(string: wikiUrl + city)
        webView.load(URLRequest(url: url!))
        title = city
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
