//
//  Example-ViewController+Task.swift
//  SwiftConcurrencyConceptualMaps
//
//  Created by Barbara Personal on 2025-01-24.
//
import UIKit

class AViewController: UIViewController {
    
    /// keep a reference if the task is super long
    /// if the task finished quickly, is not a big problem
    /// it will cancel itself when done
    /// AsyncStream -> ALWAYS cancel them
    private var loadingTask: Task<Void, Never>?
    /// just a worker to exemplify an async stream creation
    private var aWorker = AWorker()
    /// keep a reference to the task used to call the async stream... so you can cancel it
    /// when the view controller deinit - make sure not to make any reference cycle inside that task
    private var aTaskReference: Task<Void, Never>?
    
    deinit {
        loadingTask?.cancel()
        aTaskReference?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // example for a normal Task (without AsyncStream inside)
        loadingTask = Task {
            // some very long calculation here....
            // or if you need to react immediately to
            // the cancellation, create a
            // task with cancellation handler
            await withTaskCancellationHandler {
                // some long processing here
            } onCancel: {
                // do some cleanup
            }
        }
        
        aTaskReference = Task {
            for await _ in aWorker.getAsyncStream() {
                // do something with the value
            }
        }
    }
}

class AWorker {
    
    func getAsyncStream() -> AsyncStream<Int> {
        AsyncStream<Int>(unfolding: {
            // please never use while true :D ... this is only for
            // faking a forever running task
            while true {
                try? await Task.sleep(nanoseconds: 1000)
                return Int.random(in: 0...500)
            }
        })
    }
}

class AnyClass {
    
    func doSomething() {}
    
    func aFunction() {
        
        Task { [weak self] in
            // self is still strongly captured
            guard let self = self else { return }
            // long running code
            print(self)
        }
        
        Task { [weak self] in
            // USE ALWAYS THE WEAK SELF IN THE WHOLE CLOSURE
            self?.doSomething()
            // long running code
        }
    }
    
}
