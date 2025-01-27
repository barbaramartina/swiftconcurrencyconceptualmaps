//
//  TaskExecutorPreference.swift
//  SwiftConcurrencyConceptualMaps
//
//  Created by Barbara Personal on 2025-01-27.
//

import Foundation

// EXAMPLES FROM PROPOSAL SE-0417

/// A simple example of a task executor with a serial queue
final class QueueTaskExecutor: TaskExecutor, SerialExecutor {
    let queue: DispatchQueue = DispatchQueue(label: "an.example.queue")
    
    func enqueue(_ _job: consuming ExecutorJob) {
        let job = UnownedJob(_job)
        queue.async { [self] in
            job.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                 taskExecutor: asUnownedTaskExecutor())
        }
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
    
    func asUnownedTaskExecutor() -> UnownedTaskExecutor {
        UnownedTaskExecutor(ordinary: self)
    }
}

let executor = QueueTaskExecutor()

func taskExamples() async {
    // the global concurrent executor can be accessed like this
    // and can be used a preference, to 'deactivate' any ihnerited
    // previously set preference
    print(globalConcurrentExecutor)
    
    Task(executorPreference: executor) {
        // starts and runs on the 'executor'
        await nonisolatedAsyncFunc()
    }
    
    
    Task.detached(executorPreference: executor) {
        // starts and runs on the 'executor'
        await nonisolatedAsyncFunc()
    }
    
    await withDiscardingTaskGroup { group in
        group.addTask(executorPreference: executor) {
            // starts and runs on the 'executor'
            _ = await nonisolatedAsyncFunc()
        }
    }
}

func nonisolatedAsyncFunc() async -> Int {
    // if the Task has a specific executor preference,
    // runs on that 'executor' rather than on the default global concurrent executor
    return 42
}
