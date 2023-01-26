//
//  ViewController.swift
//  ITOSoftwareTest
//
//  Created by Edward Pizzurro on 1/24/23.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    //Imagen de google donde el usuario hará tap
    lazy var googleImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "googleImage")
        iv.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(googleAction))
        iv.addGestureRecognizer(tapGesture)
        return iv
    }()
    
    //Etiqueta de google
    let googleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Google"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForUserDefaults()
        setupUI()
    }


}

//MARK: - Setup -
extension LoginViewController {
    //Seteamos la UI de la vista
    func setupUI() {
        //Color de la vista
        view.backgroundColor = UIColor(red: 0.459, green: 0.789, blue: 0.916, alpha: 1)
        
        //Añadimos la imagen de google a la vista
        view.addSubview(googleImageView)
        googleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        googleImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        googleImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //Añadimos la etiqueta de google a la vista
        view.addSubview(googleLabel)
        googleLabel.topAnchor.constraint(equalTo: googleImageView.bottomAnchor, constant: 20).isActive = true
        googleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        googleLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
}


//MARK: - Class Methods -
extension LoginViewController {
    //Aqui se chequea si existe un usuario. En este caso solo nos importa ver si hay un correo almacenado en la memoria, pues el único dato que usaremos en la applicación
    func checkForUserDefaults() {
        let defaults = UserDefaults.standard
        if let _ = defaults.value(forKey: "email") as? String {
            let vc = MapViewController()
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    //Llamamos al método para iniciar sesión de Firebase
    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { result, error in
            if let result = result, error == nil {
                //Creamos la instancia de MapViewController
                let vc = MapViewController()
                
                //Guardamos el email del usuario
                let defaults = UserDefaults.standard
                defaults.set(result.user.email, forKey: "email")
                defaults.synchronize()
                
                //Navegamos a la vista con el mapa
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                //Si el inicio de sesión sale mal, mostramos alerta
                let alert = Utils().createAlertController(title: "Error", message: "Se ha producido un error registrando el usuario", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


//MARK: - Action Methods -
extension LoginViewController {
    //Método para iniciar sesión utilizando Google
    @objc func googleAction() {
        //Hacemos cierre de sesión de cualquier sesión que pudo haber estado en la app
        GIDSignIn.sharedInstance.signOut()
        
        //Asignamos el clientID a la configuración que usará el iniciio de sesión de Google
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //Se llama el método con closure para manejar el inicio de sesión
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] user, error in
            //Si el inicio de sesión sale mal, mostramos alerta
            if let error = error {
                let alert = Utils().createAlertController(title: "Error", message: error.localizedDescription, actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            //Guardamos la credeciales obtenidas y llamamos al método SignIn, pasándole como parámetro las credenciales
            let credential = GoogleAuthProvider.credential(withIDToken: (user?.user.idToken?.tokenString)!,
                                                           accessToken: (user?.user.accessToken.tokenString)!)
            self.signIn(credential: credential)
        }
    }
}
