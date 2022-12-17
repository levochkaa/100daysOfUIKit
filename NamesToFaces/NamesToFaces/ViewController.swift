// ViewController.swift

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let rigthBarBtnItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We want to be sure that your note is available only for you."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self?.addNewPerson))
                        if let savedPeople = UserDefaults.standard.object(forKey: "people") as? Data {
                            do {
                                self?.people = try JSONDecoder().decode([Person].self, from: savedPeople)
                                self?.collectionView.reloadData()
                            } catch {
                                print("Failed to load people")
                            }
                        }
                    } else {
                        let ac = UIAlertController(title: "Sadly :(", message: "Restart the app to try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        NSLayoutConstraint.activate([
            cell.widthAnchor.constraint(equalToConstant: 140),
            cell.heightAnchor.constraint(equalToConstant: 180)
        ])
        let person = people[indexPath.item]
        cell.name.text = person.name

        let path = FileManager.documentsDirectory.appendingPathComponent(person.image).path
        cell.imageView.image = UIImage(contentsOfFile: path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Rename or Delete?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            let acRename = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            acRename.addTextField()
            acRename.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            acRename.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak acRename] _ in
                guard let newName = acRename?.textFields?[0].text else { return }
                person.name = newName
                self?.collectionView.reloadData()
                self?.save()
            })
            self?.present(acRename, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            try! FileManager.default.removeItem(at: FileManager.documentsDirectory.appendingPathComponent(person.image))
            self?.collectionView.reloadData()
            self?.save()
        })
        present(ac, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        let imageName = UUID().uuidString
        let imagePath = FileManager.documentsDirectory.appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()

        dismiss(animated: true)
        save()
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        let ac = UIAlertController(title: "Photo or Camera?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self?.present(picker, animated: true)
            } else {
                let acWarning = UIAlertController(title: "Camera isn't available", message: nil, preferredStyle: .alert)
                acWarning.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(acWarning, animated: true)
            }
        })
        present(ac, animated: true)
    }

    func save() {
        if let savedData = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
}
