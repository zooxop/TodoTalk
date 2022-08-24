import UIKit

class AddTalkVC: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.titleTextField.setBottomBorder()
        self.saveButton.setBorderRoundly(color: UIColor.green)
    }

    @IBAction func saveButtonTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UITextField {
    
    func setBottomBorder() {
        // viewDidLayoutSubViews()가 여러번 실행되므로, 제약조건 걸어놓음.
        if self.borderStyle != .none {
            self.borderStyle = .none
            let border = CALayer()
            border.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 1)
            border.backgroundColor = UIColor.darkGray.cgColor
            self.layer.addSublayer(border)
        }
    }
}

extension UIButton {
    
    func setBorderRoundly(color: UIColor) {
        self.backgroundColor = color.withAlphaComponent(0.3)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0
        self.layer.borderColor = .none
    }
}
