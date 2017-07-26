

import UIKit
import FirebaseAuth
import AVKit
import AVFoundation

class SignInVC: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    public let MAIN_SEGUE = "gotoMain"

    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareVideoBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        avPlayer.play()
        paused = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        avPlayer.pause()
        paused = true
        
    }
    
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
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
extension SignInVC{
    
    fileprivate func prepareVideoBackground() {
        guard let videoPath = Bundle.main.path(forResource: "intro", ofType:"mp4") else {
            debugPrint("intro.mp4 not found")
            return
        }
        avPlayer = AVPlayer(url: URL(fileURLWithPath: videoPath))
        avPlayer.actionAtItemEnd = .none
        avPlayer.isMuted = true
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
}
