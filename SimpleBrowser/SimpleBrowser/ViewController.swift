// ViewController.swift

import UIKit

class ViewController: UITableViewController {
    var websites = ["hackingwithswift.com", "apple.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Simple Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
        // TODO: load websites.txt
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fm.contentsOfDirectory(atPath: path)
//        for item in items {
//            if item == "websites.txt" {
//                //
//            }
//        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WebBrowser") as? WebBrowserViewController {
            vc.site = websites[indexPath.row]
            vc.websites = websites
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

