// Core data
// calendar

// To-do:
// - MVC / MVVM


import UIKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var talkTableView: UITableView!
    
    var todoTalks = [TodoTalk]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To-Do Talk"
        
        self.talkTableView.delegate = self
        self.talkTableView.dataSource = self
        
        self.makeNavigationBar()
        
        self.fetchTodoTalks()  // coredata - 데이터 가져오기
        self.talkTableView.reloadData()
        
        // Talk 화면으로 넘어갈 때, 뒤로가기 버튼에 붙어있는 title 지우기.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        self.todoTalks = CoredataManager.shared.getTodoTalks(ascending: true, isFinished: false)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoTalks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTalkCell", for: indexPath) as! TodoTalkCell
        
        // 마지막 content(채팅) 내용이 보이게.
        cell.todoTitleLabel.text = todoTalks[indexPath.row].title
        if let contents = self.todoTalks[indexPath.row].joinTalkId?.array as? [TalkContents] {
            if let talkContents = contents.first?.content {
                cell.todoContentLabel.text = talkContents.description
                if cell.todoContentLabel.countCurrentLines() == 1 {
                    cell.todoContentLabel.text = talkContents + "\n"
                }
            } else {
                cell.todoContentLabel.text = " \n"
            }
        } else {
            cell.todoContentLabel.text = " \n"
        }

        cell.dateCheckView.layer.cornerRadius = cell.dateCheckView.bounds.height / 2
        cell.dateCheckView.layer.borderWidth = 0
        
        for subView in cell.dateCheckView.subviews {
            subView.removeFromSuperview()
        }

        
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
        let talkVC = TalkVC.init(nibName: "TalkVC", bundle: nil)
        
        talkVC.modalPresentationStyle = .fullScreen
        talkVC.talk = self.todoTalks[indexPath.row]
        talkVC.delegate = self
        talkVC.title = self.todoTalks[indexPath.row].title
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.pushViewController(talkVC, animated: true)
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

extension ViewController: TalkVCDelegate {
    func didFinish() {
        self.talkTableView.reloadData()
    }
}