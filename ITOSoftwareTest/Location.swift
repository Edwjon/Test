//
//  Location.swift
//  ITOSoftwareTest
//
//  Created by Edward Pizzurro on 1/25/23.
//

import Foundation

struct Location: Codable {
    let usuario: String
    let latitud: String
    let longitud: String
    let fecha: String
    
    func printLocationItem() -> String {
        let mainString = "Usuario: \(usuario), Latitud: \(latitud), Longitud: \(longitud), Fecha: \(fecha)"
        return mainString
    }
}
