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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoTalk", in: context) else {
            return
        }
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoTalk else {
            return
        }
        
        object.uuid = UUID()  // UUID: Unique ID
        object.title = titleTextField.text
        object.createDate = Date()  // 현재 날짜
        object.isFinished = false
        
        object.isUseDate = self.isTodoDateSwitch.isOn  // 날짜 설정 여부
        if self.isTodoDateSwitch.isOn {
            object.selectedDate = self.selectedDate
        } else {
            object.selectedDate = nil  // 날짜 사용 X
        }
        
        
        // save data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
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
