//
//  ViewController2.swift
//  ITOSoftwareTest
//
//  Created by Edward Pizzurro on 1/24/23.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    //MARK:- Declaración de Variables
    var mMapView: MKMapView!
    var locationManager:CLLocationManager!
    var firstTimeCalling = true
    
    //Botón para enviar email
    lazy var sendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Send Email", for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendEmailAction), for: .touchUpInside)
        return button
    }()

    //MARK: - LifeCycle Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
    }

    
    //MARK: - Intance Methods -
    func determineCurrentLocation() {
        //Borramos lo que exista en "array" con el fin de crear un nuevo registro desde cero
        UserDefaults.standard.removeObject(forKey: "array")
        
        //Seteamos el LocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                //Si la localización está activada, entonces se procede a activar el rastreo
                self.checkLocationPermissionsChanges()
            } else {
                //Si la localización no está activada, se mostrará una alerta indicando al usuario que debe de activarla para poder utilizar la app
                DispatchQueue.main.async {
                    let alert = Utils().createAlertController(title: "Error", message: "Los servicios de localización están desactivados, por favor actívalos desde configuración para poder utilizar la app", actionTitle: "Ok", withAction: true)
                    self.present(alert, animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    //Este método chequea si los permisos de localización cambian y en base a eso muestra una alerta o, si están activos, activa la localización del usuario
    func checkLocationPermissionsChanges() {
        guard let _ = locationManager else {
            return
        }
        
        DispatchQueue.main.async {
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestAlwaysAuthorization()
                break
            case .restricted:
                let alert = Utils().createAlertController(title: "Error", message: "Los servicios de localización están desactivados, por favor actívalos desde configuración para poder utilizar la app", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                break
            case .denied:
                let alert = Utils().createAlertController(title: "Error", message: "Los servicios de localización están desactivados, por favor actívalos desde configuración para poder utilizar la app", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                break
            @unknown default:
                break
            }
        }
    }
    
    //Método del delegado de CLLocationManagerDelegate que se dispara cada vez que los permisos cambian
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissionsChanges()
    }
}


//MARK: - Setup UI -
extension MapViewController {
    //En este método seteamos toda la UI de nuestra vista
    private func setupUI() {
        //Ocultamos el botón "back" del navigationItem
        navigationItem.setHidesBackButton(true, animated: false)
        
        //Seteamos el MKMapView, que es el que usaremos en la vista
        mMapView = MKMapView()
                
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        //Lo agregamos a la pantalla y hacemos respectivas configuraciones
        mMapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        mMapView.mapType = MKMapType.standard
        mMapView.isZoomEnabled = true
        mMapView.showsUserLocation = true
        mMapView.userTrackingMode = .follow
        mMapView.isScrollEnabled = false
        view.addSubview(mMapView)
        
        //Añadimos el botón de mandar email a la vista con su respectivo AutoLayout
        view.addSubview(sendEmailButton)
        sendEmailButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        sendEmailButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        sendEmailButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sendEmailButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}


//MARK: - CLLocationManagerDelegate Methods -
extension MapViewController {
    //Método del delegado CLLocationManagerDelegate que se dispara cada vez que el dispositivo muestra nuevas coordenadas de donde se encuentra actualmente el usuario
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Seteamos la localización y la región
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion: MKCoordinateRegion!
        if firstTimeCalling {
            mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            firstTimeCalling = false
        } else {
            mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: mMapView.region.span.latitudeDelta, longitudeDelta: mMapView.region.span.longitudeDelta))
        }

        //Seteamos la región a nuestro MKMapView
        mMapView.setRegion(mRegion, animated: true)
        
        //Obteemos el email del usuario
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? "Usuario"
        
        //Creamos un objeto "Location" con la información que posteriormente se incluirá en el reporte
        let location = Location(usuario: email, latitud: "\(mUserLocation.coordinate.latitude)", longitud: "\(mUserLocation.coordinate.longitude)", fecha: Utils().getActualTimeString())
        
        //Seteamos y sobre escribimos el objeto "array" guardado en la memoria interna de la app con el fin de poder actualizarlo con el nuevo objeto "Location". Este array es el que se incluirá en el archivo .txt que se enviará en el email
        if let data = UserDefaults.standard.object(forKey: "array") as? Data,
           let locationArray = try? JSONDecoder().decode([Location].self, from: data) {
        
            var arr = locationArray
            arr.append(location)
            UserDefaults.standard.removeObject(forKey: "array")
            
            if let encoded = try? JSONEncoder().encode(arr) {
                UserDefaults.standard.set(encoded, forKey: "array")
            }
            
        } else {
            var arrayLocation: [Location] = []
            arrayLocation.append(location)
            
            if let encoded = try? JSONEncoder().encode(arrayLocation) {
                UserDefaults.standard.set(encoded, forKey: "array")
            }
        }
    }
    
    //Si la obtención de la localización falla, mostramos una alerta
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            let alert = Utils().createAlertController(title: "Error", message: "Error en obtener la localización del usuario", actionTitle: "Ok", withAction: true)
            self.present(alert, animated: true)
        }
    }
}


//MARK: - Action Methods -
extension MapViewController {
    //En este método escribimos el archivo .txt en los archivos de la app
    @objc func sendEmailAction() {
        //Nombre del archivo
        let file = "file.txt"
        //String donde se irá todo el reporte de localización del usuario
        var finalString = ""
        
        //Obtenemos el "array" almacenado en la memoria con todos los datos de la localización del usuario
        guard let data = UserDefaults.standard.object(forKey: "array") as? Data,
              let locationArray = try? JSONDecoder().decode([Location].self, from: data) else { return }
        
        //Añadimos todos los datos al finalString
        for i in locationArray {
            if finalString.isEmpty {
                finalString = i.printLocationItem()
            } else {
                finalString = "\(finalString)\n\(i.printLocationItem())"
            }
        }

        //Obtenemos la ruta del directorio en el cual guardaremos el archivo .txt
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            //Obtenemos el URL de la ruta
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                //Escribimos en el archivo .txt el finalString
                try finalString.write(to: fileURL, atomically: false, encoding: .utf8)
                //Función para mandar email al usuario con el reporte. Recibe como parámetro el directorio donde se encuentra el archivo .txt
                self.sendEmail(locationFile: fileURL.path)
            }
            catch {
                //Si hay algun error al escribir los datos dentro del archivo .txt, mostramos una alerta
                let alert = Utils().createAlertController(title: "Error", message: "Error al enviar el email", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
            }
        }
    }
    
    func sendEmail(locationFile: String) {
        //Verificamos si se peude enviar correos. El chequeo es verifciar si en el teléfono existe alguna app de envío de correos, como la app "Mail" incluida en el sistema operativo
        if MFMailComposeViewController.canSendMail() {
            //Creamos la instancia del correo
            let mail = MFMailComposeViewController()
            //Asignamos el destinatario del correo y el asunto del mismo
            mail.setToRecipients(["edwardpizzurro@gmail.com"])
            mail.setSubject("Info. Localización")
            
            //Obtenemos el correo dle usuario para mostrarlo en el mesaje del mensaje del email
            let user = UserDefaults.standard.value(forKey: "array") as? String ?? "User"
            mail.setMessageBody("Esta es el reporte de localización de \(user)", isHTML: true)
            mail.mailComposeDelegate = self
            
            //Adjuntamos el arhivo .txt al email
            if let data = NSData(contentsOfFile: locationFile) {
                mail.addAttachmentData(data as Data, mimeType: "text/plain" , fileName: "file.txt")
            }
            //Mostramos la pantalla con los datos para enviar el email
            present(mail, animated: true)
        }
        else {
            //Si hay algun error al mandar el email, mostramos una alerta
            let alert = Utils().createAlertController(title: "Error", message: "Error al enviar el email", actionTitle: "Ok", withAction: true)
            self.present(alert, animated: true)
        }
    }
}


//MARK: - Mail Compose View Controller Delegate Methods -
extension MapViewController: MFMailComposeViewControllerDelegate {
    
    //Método para verificar las diferentes acciones que pudo haber tomado el usuario con resepcto al envió del correo
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //Si hay algun error, mostramos alerta
        if let _ = error {
            DispatchQueue.main.async {
                let alert = Utils().createAlertController(title: "Error", message: "Hubo un error al enviar tu correo", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        //Dependiendo de el resultado del envío del correom, mostramos una alerta con el mensaje del resultado dado
        DispatchQueue.main.async {
            switch result {
            case .cancelled:
                let alert = Utils().createAlertController(title: "Cancelado", message: "Tu email fue cancelado", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                break
            case .sent:
                let alert = Utils().createAlertController(title: "Enviado", message: "Tu email fue enviado!", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                break
            case .failed:
                let alert = Utils().createAlertController(title: "Error", message: "Hubo un error al enviar tu correo", actionTitle: "Ok", withAction: true)
                self.present(alert, animated: true)
                break
            default:
                break
            }
        }
        
        //Ocultamos la vista del email
        controller.dismiss(animated: true, completion: nil)
    }
}
