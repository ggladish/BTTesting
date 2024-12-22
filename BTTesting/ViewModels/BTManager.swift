//
//  BTManager.swift
//  BTTesting
//
//  Created by Gregory Gladish on 9/30/24.
//

import Foundation
import CoreBluetooth

@Observable
class BTManager: NSObject {
    
    var availableBTDevices = [BTDevice]()
    
    private var centralManager: CBCentralManager!
    var isScanning = false
    private var bluetoothScanTimer: Timer?
    

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadPriorKnownDevices(from: devicesURL)
    }
    
    // MARK: Convenience index requests
    
    func index(of device: BTDevice?) -> Int? {
        availableBTDevices.firstIndex(where: {$0.id == device?.id})
    }
    
    func index(withUUID uuid: UUID) -> Int? {
        availableBTDevices.firstIndex(where: {$0.id == uuid})
    }
   
    // MARK: Serialization support - known devices only

    private let devicesURL: URL = URL.applicationSupportDirectory.appendingPathComponent("KnownDevices.devices")
    
    private func saveKnownDevices(to url: URL) {
        do {
            checkAndCreateDirectory(atURL: URL.applicationSupportDirectory)
            let data = try JSONEncoder().encode(knownDevices)
            try data.write(to: url)
            print("BTM saved \(knownDevices.count) devices in \(data.count) bytes.")
        } catch let error {
            print("BTManager: error saving devices. \(error.localizedDescription)")
        }
    }
    
    private func checkAndCreateDirectory(atURL url: URL) {
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("BTManager create Directory failed \(error)")
            }
        }
    }
    
    private func loadPriorKnownDevices(from url: URL) {
        print("BTManager attempting to load device list")
        if let data = try? Data(contentsOf: url) {
            print("BTH: loaded \(data.count) bytes.")
            if let savedDevices = try? JSONDecoder().decode([BTDevice].self, from: data) {
                availableBTDevices = savedDevices
                print("BTH: \(savedDevices.count) devices found.")
            }
        }
    }
    

    // MARK: access to model
    
    var knownDevices: [BTDevice] {
        availableBTDevices.filter({ $0.isKnown == true })
    }
    
    var unknownDevices: [BTDevice] {
        availableBTDevices.filter({ $0.isKnown == false })
    }
    
    func getAllDevices() -> [BTDevice] {
        availableBTDevices
    }
    
    func getReconnectDevices() -> [BTDevice] {
        availableBTDevices.filter({ $0.connectRequested == true })
    }
    
    // MARK: Intents
    
    func updateName(_ string: String, for device: BTDevice) {
        guard let devIndex = index(of: device) else { return }
        availableBTDevices[devIndex].displayName = string
        setKnown(device)
    }
    
    func requestDeviceInformation(for device: BTDevice) {
        guard let peripheral = device.peripheral else { return }
        if peripheral.state != .connected {
            centralManager.connect(peripheral)
        }
        if let index = index(of: device) {
            if let timer = availableBTDevices[index].shortConnectionTimer { timer.invalidate() }
            availableBTDevices[index].shortConnectionTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                if !self.availableBTDevices[index].connectRequested {
                    self.centralManager.cancelPeripheralConnection(peripheral)
                }
            }
        }
    }
    
    func setKnown(_ device: BTDevice) {
        guard let devIndex = index(of: device) else { return }
        availableBTDevices[devIndex].setKnown()
        // TODO: this seems like a reasonable time/place to queue a device list serialization request.
        saveKnownDevices(to: devicesURL)
        print("SetKnown queued serialization.")
    }
    
    func deactivateDevices() {
        for index in availableBTDevices.indices {
            availableBTDevices[index].deactivate()
        }
    }
    
    func removeDevice(_ device: BTDevice) {
        guard let index = index(of: device) else { return }
        deselectBluetoothDevice(device)
        availableBTDevices.remove(at: index)
        saveKnownDevices(to: devicesURL)
        if isScanning {
            startBluetoothScan()
        }
    }
    
    private func renewStallTimer(for peripheral: CBPeripheral) {
        guard let index = index(withUUID: peripheral.identifier) else { return }
        availableBTDevices[index].isStalled = false
        if let timer = availableBTDevices[index].stallTimer { timer.invalidate() }
        availableBTDevices[index].stallTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            self.availableBTDevices[index].isStalled = true
        }
    }
    
}

extension BTManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            // for states != .poweredOn, deactivate the devices
        case .unknown:
            print("BTH: central.state is .unknown")
        case .resetting:
            print("BTH: central.state is .resetting")
            deactivateDevices()
        case .unsupported:
            print("BTH: central.state is .unsupported")
            deactivateDevices()
        case .unauthorized:
            print("BTH: central.state is .unauthorized")
            deactivateDevices()
        case .poweredOff:
            print("BTH: central.state is .poweredOff")
            deactivateDevices()
        case .poweredOn:
            print("BTH: central.state is .poweredOn")
            startBluetoothScan()
        @unknown default:
          print("BTH: central.state is unexpected unknown")
        }
    }
    
    func startBluetoothScan() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [SerialBTDevice.serialDataServiceCBUUID])
            print("BTH: start scanning")
            isScanning = true
            // kill any previous timer and set a timer to shut this off after 30 seconds
            if let bluetoothScanTimer { bluetoothScanTimer.invalidate() }
            bluetoothScanTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in self.endBluetoothScan() }
        }
    }
    
    func endBluetoothScan() {
        print("BTH: End scanning")
        isScanning = false
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
        }
        if let bluetoothScanTimer { bluetoothScanTimer.invalidate() }
    }
    
    func selectBluetoothDevice(_ device: BTDevice) {
        if let index = index(of: device) {
            availableBTDevices[index].activate()
        }
        if centralManager.state == .poweredOn {
            setKnown(device)
            if let peripheral = device.peripheral {
                centralManager.connect(peripheral)
            }
        }
    }
    
    func deselectBluetoothDevice(_ device: BTDevice) {
        if let index = index(of: device) {
            availableBTDevices[index].deactivate()
        }
        if centralManager.state == .poweredOn {
            if let peripheral = device.peripheral {
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("BTH: \(peripheral)")
        // if known, try to reconnect if connectRequested
        if let index = index(withUUID: peripheral.identifier) {
            print("Did discover prior device \(peripheral)")
            if availableBTDevices[index].peripheral == nil {
                availableBTDevices[index].peripheral = peripheral
            }
            if !availableBTDevices[index].isConnected,
               availableBTDevices[index].connectRequested,
               availableBTDevices[index].peripheral != nil {
                central.connect(availableBTDevices[index].peripheral!)
            }
        } else { // if new, just add to the list
            print("Did discover new device \(peripheral)")
            availableBTDevices.append(BTDevice(peripheral: peripheral))
        }
        renewStallTimer(for: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BTH: Connected to \(peripheral), discovering services")
        peripheral.delegate = self
        if let index = index(withUUID: peripheral.identifier) {
            availableBTDevices[index].peripheral = peripheral
//            availableBTDevices[index].isConnected = true
        }
        peripheral.discoverServices([SerialBTDevice.serialDataServiceCBUUID])
        if let index = index(withUUID: peripheral.identifier),
           availableBTDevices[index].deviceInformation.isEmpty {
            peripheral.discoverServices([SerialBTDevice.deviceInformationServiceCBUUID])
        }
        renewStallTimer(for: peripheral)
    }
    
//    func centralManager(_ central: CBCentralManager, didDisconnect peripheral: CBPeripheral) {
//        if let devIndex = index(withUUID: peripheral.identifier) {
//             availableBTDevices[devIndex].isConnected = false
//        }
//
//    }

}


// Here, because it's an NSObjectProtocol

extension BTManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        // TODO: handle errors, maybe just print .localizedDescription and return
        guard let services = peripheral.services else {return}
        
        for service in services {
            print("BTH: service \(service.uuid.uuidString) \(service)")
            if service.uuid == SerialBTDevice.serialDataServiceCBUUID {
                peripheral.discoverCharacteristics([SerialBTDevice.readDataPortCharacteristicCBUUID,
                                                    SerialBTDevice.writeDataPortCharacteristicCBUUID], for: service)

            } else if service.uuid == SerialBTDevice.deviceInformationServiceCBUUID {
                peripheral.discoverCharacteristics([SerialBTDevice.mfgrNameCharacteristicCBUUID,
                                                    SerialBTDevice.modelNumberCharacteristicCBUUID,
                                                    SerialBTDevice.serialNumberCharacteristicCBUUID,
                                                    SerialBTDevice.hardwareRevCharacteristicCBUUID,
                                                    SerialBTDevice.firmwareRevCharacteristicCBUUID,
                                                    SerialBTDevice.softwareRevCharacteristicCBUUID,
                                                    SerialBTDevice.systemIDCharacteristicCBUUID,
                                                    SerialBTDevice.pnpIDCharacteristicCBUUID,
                                                    SerialBTDevice.medicalDevUDICharacteristicCBUUID], for: service)
            }
        }
        
        renewStallTimer(for: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        // TODO:  handle errors
        guard let characteristics = service.characteristics else {return}
        
        print("BTH: Characteristics for \(service.uuid.uuidString) \(service.uuid)")
        for characteristic in characteristics {
            //      print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains((.write)) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .write")
            }
            if characteristic.properties.contains((.writeWithoutResponse)) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .writeWithoutResponse")
            }
            if characteristic.properties.contains((.broadcast)) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .broadcast")
            }
            if characteristic.properties.contains((.indicate)) {
                print("\(characteristic.uuid.uuidString) \(characteristic.uuid.description): properties contains .indicate")
            }
        }
        renewStallTimer(for: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        // TODO: handle errors
        // it should be a Known device to get here, because connecting should have moved it to Known
        guard let index = index(withUUID: peripheral.identifier)
        else {
            print("BTH: No matching device to receive value updates")
            return
        }
        if let value =  characteristic.value  {
            switch characteristic.uuid {
            case SerialBTDevice.mfgrNameCharacteristicCBUUID:
                print("got manufacturer name")
                availableBTDevices[index].setDeviceInfo(for: .ManufacturerName, to: value)
            case SerialBTDevice.modelNumberCharacteristicCBUUID:
                print("got model number")
                availableBTDevices[index].setDeviceInfo(for: .ModelNumber, to: value)
            case SerialBTDevice.serialNumberCharacteristicCBUUID:
                print("got serial number")
                availableBTDevices[index].setDeviceInfo(for: .SerialNumber, to: value)
            case SerialBTDevice.hardwareRevCharacteristicCBUUID:
                print("got hardware revision")
                availableBTDevices[index].setDeviceInfo(for: .HardwareRev, to: value)
            case SerialBTDevice.firmwareRevCharacteristicCBUUID:
                print("got firmware revision")
                availableBTDevices[index].setDeviceInfo(for: .FirmwareRev, to: value)
            case SerialBTDevice.softwareRevCharacteristicCBUUID:
                print("got software revision")
                availableBTDevices[index].setDeviceInfo(for: .SoftwareRev, to: value)
            case SerialBTDevice.systemIDCharacteristicCBUUID:
                print("got systemID")
                availableBTDevices[index].setDeviceInfo(for: .SystemID, to: value)
            case SerialBTDevice.pnpIDCharacteristicCBUUID:
                print("got pnpID")
                availableBTDevices[index].setDeviceInfo(for: .PnPID, to: value)
            case SerialBTDevice.medicalDevUDICharacteristicCBUUID:
                print("got medical device UID")
                availableBTDevices[index].setDeviceInfo(for: .MedicalDeviceUDI, to: value)
            case SerialBTDevice.readDataPortCharacteristicCBUUID:
                availableBTDevices[index].processPacket(characteristic.value)
            default:
                print("BTH: Haven't handled \(characteristic.uuid.uuidString) yet.")
            }
        }

        renewStallTimer(for: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Closed \(invalidatedServices.count) services. ")
        for service in invalidatedServices {
            print(service.description)
        }
        if let services = peripheral.services {
            if services.count == 0,
               let _ = index(withUUID: peripheral.identifier) {
                print("trying to reconnect")
                peripheral.discoverServices([SerialBTDevice.serialDataServiceCBUUID])
            }
            print("\(peripheral.services?.count ?? 0) known services")
            for service in services {
                print(service.description)
            }
        }
        print("peripheral state is \(peripheral.state.description)")
        renewStallTimer(for: peripheral)
    }

}

extension CBPeripheralState {
    var description : String {
        switch self {
        case .connected: "Connected"
        case .connecting: "Connecting"
        case .disconnected: "Disconnected"
        case .disconnecting: "Disconnecting"
        default: "Future Unknown"
        }
    }
}

extension CBManagerState {
    var description : String {
        switch self {
        case .poweredOn: "Powered On"
        case .poweredOff: "Powered Off"
        case .resetting: "Resetting"
        case .unauthorized: "Unauthorized"
        case .unknown: "Unknown"
        case .unsupported: "Unsuported"
        default: "Future Unknown"
        }
    }
}

