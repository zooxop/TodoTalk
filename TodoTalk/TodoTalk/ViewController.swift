// Core data
// messageKit
// calendar

// To-do:
// 1. dateCheckView 날짜 or 체크표시 둘 중 하나 보이도록 처리.
// 3. coredata 모델 여러개 사용하기
//   - 조인하는 방법 찾아보기


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var talkTableView: UITableView!
    
    // App delegate 접근
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    let CHECKMARKCOLOR = UIColor(named: "CheckmarkColor")
    let DATEVIEWCOLOR = UIColor(named: "DateViewColor")
    
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    var todoTalks = [TodoTalk]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To-Do Talk"
        
        self.talkTableView.delegate = self
        self.talkTableView.dataSource = self
        
        self.makeNavigationBar()
        
        self.fetchTodoTalks()  // coredata - 데이터 가져오기
        self.talkTableView.reloadData()
    }
    
    func makeNavigationBar() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddTalkVC))
        self.navigationItem.rightBarButtonItem = item
        
    }
    
    @objc func presentAddTalkVC() {
        let addTalkVC = AddTalkVC.init(nibName: "AddTalkVC", bundle: nil)
        
        addTalkVC.delegate = self
        self.present(addTalkVC, animated: true, completion: nil)
    }
    
    func fetchTodoTalks() {
        self.todoTalks = CoredataManager.shared.getTodoTalks(ascending: false, isFinished: false)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoTalks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTalkCell", for: indexPath) as! TodoTalkCell
        
        cell.todoTitleLabel.text = todoTalks[indexPath.row].title
        // cell.todoContentLabel.text = todoTalks[indexPath.row].  // 마지막 채팅 내용이 보여야 함
        if let hasDescription = todoTalks[indexPath.row].selectedDate?.description {
            cell.todoContentLabel.text = hasDescription
            if cell.todoContentLabel.countCurrentLines() == 1 {
                cell.todoContentLabel.text = hasDescription + "\n"
            }
        } else {
            cell.todoContentLabel.text = " \n"
        }
        
        cell.dateCheckView.layer.cornerRadius = cell.dateCheckView.bounds.height / 2
        cell.dateCheckView.layer.borderWidth = 0

        
        if todoTalks[indexPath.row].isUseDate {
            let selectedDate = todoTalks[indexPath.row].selectedDate
            let dateFormatter = DateFormatter()
            
            var monthString = ""
            var dateString = ""
            
            if let date = selectedDate {
                dateFormatter.dateFormat = "MMM"
                monthString = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "dd"
                dateString = dateFormatter.string(from: date)
            }
            
            
            cell.dateCheckView.backgroundColor = DATEVIEWCOLOR
            
            let monthLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let dateLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            cell.dateCheckView.addSubview(monthLabel)
            cell.dateCheckView.addSubview(dateLabel)
            
            monthLabel.translatesAutoresizingMaskIntoConstraints = false
            monthLabel.text = monthString // "JUN"
            monthLabel.textColor = .white
            monthLabel.textAlignment = .center
            monthLabel.font = UIFont.boldSystemFont(ofSize: 15)
            
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.text = dateString // "17"
            dateLabel.textColor = .white
            dateLabel.textAlignment = .center
            dateLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            let margineGuide = cell.dateCheckView.layoutMarginsGuide
            NSLayoutConstraint.activate([
                monthLabel.topAnchor.constraint(equalTo: margineGuide.topAnchor, constant: 0),
                monthLabel.leadingAnchor.constraint(equalTo: margineGuide.leadingAnchor),
                monthLabel.trailingAnchor.constraint(equalTo: margineGuide.trailingAnchor),
                
                dateLabel.topAnchor.constraint(equalTo: monthLabel.topAnchor, constant: 20),
                dateLabel.leadingAnchor.constraint(equalTo: margineGuide.leadingAnchor),
                dateLabel.trailingAnchor.constraint(equalTo: margineGuide.trailingAnchor)
            ])

        } else {
            cell.dateCheckView.backgroundColor = CHECKMARKCOLOR
            
            // 체크 표시 보여주기
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
            let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            cell.dateCheckView.addSubview(myImageView)
            
            myImageView.translatesAutoresizingMaskIntoConstraints = false
            myImageView.image = UIImage(systemName: "checkmark", withConfiguration: largeConfig)
            myImageView.tintColor = .white
            
            myImageView.contentMode = .scaleAspectFit
            myImageView.centerXAnchor.constraint(equalTo: cell.dateCheckView.centerXAnchor).isActive = true
            myImageView.centerYAnchor.constraint(equalTo: cell.dateCheckView.centerYAnchor).isActive = true
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell 클릭 이벤트
        // Talk 화면으로 넘어가는 코딩 필요.
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // 스와이프 이벤트
    // 오른쪽에 스와이프 버튼 만들기
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteTalk = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            CoredataManager.shared.updateTalkFinished(talkData: self.todoTalks[indexPath.row], isFinished: true)
            self.todoTalks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        }
        deleteTalk.backgroundColor = .systemRed
        
        //actions배열 인덱스 0이 왼쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[deleteTalk])
    }
    
}

// Add 팝업 페이지 delegate
extension ViewController: AddTalkVCDelegate {
    func didFinishSaveData() {
        self.fetchTodoTalks()
        self.talkTableView.reloadData()
    }
}


extension UILabel {

    func countCurrentLines() -> Int {
        guard let text = self.text as NSString? else { return 0 }
        guard let font = self.font              else { return 0 }
        
        var attributes = [NSAttributedString.Key: Any]()
        
        // kern을 설정하면 자간 간격이 조정되기 때문에, 크기에 영향을 미칠 수 있습니다.
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
