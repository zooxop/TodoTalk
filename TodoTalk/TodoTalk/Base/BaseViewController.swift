import UIKit
import SafeAreaBrush
import CoreData

class BaseViewController: UIViewController {
    
    let CHECKMARKCOLOR = UIColor(named: "CheckmarkColor")
    let DATEVIEWCOLOR = UIColor(named: "DateViewColor")
    let INPUTBGCOLOR = UIColor(named: "InputBGColor")
    
    
    // 대화내용 옆에 붙일 날짜용
    let tcDateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tcDateFormatter.dateFormat = "yyyy.MM.dd"
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

extension BaseViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
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

extension UILabel {

    func countCurrentLines() -> Int {
        guard let text = self.text as NSString? else { return 0 }
        guard let font = self.font              else { return 0 }
        
        var attributes = [NSAttributedString.Key: Any]()
        
        // kern을 설정하면 자간 간격이 조정되기 때문에, 크기에 영향을 미칠 수 있다.
        if let kernAttribute = self.attributedText?.attributes(at: 0, effectiveRange: nil).first(where: { key, _ in
            return key == .kern
        }) {
            attributes[.kern] = kernAttribute.value
        }
        attributes[.font] = font
        
        // width을 제한한 상태에서 해당 Text의 Height를 구하기 위해 boundingRect 사용
        let labelTextSize = text.boundingRect(
            with: CGSize(width: self.bounds.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        // 총 Height에서 한 줄의 Line Height를 나누면 현재 총 Line 수
        return Int(ceil(labelTextSize.height / font.lineHeight))
    }
 
}
