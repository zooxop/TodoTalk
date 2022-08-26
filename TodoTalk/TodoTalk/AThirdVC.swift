//
//  AThirdVC.swift
//  TodoTalk
//
//  Created by 문철현 on 2022/08/26.
//

import UIKit

class AThirdVC: UIViewController {

    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: modalDelegate?
            
    // let menuView = UIView()
    
    let menuHeight = UIScreen.main.bounds.height / 3  // half 아니고 1/3
    
    var isPresenting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        self.view.backgroundColor = .clear
        
        backdropView.frame = self.view.bounds
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.view.addSubview(menuView)
        
        print(UIScreen.main.bounds.height)
        
        menuView.backgroundColor = .systemBackground
        menuView.layer.cornerRadius = 20
        menuView.translatesAutoresizingMaskIntoConstraints = false
        //menuView.frame.width = UIScreen.main.bounds.width
        menuView.heightAnchor.constraint(equalToConstant: menuHeight).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // 뒷배경 터치하면 모달 내려가도록.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AThirdVC.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
        
        // self.temp()
        // self.temp2()
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .dateAndTime
        datePicker.contentHorizontalAlignment = .center

    }
    
    func temp() {
        // To-do: menuView에 subview로 DatePicker, 확인버튼 추가하기.
        let datePicker1 = UIDatePicker(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        // datePicker = UIDatePicker(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        // datePicker = UIDatePicker()
        datePicker1.translatesAutoresizingMaskIntoConstraints = false
        datePicker1.center = CGPoint(x: 100, y: 30)
        
        // datePicker.frame = CGRect(x: 10, y: 50, width: UIScreen.main.bounds.width, height: 200)
        datePicker1.preferredDatePickerStyle = .wheels
        datePicker1.datePickerMode = .dateAndTime
        datePicker1.timeZone = NSTimeZone.local
        datePicker1.backgroundColor = UIColor.systemBackground
        datePicker1.layer.cornerRadius = 20
        // datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    
        datePicker1.addTarget(self, action: #selector(onDidChangeDate(sender:)), for: .valueChanged)
        menuView.addSubview(datePicker1)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onDidChangeDate(sender: UIDatePicker){
        // Generate the format.
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"

        let selectedDate: String = dateFormatter.string(from: sender.date)
        delegate?.pickedDate(text: selectedDate)   // 마더 폼으로 날짜 보내기
    }


}

extension AThirdVC: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
