//
//  SocketDataManager.swift
//  OnStep Controller
//
//  Created by Satnam on 7/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import Foundation

class SocketDataManager: NSObject, StreamDelegate {
    
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var messages = [AnyHashable]()
    weak var uiPresenter :PresenterProtocol!
    
    init(with presenter:PresenterProtocol){
        
        self.uiPresenter = presenter
    }
    
    func connectWith(socket: DataSocket) {

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (socket.ipAddress! as CFString), UInt32(socket.port), &readStream, &writeStream)
        messages = [AnyHashable]()
        open()

        // Timeout the input stream if unresponsive
        let future = Date(timeIntervalSinceNow: TimeInterval(2))
        Thread.sleep(until: future)
        
        if inputStream?.streamStatus != .open {
            print("connect timout!!")
            close()
        } else {
        }
        
    }
    
    func disconnect(){
        
        close()
    }
    
    func open() {
        print("Opening streams.")
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        outputStream?.delegate = self
        inputStream?.delegate = self
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.open()
        inputStream?.open()
    }
    
    func close() {
        print("Closing streams.")
        uiPresenter?.resetUIWithConnection(status: false)
        inputStream?.close()
        outputStream?.close()
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream = nil
        outputStream = nil
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("stream event \(eventCode)")
        switch eventCode {
        case .openCompleted:
            uiPresenter?.resetUIWithConnection(status: true)
            print("Stream opened")
        case .hasBytesAvailable:
            if aStream == inputStream {
                var dataBuffer = Array<UInt8>(repeating: 0, count: 1)
                var len: Int
                while (inputStream?.hasBytesAvailable)! {
                    len = (inputStream?.read(&dataBuffer, maxLength: 1))!
                    if len > 0 {
                        let output = String(bytes: dataBuffer, encoding: .ascii)
                        if nil != output {
                            print("\(output ?? "")")
                            messageReceived(message: output!)
                        }
                    }
                }
            }
        case .hasSpaceAvailable:
            print("Stream has space available now")
        case .errorOccurred:
            print("\(aStream.streamError?.localizedDescription ?? "")")
        case .endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            print("close stream")
            uiPresenter?.resetUIWithConnection(status: false)
        default:
            print("Unknown event")
        }
    }
    
    func messageReceived(message: String){
        
        uiPresenter?.update(message: "\(message)")
        print(message)
    }
    
    func send(message: String){
        
        let response = "\(message)"
        let buff = [UInt8](message.utf8)
        if let _ = response.data(using: .ascii) {
            outputStream?.write(buff, maxLength: buff.count)
        }

    }

}
