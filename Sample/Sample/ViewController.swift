//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-06-03.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import Beam

enum TestEvent: String, Event {
    case callback
}

typealias TestBeam = Beam<TestEvent>

class ViewController: UIViewController {

    var counter: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.78, green:0.25, blue:0.55, alpha:1.00)
        
        TestBeam.register(self) { (event) in
            self.counter += 1
            print("Event: ", event.rawValue, self.counter)
        }
        
        self.view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(go))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    deinit {
        TestBeam.unregister(self)
    }

    @objc
    func go() {
        let next = NextViewController.init(nibName: nil, bundle: nil)
        self.present(next, animated: true, completion: nil)
    }

}

class NextViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.02, green:0.43, blue:0.14, alpha:1.00)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(go))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func go() {
        TestBeam.post(.callback)
        self.dismiss(animated: true, completion: nil)
    }

}
