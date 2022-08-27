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
    var formatter = DateFormatter()
    let datePicker = UIDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        datePicker.locale = NSLocale(localeIdentifier: "ko_KO") as Locale
    }
    
    override func viewDidLayoutSubviews() {
        self.titleTextField.setBottomBorder()
        
    }
    

    @IBAction func saveButtonTouch(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoTalk", in: context) else {
            return
        }
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoTalk else {
            return
        }
        
        object.title = titleTextField.text
        object.createDate = Date()  // 현재 날짜
        object.uuid = UUID()  // UUID: Unique ID
        object.deadline = Date()  // 임시로
        object.isFinished = false
        
        // save data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        // delegate
        delegate?.didFinishSaveData()
        
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
