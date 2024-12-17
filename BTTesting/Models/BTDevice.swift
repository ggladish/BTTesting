//
//  BTDevice.swift
//  BTTesting
//
//  Created by Gregory Gladish on 9/30/24.
//

import Foundation
import CoreBluetooth

struct BTDevice : Identifiable, Codable {
    private var friendlyName: String?
    var deviceInformation = DeviceInformation()
    var peripheral: CBPeripheral?
    private(set) var id: UUID
    private(set) var isKnown = false
    private(set) var connectRequested = false
    var lastPacketDate: Date?
    private(set) var lastPacket: String?
    var stallTimer: Timer?
    var isStalled: Bool = true
    var deviceType = DeviceType.unknown
    
    init(deviceName: String? = nil, peripheral: CBPeripheral) {
        self.friendlyName = deviceName
        self.peripheral = peripheral
        self.id = peripheral.identifier
    }
    
    init(deviceName: String? = nil, id: UUID) {
        self.friendlyName = deviceName
        self.id = id
    }
    
    enum CodingKeys: CodingKey {
        case friendlyName
        case deviceInformation
        case isKnown
        case connectRequested
        case id
        case lastPacketDate
    }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        friendlyName = try values.decode(String?.self, forKey: .friendlyName)
        deviceInformation = try values.decode(DeviceInformation.self, forKey: .deviceInformation)
        isKnown = try values.decode(Bool.self, forKey: .isKnown)
        connectRequested = try values.decode(Bool.self, forKey: .connectRequested)
        id = try values.decode(UUID.self, forKey: .id)
        lastPacketDate = try values.decode(Date?.self, forKey: .lastPacketDate)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(friendlyName, forKey: .friendlyName)
        try container.encode(deviceInformation, forKey: .deviceInformation)
        try container.encode(isKnown, forKey: .isKnown)
        try container.encode(connectRequested, forKey: .connectRequested)
        try container.encode(id, forKey: .id)
        try container.encode(lastPacketDate, forKey: .lastPacketDate)
    }
     
    var displayName:  String {
        get {
            friendlyName ?? (peripheral?.name ?? "Undetected")
        }
        set {
            friendlyName = newValue
        }
    }
    
    var isConnected: Bool {
        peripheral?.state == .connected
    }
    
    mutating func setKnown() {
        isKnown = true
    }
    
    mutating func deactivate() {
        connectRequested = false
        stallTimer?.invalidate()
        isStalled = true
    }
    
    mutating func activate() {
        connectRequested = true
    }
    
    mutating func setDeviceInfo(for mfgrDataType: MfgrDataType, to value: Data) {
        print("BTDevice setting \(mfgrDataType)")
        deviceInformation.setDeviceInformation(for: mfgrDataType, to: value)
    }
    
    mutating func processPacket(_ data: Data?) {
        // packets printed if possible
        guard let data else { return }
        if let inputString = String(data: data, encoding: .utf8) {
            lastPacket = inputString
            print(inputString)
        }
        lastPacketDate = Date.now
    }

    // If CB state goes off and on, are the peripherals still valid?
    // How about it the device resets?
    // if not, should we be able to update peripheral?
    // I think peripheral.identifier will persist even over all device resets

    enum DeviceType {
        case unknown
        case EggFinderGPS(EggFinderDevice)
        case EggTimer(EggTimerDevice)
        
        var eggFinderDevice: EggFinderDevice? {
            switch self {
            case .EggFinderGPS(let eggFinderDevice) : return eggFinderDevice
            default: return nil
            }
        }
        
        var eggTimerDevice: EggTimerDevice? {
            switch self {
            case .EggTimer(let eggTimerDevice) : return eggTimerDevice
            default: return nil
            }
        }
    }
    
}

enum EggTimerDevice {
    case Quasar
    case Proton
    case Quantum
    case Quark
    case Ion
    case WiFiSwitch
    case MiniSwitch
}

enum EggFinderDevice {
    case TX
    case Mini
}
