// ViewController.swift

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var picturesOpenedFor = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Storm Viewer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!

        DispatchQueue.global(qos: .background).async {
            let items = try! fm.contentsOfDirectory(atPath: path)
            for item in items.sorted() {
                if item.hasPrefix("nssl") {
                    self.pictures.append(item)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        if let savedPicturesOpenedFor = UserDefaults.standard.object(forKey: "picturesOpenedFor") as? Data {
            do {
                picturesOpenedFor = try JSONDecoder().decode([String: Int].self, from: savedPicturesOpenedFor)
            } catch {
                print("Couldn't load how many every picture was opened for")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture
        cell.detailTextLabel?.text = String(picturesOpenedFor[picture] ?? 0)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let picture = pictures[indexPath.row]
            picturesOpenedFor[picture] = (picturesOpenedFor[picture] ?? 0) + 1
            save()
            tableView.reloadData()
            vc.selectedImage = picture
            vc.totalPictures = pictures.count
            vc.selectedPictureNumber = indexPath.row + 1
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["StormViewer is the best app in the world! Download it at fuckyou.com"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    func save() {
        if let savedData = try? JSONEncoder().encode(picturesOpenedFor) {
            UserDefaults.standard.set(savedData, forKey: "picturesOpenedFor")
        } else {
            print("Failed to save how many times each picture was opened")
        }
    }
}

