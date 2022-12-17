// ViewController.swift

import UIKit

extension Int {
    func times(_ closure: () -> Void) {
        for _ in 0..<self { closure() }
    }
}

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let location = self.firstIndex(of: item) {
            self.remove(at: location)
        }
    }
}

extension UIView {
    func bounceOut(duaration: TimeInterval) {
        UIView.animate(withDuration: duaration) {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}



class ViewController: UIViewController {

    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        5.times {
            print("hello world")
        }

        var array = ["a", "b", "c"]
        array.remove(item: "b")
        print(array)

        label.text = "text"
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.label.bounceOut(duaration: 5)
        }
    }


}

