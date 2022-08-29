import UIKit
import CoreData

protocol AddTalkVCDelegate: AnyObject {
    func didFinishSaveData()
}

class AddTalkVC: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var todoDatePicker: UIDatePicker!
    @IBOutlet weak var isTodoDateSwitch: UISwitch!
    
    weak var delegate: AddTalkVCDelegate?
    var dateFormatter = DateFormatter()
    
    var selectedDate = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.delegate = self
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.todoDatePicker.locale = Locale(identifier: "ko")
        self.isTodoDateSwitch.isOn = true  // "날짜 설정" 기본값 => true
        self.todoDatePicker.addTarget(self, action: #selector(onDidChangeDate(sender:)), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        self.titleTextField.setBottomBorder()
        
    }
    
    @objc func onDidChangeDate(sender: UIDatePicker) {
        self.selectedDate = sender.date
    }    

    @IBAction func saveButtonTouch(_ sender: Any) {
        if let title = self.titleTextField.text {
            if self.isTodoDateSwitch.isOn {
                CoredataManager.shared.insertTodoTalk(title: title, isUseDate: true, selectedDate: self.selectedDate)
            } else {
                CoredataManager.shared.insertTodoTalk(title: title, isUseDate: false, selectedDate: nil)
            }
        }
        
        // delegate
        self.delegate?.didFinishSaveData()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTouchSwitch(_ sender: Any) {
        
        self.todoDatePicker.layer.isHidden = !self.isTodoDateSwitch.isOn
    }
    
    @IBAction func cancelButtonTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddTalkVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
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
