import UIKit
// import SafeAreaBrush
import CoreData

class BaseViewController: UIViewController {
    
    let INPUTBGCOLOR = UIColor(named: "InputBGColor")

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // textView에 입력된 글의 내용에 따른 높이 설정
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if estimatedSize.height <= 30  || estimatedSize.height >= 100 {
                
            } else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
}


extension UITableView {
    
    // View를 화면 최하단으로 스크롤
    func scrollToBottom(animated: Bool, count: Int) {
        let lastIndexPath = IndexPath(row: (count - 1), section: 0)
        if lastIndexPath[1] >= 0 {
            DispatchQueue.main.async {
                self.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: animated)
            }
        }
    }
}

extension BaseViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}
