//
//  ToDoCell.swift
//  ToDoList
//
//  Created by Sebastian Stark on 07.03.26.
//

import UIKit

protocol ToDoCellDelegate: AnyObject {
    func checkMarkTapped(sender: ToDoCell)
}

class ToDoCell: UITableViewCell {
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    weak var delegate: ToDoCellDelegate?
    
    // Funktion wird aufgerufen, wenn der CheckMarkButton betätigt wird.
    // Daduch wird das Delegate-Protokoll informiert, dass der Button betätigt wurde.
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        delegate?.checkMarkTapped(sender: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
