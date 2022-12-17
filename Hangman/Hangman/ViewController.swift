// ViewController.swift

import UIKit

class ViewController: UIViewController {

    var hpLabel: UILabel!
    var textLabel: UILabel!
    var textField: UITextField!

    var word = ""
    var answer = ""
    var usedLetters = [String]()
    var words = [String]()
    var hp = 5 {
        didSet {
            hpLabel.text = "HP: \(hp)"
            if hp == 0 {
                errorAlert(title: "You lost!", message: "Maybe next time you will be better")
                newWord()
            }
        }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        DispatchQueue.global(qos: .background).async {
            if let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
                if let wordsContent = try? String(contentsOf: wordsFileURL) {
                    self.words = wordsContent.components(separatedBy: "\n")
                    DispatchQueue.main.async {
                        self.newWord()
                    }
                }
            }
        }

        hpLabel = UILabel()
        hpLabel.translatesAutoresizingMaskIntoConstraints = false
        hpLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        hpLabel.textAlignment = .center
        hpLabel.text = "HP: 5"
        view.addSubview(hpLabel)

        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        textLabel.textAlignment = .center
        textLabel.text = word
        view.addSubview(textLabel)

        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        textField.textAlignment = .center
        textField.placeholder = "Enter a letter"
        view.addSubview(textField)

        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            hpLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            hpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textLabel.topAnchor.constraint(equalTo: hpLabel.bottomAnchor, constant: 200),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 200),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            submitButton.topAnchor.constraint(equalTo: textField.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func newWord() {
        usedLetters = []
        hp = 5
        if let randomWord = words.randomElement() {
            answer = randomWord
            print(randomWord)
            checkWord()
        } else {
            errorAlert(title: "Error 404", message: "Restart the app, please, something wrong happened")
        }
    }

    func errorAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }

    @objc func submitButtonTapped() {
        if let text = textField.text {
            if text.count == 1 {
                if !answer.contains(text) {
                    hp -= 1
                    return
                }
                if usedLetters.contains(text) {
                    return errorAlert(title: "Again?", message: "I've seen this letter before, maybe another one?")
                }
                usedLetters.append(text)
                textField.text = ""
                checkWord()
            } else {
                errorAlert(title: "Wrong!", message: "You can only submit 1 letter at a time")
            }
        }
    }

    func checkWord() {
        word = ""
        for letter in answer {
            let strLetter = String(letter)
            if usedLetters.contains(strLetter) {
                word += strLetter
            } else {
                word += "?"
            }
        }
        DispatchQueue.main.async {
            self.textLabel.text = self.word
        }
        if !word.contains("?") {
            errorAlert(title: "You won!", message: "Great job, now lets repeat it.")
            newWord()
        }
    }
}

