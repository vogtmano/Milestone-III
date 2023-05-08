//
//  ViewController.swift
//  Milestone III.1
//
//  Created by Maks Vogtman on 19/09/2022.
//

import UIKit

class ViewController: UITableViewController {
    var wrongAnswers = 0
    var allWords = [String]()
    var usedLetters = [String]()
    var passwordToGuess = ""
    
    var displayedPassword = String() {
        didSet {
            title = displayedPassword.uppercased()
            
            if displayedPassword.uppercased() == passwordToGuess {
                resultWin()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "level1", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        startGame()
    }
    
    
    @objc func startGame(_ action: UIAlertAction! = nil) {
        passwordToGuess = allWords.randomElement()!
        displayedPassword = String(repeating: "?", count: passwordToGuess.count)
        usedLetters.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter the letter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let letter = ac?.textFields?[0].text else { return }
            if letter.count < 2 && letter.count > 0 {
                self?.submit(letter)
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    func submit(_ letterToCheck: String) {
        let capitalLetter = letterToCheck.uppercased()
        usedLetters.insert(capitalLetter, at: 0)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard passwordToGuess.contains(capitalLetter) else {
            wrongAnswers += 1
            
            if wrongAnswers == 6 {
                almostDead()
            }
            
            if wrongAnswers == 7 {
                resultLose()
            }
            
            return
        }
        
        var displayedPasswordAsArray = Array<Character>.init(displayedPassword)
        
        for (index, letter) in passwordToGuess.enumerated() {
            let strLetter = String(letter)
            
            if capitalLetter == strLetter {
                displayedPasswordAsArray.remove(at: index)
                displayedPasswordAsArray.insert(contentsOf: letterToCheck, at: index)
            }
        }
        
        displayedPassword = String(displayedPasswordAsArray)
    }
    
    
    func resultWin() {
        let ac = UIAlertController(title: "Congratulations", message: "You've guessed the word!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try another one", style: .default, handler: startGame(_:)))
        present(ac, animated: true)
    }
    
    
    func almostDead() {
        let ac = UIAlertController(title: "Be careful", message: "You're one inch from death!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Got it", style: .default))
        present(ac, animated: true)
    }
    
    
    func resultLose() {
        let ac = UIAlertController(title: "You've used all of your chances...", message: "Don't give up!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Let's try again", style: .default, handler: startGame(_:)))
        present(ac, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedLetters.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = usedLetters[indexPath.row]
        return cell
    }
}

