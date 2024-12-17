//
//  SerialBTDevice.swift
//  RocketGPSTracker
//
//  Created by Gregory Gladish on 9/27/24.
//

import Foundation
import CoreBluetooth

enum SerialBTDevice {
    
    // Device Information Service UUIDs
    static let deviceInformationServiceCBUUID = CBUUID(string: "0x180A")
    static let mfgrNameCharacteristicCBUUID = CBUUID(string: "2A29")
    static let modelNumberCharacteristicCBUUID = CBUUID(string: "2A24")
    static let serialNumberCharacteristicCBUUID = CBUUID(string: "2A25")
    static let hardwareRevCharacteristicCBUUID = CBUUID(string: "2A27")
    static let firmwareRevCharacteristicCBUUID = CBUUID(string: "2A26")
    static let softwareRevCharacteristicCBUUID = CBUUID(string: "2A28")
    static let systemIDCharacteristicCBUUID = CBUUID(string: "2A23")
    static let pnpIDCharacteristicCBUUID = CBUUID(string: "2A50")
    static let medicalDevUDICharacteristicCBUUID = CBUUID(string: "2BFF")

    // Serial Data Service UUIDs - sort of.
    static let serialDataServiceCBUUID = CBUUID(string: "0xFFE0")
    static let readDataPortCharacteristicCBUUID = CBUUID(string: "FFE1")
    static let writeDataPortCharacteristicCBUUID = CBUUID(string: "FFE2")

}

struct DeviceInformation: Codable {
    var manufacturerName: String?
    var modelNumber: String?
    var serialNumber: String?
    var hardwareRevision: String?
    var firmwareRevision: String?
    var softwareRevision: String?
    var systemID: [UInt8] = []
    var pnpID: [UInt8] = []
    var medicalDeviceUDI: [UInt8] = []
    var ieeeeDataList: [UInt8] = []
    
    mutating func setDeviceInformation(for mfgrDataType: MfgrDataType, to value: Data) {
        let valueAsString = String(data: value, encoding: .utf8)
        switch mfgrDataType {
        case .ManufacturerName: manufacturerName = valueAsString ?? "Garbled"
        case .ModelNumber: modelNumber = valueAsString ?? "Garbled"
        case .SerialNumber: serialNumber = valueAsString ?? "Garbled"
        case .HardwareRev: hardwareRevision = valueAsString ?? "Garbled"
        case .FirmwareRev: firmwareRevision = valueAsString ?? "Garbled"
        case .SoftwareRev: softwareRevision = valueAsString ?? "Garbled"
        case .SystemID: systemID = value.map { $0 }
        case .PnPID: pnpID = value.map { $0 }
        case .MedicalDeviceUDI: medicalDeviceUDI = value.map { $0 }
        case .IEEEDataList: ieeeeDataList = value.map { $0 }
        }
    }
        
}

enum MfgrDataType : String {
    case ManufacturerName
    case ModelNumber
    case SerialNumber
    case HardwareRev
    case FirmwareRev
    case SoftwareRev
    case SystemID
    case PnPID
    case MedicalDeviceUDI
    case IEEEDataList
}


