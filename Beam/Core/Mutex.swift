//
//  Mutex.swift
//  Beam
//
//  Created by Meniny on 2018-06-03.
//

import Foundation

internal class Mutex {
    var value = 1
    let semaphore = DispatchSemaphore(value: 1)
    
    func wait() {
        value -= 1
        semaphore.wait()
    }
    
    func signal() {
        value += 1
        semaphore.signal()
    }
    
    var isMuted: Bool { return value > 0 }
}
