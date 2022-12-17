// ViewController.swift

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Photos"

        if let savedData = UserDefaults.standard.object(forKey: "photos") as? Data {
            do {
                photos = try JSONDecoder().decode([Photo].self, from: savedData)
            } catch {
                print("Failed to load photos data")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = photos[indexPath.row].caption
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.photo = photos[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let ac = UIAlertController(title: "Caption", message: "Enter the caption of this photo", preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let caption = ac?.textFields?[0].text else { return }
            let photoName = UUID().uuidString
            let photoDirectory = FileManager.documentsDirectory.appendingPathComponent(photoName)
            if let jpegData = image.jpegData(compressionQuality: 1) {
                do {
                    try jpegData.write(to: photoDirectory)
                } catch {
                    print("Failed to save image")
                }
            } else {
                print("Failed to save .jpeg data of an image")
            }
            let photo = Photo(caption: caption, photoName: photoName)
            self?.photos.append(photo)
            self?.tableView.reloadData()
            self?.save()
        }
        ac.addAction(action)
        dismiss(animated: true)
        present(ac, animated: true)
    }

    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    func save() {
        if let data = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(data, forKey: "photos")
        } else {
            print("Failed to save photos")
        }
    }
}

