// ViewController.swift

import UIKit

class ViewController: UIViewController,
                        UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!

    func addTextToImage(text: String, ofSize imageSize: CGSize, isTop: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: imageSize.height / 10, weight: .black),
            .paragraphStyle: paragraphStyle,
            .backgroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)

        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        let img = renderer.image { ctx in
            imageView.image?.draw(at: CGPoint(x: 0, y: 0))
            attributedString.draw(with: CGRect(
                x: 0,
                y: isTop ? 0 : imageSize.height - textSize.height,
                width: imageSize.width,
                height: imageSize.height),
                                  options: .usesLineFragmentOrigin, context: nil)
        }

        imageView.image = img
    }

    func showAlert(title: String?) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    @IBAction func setText(_ sender: UIButton) {
        guard let imageSize = imageView.image?.size else { return showAlert(title: "Set an image firstly") }
        let isTop = sender.restorationIdentifier == "top"

        let ac = UIAlertController(title: "Enter text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            if let text = ac.textFields?.first?.text {
                self?.addTextToImage(text: text, ofSize: imageSize, isTop: isTop)
            }
        })

        present(ac, animated: true)
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        guard let image = imageView.image else { return showAlert(title: "Set an image firstly") }
        let avc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(avc, animated: true)
    }

    @IBAction func importPicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        dismiss(animated: true)
    }
}

