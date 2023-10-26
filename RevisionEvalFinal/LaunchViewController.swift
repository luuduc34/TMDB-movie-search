//
//  LaunchViewController.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 24/10/2023.
//

import UIKit
import Lottie

class LaunchViewController: UIViewController {
    
    private var animationView: LottieAnimationView = LottieAnimationView(name: "movie")
    @IBOutlet weak var lottieView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Créez une vue Lottie
        
        // Do any additional setup after loading the view.
        animationView.frame = lottieView.bounds
        // define content mode and animation loop
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        //add animation to our view
        lottieView.addSubview(animationView)
        // Play animation
        //animationView.play()
        // Lancez l'animation
        animationView.play { (finished) in
            // Animation terminée, passez à l'interface utilisateur principale
            if finished {
                transitionToMainInterface()
            }
        }
        func transitionToMainInterface() {
            // Assurez-vous que "MainViewController" correspond à l'identifiant de votre View Controller principal.
            if let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                if tabBarController.viewControllers?[0] is UIViewController {
                    // Utilisez l'index correct pour accéder à l'onglet que vous souhaitez afficher.
                    // Par exemple, ici nous utilisons 0 pour accéder au premier onglet.
                    // Assurez-vous que l'index correspond à l'onglet que vous voulez afficher.
                    tabBarController.selectedIndex = 0 // Sélectionnez l'onglet que vous voulez afficher
                    tabBarController.modalPresentationStyle = .fullScreen
                    self.present(tabBarController, animated: true, completion: nil)
                }
            }
        }
        
    }
}
