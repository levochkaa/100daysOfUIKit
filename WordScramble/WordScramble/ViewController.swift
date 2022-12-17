// ViewController.swift

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    let LEFT_BAR_BUTTON_ITEM_TAG = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarBtnItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        leftBarBtnItem.tag = LEFT_BAR_BUTTON_ITEM_TAG
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = leftBarBtnItem

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }

        if let savedUsedWords = UserDefaults.standard.object(forKey: "usedWords") as? Data {
            do {
                usedWords = try JSONDecoder().decode([String].self, from: savedUsedWords)
                tableView.reloadData()
            } catch {
                print("Couldn't load used words")
            }
        }

        startGame(UIBarButtonItem())
    }

    @objc func startGame(_ sender: UIBarButtonItem) {
        title = sender.tag == LEFT_BAR_BUTTON_ITEM_TAG ? allWords.randomElement() : UserDefaults.standard.string(forKey: "lastWord") ?? allWords.randomElement()
        UserDefaults.standard.set(title, forKey: "lastWord")
        if sender.tag == LEFT_BAR_BUTTON_ITEM_TAG {
            usedWords.removeAll(keepingCapacity: true)
            if let savedData = try? JSONEncoder().encode([String]()) {
                UserDefaults.standard.set(savedData, forKey: "usedWords")
            } else {
                print("Failed to save used words")
            }
        }
        tableView.reloadData()
    }

    func submit(_ answer: String) {
        let trimmedAnswer = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let title = title?.lowercased() else { return }

        guard trimmedAnswer != title else {
            return showErrorMessage(title: "Word is the root word", message: "Be more original!")
        }
        guard trimmedAnswer.count > 2 else {
            return showErrorMessage(title: "Word is too short", message: "Length matters, bro")
        }
        guard !usedWords.contains(trimmedAnswer) else {
            return showErrorMessage(title: "Word used already", message: "Be more original!")
        }
        guard isPossible(word: trimmedAnswer) else {
            return showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
        }
        guard isReal(word: trimmedAnswer) else {
            return showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
        }

        usedWords.insert(trimmedAnswer, at: 0)
        if let savedData = try? JSONEncoder().encode(usedWords) {
            UserDefaults.standard.set(savedData, forKey: "usedWords")
        } else {
            print("Failed to save used words")
        }

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }

    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }

        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let sumbitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }

        ac.addAction(sumbitAction)
        present(ac, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}

