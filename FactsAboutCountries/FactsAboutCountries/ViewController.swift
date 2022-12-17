// ViewController.swift

import UIKit

class ViewController: UITableViewController {

    let cellId = "cellId"
    let cellFont = UIFont.systemFont(ofSize: 18)

    var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true

        if let data = getData(),
           let decodedData = try? JSONDecoder().decode([Country].self, from: data) {
            countries = decodedData
        } else {
            fatalError("Error on decoding countries.json")
        }
    }

    func getData() -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "countries", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.country = countries[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.font = cellFont
        cell.textLabel?.text = countries[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
}

