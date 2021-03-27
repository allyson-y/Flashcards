//
//  ViewController.swift
//  Flashcards
//
//  Created by allyson yao on 2/20/21.
//

import UIKit

struct Flashcard {
    var question: String
    var answer: String
}

class ViewController: UIViewController {

    @IBOutlet weak var backLabel: UILabel!
    
    @IBOutlet weak var frontLabel: UILabel!
    
    @IBOutlet weak var prevButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var card: UIView!
    
    // Array to hold our flashcards
    var flashcards = [Flashcard]()
    
    // Current flashcard index
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // rounded corners
        backLabel.layer.cornerRadius = 20.0
        frontLabel.layer.cornerRadius = 20.0
        card.layer.cornerRadius = 20.0
        card.clipsToBounds = false
        backLabel.clipsToBounds = true
        frontLabel.clipsToBounds = true
        
        // shadow
        card.layer.shadowRadius = 15.0
        card.layer.shadowOpacity = 0.2
        
        // Read saved flashcards
        readSavedFlashcards()
        
        // Adding our initial flashcard if needed
        if flashcards.count == 0 {
            updateFlashcard(question: "What's the capitol of France?", answer: "Paris", isExisting: false)
        } else {
            updateLabels()
            updateNextPrevButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // First start with the flashcard invisible and slightly smaller in size
        card.alpha = 0.0
        card.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75)
        
        // Animation
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
            self.card.alpha = 1.0
            self.card.transform = CGAffineTransform.identity
        }

    }

    @IBAction func didTapOnFlashcard(_ sender: Any) {
        flipFlashcard()
    }
    
    func flipFlashcard() {
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight) {
            if (self.frontLabel.isHidden) {
                self.frontLabel.isHidden = false
            } else {
                self.frontLabel.isHidden = true
            }
        }
    }
    
    func animateCardOutNext() {
        
        // Animate card going left
        UIView.animate(withDuration: 0.2) {
            self.card.transform = CGAffineTransform.identity.translatedBy(x: -300.0, y: 0.0)
        } completion: { finished in
            
            // Update labels
            self.updateLabels()
            
            // Run other animation
            self.animateCardInNext()
        }
    }
    
    func animateCardInNext() {
        
        // Start on the right side (don't animate this)
        card.transform = CGAffineTransform.identity.translatedBy(x: 300.0, y: 0.0)
        
        // Animate card going back to its original position
        UIView.animate(withDuration: 0.2) {
            self.card.transform = CGAffineTransform.identity
        }
    }
    
    func animateCardOutPrev() {
        
        // Animate card going right
        UIView.animate(withDuration: 0.2) {
            self.card.transform = CGAffineTransform.identity.translatedBy(x: 300.0, y: 0.0)
        } completion: { finished in
            
            // Update labels
            self.updateLabels()
            
            // Run other animation
            self.animateCardInPrev()
        }
    }
    
    func animateCardInPrev() {
        // Start on the left side (don't animate this)
        card.transform = CGAffineTransform.identity.translatedBy(x: -300.0, y: 0.0)
        
        // Animate card going back to its original position
        UIView.animate(withDuration: 0.2) {
            self.card.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func didTapOnPrev(_ sender: Any) {
        
        // Decrease current index
        currentIndex = currentIndex - 1
        
        // Update buttons
        updateNextPrevButton()
        
        animateCardOutPrev()
    }
    
    @IBAction func didTapOnNext(_ sender: Any) {
        
        //Increase current index
        currentIndex = currentIndex + 1
        
        // Update buttons
        updateNextPrevButton()
        
        animateCardOutNext()
    }
    
    @IBAction func didTapOnDelete(_ sender: Any) {
        
        // Show confirmation
        let alert = UIAlertController(title: "Delete flashcard", message: "Are you sure you want to delete it?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteCurrentFlashcard()
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func deleteCurrentFlashcard() {
        
        // Delete current
        flashcards.remove(at: currentIndex)
        
        // Special case: Check if last card was deleted
        if currentIndex > flashcards.count - 1 {
            currentIndex = flashcards.count - 1
        }
        
        // Speical case: One flashcard left
        if flashcards.count == 1 {
            // Show error
            let alert = UIAlertController(title: "One flashcard left", message: "You can edit the final flashcard or add flashcards!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
        
        updateNextPrevButton()
        updateLabels()
        saveAllFlashcardsToDisk()
    }
    
    func updateLabels() {
        
        // Get current flashcard
        let currentFlashcard = flashcards[currentIndex]
        
        // Update labels
        frontLabel.text = currentFlashcard.question
        backLabel.text = currentFlashcard.answer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // We know the destinatin of the segue is the Navigation Controller
        let navigationController = segue.destination as! UINavigationController
        
        // We know the Navigation Controller only contains a Creation View Controller
        let creationController = navigationController.topViewController as! CreationViewController
        
        // We set the flashcardsController property to self
        if segue.identifier != "EditSegue" {
            creationController.initialQuestion = frontLabel.text
            creationController.initialAnswer = backLabel.text
        }
        creationController.flashcardsController = self
    }
    
    func updateNextPrevButton() {
        
        // Disable next button if at the end
        if currentIndex == flashcards.count - 1 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        
        // Disable prev button if at the beginning
        if currentIndex == 0 {
            prevButton.isEnabled = false
        } else {
            prevButton.isEnabled = true
        }
    }
    
    func updateFlashcard(question: String, answer: String, isExisting: Bool) {
        let flashcard = Flashcard(question: question, answer: answer)
        
        if isExisting {
            // Replace existing flashcard
            flashcards[currentIndex] = flashcard
        } else {
            
            // Adding flashcard in the flashcards array
            flashcards.append(flashcard)
            
            // Logging to the console
            print("Added new flashcard")
            print("We now have \(flashcards.count) flashcards")
            
            // Update current index
            currentIndex = flashcards.count - 1
            print("Our current index is \(currentIndex)")
            
        }
        
        // Update buttons
        updateNextPrevButton()
        
        // Update labels
        updateLabels()
        
        // Save flashcards to disk
        saveAllFlashcardsToDisk()
    }
    
    func saveAllFlashcardsToDisk() {
        
        // From flashcard array to dictionary array
        let dictionaryArray = flashcards.map { (card) -> [String: String] in
            return ["question": card.question, "answer": card.answer]
        }
        
        // Save array on disk using UserDefaults
        UserDefaults.standard.set(dictionaryArray, forKey: "flashcards")
        
        // Log it
        print("Flashcards saved to UserDefaults")
    }
    
    func readSavedFlashcards() {
        
        // Read dictionary array from disk (if any)
        if let dictionaryArray = UserDefaults.standard.array(forKey: "flashcards") as? [[String: String]] {
            
            // In here we know for sure we have a dictionary array
            let savedCards = dictionaryArray.map { dictionary -> Flashcard in
                return Flashcard(question: dictionary["question"]!, answer: dictionary["answer"]!)
            }
            
            // Put all these cards in our flashcards array
            flashcards.append(contentsOf: savedCards)
        }
    }
    
}

