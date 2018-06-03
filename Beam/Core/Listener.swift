//
//  Listener.swift
//  Beam
//
//  Created by Meniny on 2018-06-03.
//

import Foundation

// MARK: subscriber holder
internal class Listener<EventType: BaseEvent> {
    
    typealias ListenerClosure = Beam<EventType>.ListenerClosure
    weak var observer: AnyObject?
    let observerPointer: UnsafeRawPointer
    let queue: OperationQueue
    let handler: ListenerClosure
    let eventClassName: String
    
    init(_ observer: AnyObject, _ queue: OperationQueue, _ handler: @escaping ListenerClosure) {
        self.observer = observer
        self.observerPointer = UnsafeRawPointer(Unmanaged.passUnretained(observer).toOpaque())
        self.handler = handler
        self.queue = queue
        self.eventClassName = String(describing: observer)
    }
    
    func post(_ event: EventType, async: Bool) {
        guard let _ = observer else {
            assertionFailure("One of the observers did not unregister, but already dealocated, observer info: " + eventClassName)
            return
        }
        
        if !async && OperationQueue.current == queue {
            handler(event)
        } else {
            queue.addOperation { [weak self] in
                self?.handler(event)
            }
        }
    }
    
}
