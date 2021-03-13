//
//  CreationViewController.swift
//  Flashcards
//
//  Created by allyson yao on 3/6/21.
//

import UIKit

class CreationViewController: UIViewController {
    
    var flashcardsController: ViewController!
    
    // Get the text in the question text field
    @IBOutlet weak var questionTextField: UITextField!
    
    // Get the text in the answer text field
    @IBOutlet weak var answerTextField: UITextField!
    
    var initialQuestion: String?
    
    var initialAnswer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Do any additional setup after loading the view.
        questionTextField.text = initialQuestion
        answerTextField.text = initialAnswer

    }
    
    @IBAction func didTapOnCancel(_ sender: Any) {
        dismiss(animated: true)
        
    }
    
    @IBAction func didTapOnDone(_ sender: Any) {
        
        // Get the text in the question text field
        let questionText:String! = questionTextField.text
        
        // Get the text in the answer text field
        let answerText:String! = answerTextField.text
        
        // Check if empty
        if questionText == nil || answerText == nil || questionText!.isEmpty || answerText!.isEmpty {
            // Show error
            let alert = UIAlertController(title: "Missing text", message: "You need to enter both a question and an answer", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            // See if it's existing
            var isExisting = false
            if initialQuestion != nil {
                isExisting = true
            }
            
            // Call the function to update the flashcard
            flashcardsController.updateFlashcard(question: questionText!, answer: answerText!, isExisting: isExisting)
            
            //Dismiss
            dismiss(animated: true)
        }
    }
}
