//
//  Beam.swift
//  Beam
//
//  Created by Elias Abel on 03/11/16.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//

import Foundation

public class EffectStorage {

    fileprivate var buses = [AnyObject]()
    fileprivate let instanceMutex = Mutex()

    public static let `default` = EffectStorage()

    public init() {}
}

public class Beam<EventType: BaseEvent> {

    internal var listeners = LinkedList<Listener<EventType>>()
    public typealias ListenerClosure = (_ event: EventType) -> Void
    fileprivate var sticky: EventType?
    fileprivate let editListenersMutex = Mutex()
    fileprivate let stickyMutex = Mutex()

}

// MARK: public non sticky events interface
public extension Beam where EventType: Event {

    static func register(_ observer: AnyObject, in storage: EffectStorage = .default, onQueue queue: OperationQueue = .main, handler: @escaping ListenerClosure) {
        instance(in: storage).register(observer, onQueue: queue, handler: handler)
    }

    static func registerOnBackground(_ observer: AnyObject, in storage: EffectStorage = .default, handler: @escaping ListenerClosure) {
        register(observer, in: storage, onQueue: creteBackgroundQueue(for: observer), handler: handler)
    }

    static func post(_ event: EventType, in storage: EffectStorage = .default) {
        instance(in: storage).post(event)
    }

}

// MARK: public sticky events interface
public extension Beam where EventType: StickyEvent {

    static func register(_ observer: AnyObject, in storage: EffectStorage = .default, onQueue queue: OperationQueue = .main, handler: @escaping ListenerClosure) {
        instance(in: storage).register(observer, onQueue: queue, handler: handler)
    }

    static func registerOnBackground(_ observer: AnyObject, in storage: EffectStorage = .default, handler: @escaping ListenerClosure) {
        register(observer, in: storage, onQueue: creteBackgroundQueue(for: observer), handler: handler)
    }

    static func post(_ event: EventType, in storage: EffectStorage = .default) {
        instance(in: storage).post(event)
    }

    static func sticky(in storage: EffectStorage = .default) -> EventType? {
        return instance(in: storage).sticky
    }

}

// MARK: public interface
public extension Beam {

    static func unregister(_ observer: AnyObject, in storage: EffectStorage = .default) {
        instance(in: storage).unregister(observer)
    }

}

// MARK: instantiation
internal extension Beam {

    static func instance(in storage: EffectStorage) -> Beam<EventType> {
        storage.instanceMutex.wait()
        defer { storage.instanceMutex.signal() }

        for case let bus as Beam<EventType> in storage.buses {
            return bus
        }

        let bus = Beam<EventType>()
        storage.buses.append(bus)
        return bus
    }
}

// MARK: private non sticky methods
fileprivate extension Beam where EventType: Event {

    func register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: @escaping ListenerClosure) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }

        let listener = Listener<EventType>(observer, queue, handler)
        listeners.append(listener)
    }

    func post(_ event: EventType) {
        postToAll(event)
    }

}

// MARK: private sticky methods
fileprivate extension Beam where EventType: StickyEvent {

    func register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: @escaping ListenerClosure) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }

        let listener = Listener<EventType>(observer, queue, handler)
        listeners.append(listener)
        guard let sticky = sticky else { return }
        listener.queue.addOperation { [weak listener] in
            listener?.post(sticky, async: false)
        }
    }

    func post(_ event: EventType) {
        stickyMutex.wait()
        defer { stickyMutex.signal() }
        sticky = event
        postToAll(event)
    }

}

// MARK: private helpers
fileprivate extension Beam {

    static func creteBackgroundQueue(for observer: AnyObject) -> OperationQueue {
        let queue = OperationQueue()
        queue.name = "com.sixt.Beam " + String(describing: EventType.self) + String(describing: observer)
        return queue
    }

    func postToAll(_ event: EventType) {
        listeners.forEach { $0.post(event, async: self.editListenersMutex.value <= 0) }
    }

    func unregister(_ observer: AnyObject) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(observer).toOpaque())
        listeners.filter { $0.observerPointer != pointer }
    }

}


