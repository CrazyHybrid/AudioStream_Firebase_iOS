

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    public let MAIN_SEGUE = "gotoMain"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func LogIn(_ sender: Any) {
        
        if (EmailTextField.text != "" && PasswordTextField.text != "") {
        AuthProvider.Instance.login(withEmail: EmailTextField.text!, password: PasswordTextField.text!, loginHandler: { (message) in
            
            if (message != nil) {
                self.alertUser(title: "Problem with Authentication", message: message!);
            }
            else{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "listVC")
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
                }
            });
        }
        else{
            alertUser(title: "Email and Password Required", message: "Please enter a valid email and password");
        }
    }
    
    @IBAction func SignUp(_ sender: Any) {
    
        if (EmailTextField.text != "" && PasswordTextField.text != ""){
            AuthProvider.Instance.signUp(withEmail: EmailTextField.text!, password: PasswordTextField.text!, loginHandler: { (message) in
                if (message != nil){
                    self.alertUser(title: "Problem with Account Registration", message: message!);
                }
                else{
                    self.performSegue(withIdentifier: self.MAIN_SEGUE, sender: nil);
                }
            });
        }
        else{
            alertUser(title: "Email and Password Required", message: "Please enter a valid email and password");
        }
    }
    
    private func alertUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }

}

extension SignInVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EmailTextField {
            let _ = PasswordTextField.becomeFirstResponder()
        }
        else {
            EmailTextField?.resignFirstResponder()
            PasswordTextField?.resignFirstResponder()
        }
        
        return true
    }
}
