//
//  ToDoCell.swift
//  ToDoList
//
//  Created by Sebastian Stark on 07.03.26.
//

import UIKit


// MARK: - Protokoll ToDoCellDelegate

// Ein Protokoll, das die Zelle verwendet, um Ereignisse (z. B. Button-Taps)
// an den übergeordneten ViewController weiterzugeben.
// Dadurch bleibt die Zelle dumm und wiederverwendbar.
protocol ToDoCellDelegate: AnyObject {
    // Wird aufgerufen, wenn der Checkmark-Button in der Zelle getippt wurde.
    func checkMarkTapped(sender: ToDoCell)
}


// MARK: - Klasse ToDoCell

class ToDoCell: UITableViewCell {
    
    // Button, der anzeigt, ob ein ToDo erledigt ist.
    // Wird im Storyboard mit einem Häkchen-Icon konfiguriert.
    @IBOutlet var isCompleteButton: UIButton!
    
    // Label, das den Titel des ToDos anzeigt.
    @IBOutlet var titleLabel: UILabel!
    
    // Delegate, das über Interaktionen in der Zelle informiert wird.
    // weak verhindert Retain Cycles zwischen Zelle und ViewController.
    weak var delegate: ToDoCellDelegate?
    
    // Wird aufgerufen, wenn der Nutzer auf den Checkmark-Button tippt.
    // Die Zelle selbst ändert NICHT den Zustand — sie meldet nur das Ereignis.
    // Der ViewController entscheidet dann, was passieren soll.
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        delegate?.checkMarkTapped(sender: self)
    }
    
    // Wird aufgerufen, nachdem die Zelle aus dem Storyboard geladen wurde.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // Wird aufgerufen, wenn die Zelle ausgewählt oder abgewählt wird.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
