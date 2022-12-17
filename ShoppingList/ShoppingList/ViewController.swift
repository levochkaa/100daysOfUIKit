// ViewController.swift

import UIKit

class ViewController: UITableViewController {
    var items = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForItem))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearList))
        title = "Shopping List"

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareSheet))
        toolbarItems = [spacer, share, spacer]
        navigationController?.isToolbarHidden = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func submitItem(_ item: String) {
        items.insert(item, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    @objc func shareSheet() {
        let list = items.joined(separator: "\n")
        let ac = UIActivityViewController(activityItems: [list], applicationActivities: [])
        present(ac, animated: true)
    }

    @objc func promptForItem() {
        let ac = UIAlertController(title: "Enter name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] _ in
            guard let item = ac?.textFields?[0].text else { return }
            self?.submitItem(item)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    @objc func clearList() {
        items.removeAll()
        tableView.reloadData()
    }
}

