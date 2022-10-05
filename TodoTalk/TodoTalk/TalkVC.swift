import UIKit
import CoreData

// 2. 다크모드 대응

protocol TalkVCDelegate: AnyObject {
    func didFinish()
}

class TalkVC: UIViewController {
    
    let bottomColor: UIColor = UIColor.init(red: 235/255, green: 236/255, blue: 240/255, alpha: 1.0)
    
    weak var delegate: TalkVCDelegate?
    
    @IBOutlet weak var inputBGView: UIView! {
        didSet {
            inputBGView.backgroundColor = bottomColor
        }
    }
    @IBOutlet weak var bottomSafeAreaView: UIView! {
        didSet {
            bottomSafeAreaView.backgroundColor = bottomColor
        }
    }
    @IBOutlet weak var contentsTableView: UITableView! {
        didSet {
            contentsTableView.delegate = self
            contentsTableView.dataSource = self
            contentsTableView.separatorStyle = .none
            
            contentsTableView.register(UINib(nibName: "MyTalkCell", bundle: nil), forCellReuseIdentifier: "MyTalkCell")
            contentsTableView.keyboardDismissMode = .interactive
        }
    }
    
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.delegate = self
        }
    }
    
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    var talk: TodoTalk!
    var talkContents: [TalkContents]!
    
    func loadTalkContents() {
        let contents = self.talk.joinTalkId?.array as! [TalkContents]
        talkContents = contents.reversed().filter { $0.isDeletedContent == false }
    }
    
    func scrollToBottom(animated: Bool) {
        let lastIndexPath = IndexPath(row: (self.talkContents.count - 1), section: 0)
        if lastIndexPath[1] >= 0 {
            DispatchQueue.main.async {
                self.contentsTableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: animated)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTalkContents()
        // 키보드 관련 옵저버 - 상태를 알려줌
        // - 키보드가 올라올 때
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // - 키보드가 내려갈 때
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // - 키보드가 완전히 올라온 뒤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        // default height를 고정값으로 처리할 수 없음. (기기마다 폰트 사이즈가 다를 수 있으므로.)
        // -> 한 글자 미리 입력해놓고, textview 높이 조절 이벤트를 호출.
        // 이벤트가 끝나면 다시 text를 클리어 해준다.
        self.inputTextView.text = "."
        self.textViewDidChange(self.inputTextView)
        self.inputTextView.text = ""
        
        // 제스쳐 핸들러 등록
        // 화면 전체를 UIViewController로 덮어놨기 때문에, touchesBegan 만으로는 동작하지 않는다.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        // 맨 아래로 스크롤
        self.scrollToBottom(animated: false)
        
        // 키보드 올라올때/내려올때 bottomAcnhor autolayout 활성화
        self.contentsTableView.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor).isActive = true

        
    }
        
    // Observer 해제
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        self.delegate?.didFinish()
    }
    
    // 화면 터치하면 키보드 내려가도록.
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardDidShow(noti: Notification) {
        self.scrollToBottom(animated: true)
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        // 키보드의 frame 가져오기
        let notiInfo = noti.userInfo!
        let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        
        // let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        // 키보드 frame의 높이 - safe area 높이
        let height = keyboardFrame.size.height - self.view.safeAreaInsets.bottom
        
        // 키보드가 올라올/내려올 때 호출되는 애니메이션의 동작시간 가져오기.
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        // Animation 적용
        UIView.animate(withDuration: animationDuration) {
            // 높이 적용해주기
            self.inputViewBottomMargin.constant = 0 - height
            // self.contentsTableView.

            // layoutIfNeeded => layout 변경에 대한 이벤트를 큐의 뒤쪽이 아닌 앞으로 가져오고
            // 그에 대해 즉시 실행해주는 명령.
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
       
        // 키보드의 frame 가져오기
        let notiInfo = noti.userInfo!

        // 키보드가 올라올/내려올 때 호출되는 애니메이션의 동작시간 가져오기.
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        UIView.animate(withDuration: animationDuration) {
            self.inputViewBottomMargin.constant = 0
            self.view.layoutIfNeeded()
        }
 
    }
    
    // 전송 버튼 이벤트
    @IBAction func saveTalkContent(_ sender: Any) {
        
        if let inputText = self.inputTextView.text {
            CoredataManager.shared.insertTalkContents(todoTalk: self.talk, content: inputText)
            self.loadTalkContents()
            self.inputTextView.text.removeAll()
            
            self.textViewDidChange(self.inputTextView)
            
            self.contentsTableView.reloadData()
            let lastIndexPath = IndexPath(row: (self.talkContents.count - 1), section: 0)
            contentsTableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
}

extension TalkVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.talkContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTalkCell", for: indexPath) as! MyTalkCell
        cell.contentTextView.text = self.talkContents[indexPath.row].content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let sendDateString = dateFormatter.string(from: self.talkContents[indexPath.row].sendDate!)
        if indexPath.row < self.talkContents.count - 1 {
            let nextContentDateString = dateFormatter.string(from: self.talkContents[indexPath.row+1].sendDate!)
            // 바로 다음 Content와 날짜가 같으면 표시하지 않는다.
            if sendDateString != nextContentDateString {
                cell.dateLabel.text = sendDateString
                cell.bottomSpace.constant = 10  // 간격 조정
            } else {
                cell.dateLabel.text?.removeAll()
            }
            
            if indexPath.row == 0 {
                cell.topSpace.constant = 5
            }
        } else {
            cell.dateLabel.text = sendDateString
        }
        
        cell.isFinishedMark.isHidden = !self.talkContents[indexPath.row].isFinished
        
        return cell
    }
    
    // 오른쪽에 스와이프 버튼 만들기
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteContent = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            CoredataManager.shared.updateTalkContentsDelete(talkContents: self.talkContents[indexPath.row], isDeletedContent: true)
            self.talkContents.remove(at: indexPath.row)
            self.contentsTableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        }
        
        deleteContent.backgroundColor = .systemRed
        
        var finishedButtonText = ""
        var isFinished = false
        var finishedColor: UIColor
        if self.talkContents[indexPath.row].isFinished == true {
            isFinished = true
            finishedButtonText = "취소"
            finishedColor = .systemGreen
        } else {
            isFinished = false
            finishedButtonText = "완료"
            finishedColor = .systemBlue
        }
        
        let finishContent = UIContextualAction(style: .normal, title: finishedButtonText) { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let hasCell = self.contentsTableView.cellForRow(at: indexPath) as? MyTalkCell else {
                return
            }
            
            hasCell.isFinishedMark.layer.isHidden = isFinished
            
            CoredataManager.shared.updateTalkContentsFinished(talkContents: self.talkContents[indexPath.row], isFinished: !isFinished)
            
            success(true)
        }
        finishContent.backgroundColor = finishedColor
        
        return UISwipeActionsConfiguration(actions: [deleteContent, finishContent])
    }
  
}

extension TalkVC: UITextViewDelegate {
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
