// ViewController.swift

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!

    var countries = [String]()
    var score = 0
    var highestScore = UserDefaults.standard.integer(forKey: "highestScore")
    var correctAnswer = 0
    var questionsAsked = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Score", style: .plain, target: self, action: #selector(showScoreTapped))

        button1.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor

        button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.lightGray.cgColor

        button3.layer.borderWidth = 1
        button3.layer.borderColor = UIColor.lightGray.cgColor

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        askQuestion()

        registerNotifications()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("here")
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    print("Default identifier")
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    registerNotifications()
                default:
                    print("break")
                    break
            }
        }
        completionHandler()
    }

    func registerNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yeah")
                center.delegate = self
                let content = UNMutableNotificationContent()
                content.title = "Come back to the game!"
                content.body = "Flags are waiting for you, come and play more, please :)"
                content.categoryIdentifier = "alarm"
                content.userInfo = ["customData": "fizzbuzz"]
                content.sound = UNNotificationSound.default
                #if DEBUG
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
                #else
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
                #endif
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            } else {
                print("D'oh")
            }
        }
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()

        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            self.button1.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.button2.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.button3.transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        correctAnswer = Int.random(in: 0...2)

        title = "\(countries[correctAnswer].uppercased())"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var ac: UIAlertController

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }

        if sender.tag == correctAnswer {
            title = "Correct!"
            score += 1
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            score -= 1
        }
        questionsAsked += 1

        if questionsAsked == 10 {
            ac = UIAlertController(title: "Game Finished", message: "Your score is \(score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: askQuestion))
            questionsAsked = 0
            if score > highestScore {
                UserDefaults.standard.set(score, forKey: "highestScore")
                highestScore = score
                ac = UIAlertController(title: "Great job!", message: "You beat your previous record", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            }
        } else {
            ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        }
        present(ac, animated: true)
    }

    @objc func showScoreTapped() {
        let ac = UIAlertController(title: "Showing score", message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default))
        present(ac, animated: true)
    }
}

