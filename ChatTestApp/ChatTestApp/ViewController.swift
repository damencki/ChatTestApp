import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private lazy var displayNameTextField = UITextField {
        $0.text = ApplicationSettings.displayName
        $0.borderStyle = .roundedRect
    }
    
    private lazy var loginButtton = UIButton {
        $0.setTitle("Go to chat", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(displayNameTextField)
        view.addSubview(loginButtton)
        
        displayNameTextField.snp.makeConstraints { textField in
            textField.leading.equalTo(view.snp.leading).offset(8)
            textField.trailing.equalTo(view.snp.trailing).offset(-8)
            textField.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        
        loginButtton.snp.makeConstraints { button in
            button.top.equalTo(displayNameTextField.snp.bottom).offset(16)
            button.centerX.equalTo(view.snp.centerX)
            button.width.equalTo(200)
            button.height.equalTo(100)
        }
    }
    
    @objc private func didTapButton() {
        guard let displayName = displayNameTextField.text else {return}
        ApplicationSettings.displayName = displayName
    }
}

