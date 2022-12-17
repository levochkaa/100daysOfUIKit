// ViewController.swift

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions: [Petition] {
        if query.isEmpty {
            return petitions
        } else {
            return petitions.filter {
                $0.title.localizedCaseInsensitiveContains(query)
            }
        }
    }
    var query = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Whitehouse Petitions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc"), style: .plain, target: self, action: #selector(showCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearch))
        
        let urlString: String
        switch navigationController?.tabBarItem.tag {
            case 0:
                urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
            case 1:
                urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
            default:
                return showError()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    return self.parse(json: data)
                }
            }
            self.showError()
        }
    }

    @objc func showSearch() {
        let ac = UIAlertController(title: "Search in petitions", message: "Enter text, that must be in the title of a petition", preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Proceed", style: .cancel) { [weak self, weak ac] _ in
            guard let search = ac?.textFields?[0].text else { return }
            self?.query = search
            self?.tableView.reloadData()
        }
        ac.addAction(action)
        present(ac, animated: true)
    }

    @objc func showCredits() {
        let ac = UIAlertController(title: "That's not mine!!", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        ac.addAction(action)
        present(ac, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

