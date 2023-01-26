//
//  Utils.swift
//  ITOSoftwareTest
//
//  Created by Edward Pizzurro on 1/24/23.
//

import Foundation
import UIKit

class Utils: NSObject {
    //Auxiliar para crear alertas
    func createAlertController(title: String, message: String, actionTitle: String, withAction: Bool) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if withAction {
            alertController.addAction(UIAlertAction(title: actionTitle, style: .default))
        }
        return alertController
    }
    
    //Auxiliar para obtener la fecha actual con la hora incluida
    func getActualTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}
