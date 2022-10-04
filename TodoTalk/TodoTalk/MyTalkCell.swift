import UIKit

class MyTalkCell: UITableViewCell {

    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var bgView: UIView! {
        didSet {
            bgView.backgroundColor = .systemYellow
            bgView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var contentTextView: UITextView! {
        didSet {
            contentTextView.isEditable = false  // read only
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
