//
//  SerialBTDevice.swift
//  RocketGPSTracker
//
//  Created by Gregory Gladish on 9/27/24.
//

import Foundation
import CoreBluetooth

enum SerialBTDevice {
    
    static let deviceInformationServiceCBUUID = CBUUID(string: "0x180A")
    static let mfgrNameCharacteristicCBUUID = CBUUID(string: "2A29")
    static let pnpIDCharacteristicCBUUID = CBUUID(string: "2A50")

    static let serialDataServiceCBUUID = CBUUID(string: "0xFFE0")
    static let readDataPortCharacteristicCBUUID = CBUUID(string: "FFE1")
    static let writeDataPortCharacteristicCBUUID = CBUUID(string: "FFE2")

}
