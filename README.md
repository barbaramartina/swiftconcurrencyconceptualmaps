# Swift Concurrency Documentation
I have created this repository to share with other developers some documentation and conceptual maps I have created.

## Summary of Swift Concurrency related proposals
### Until January 2025
This is a summary of the Swift proposals related to Swift Concurrency, since 2021 to January 2025. 

They are grouped by Swift version. Also there is color-coding.
For example: all greens are related to actors... all dark greens are distributed actors.
The ones without color, I could not group them to any of the main topics, they are more general proposals.

<img width="762" alt="Screenshot 2025-01-14 at 8 55 17 PM" src="https://github.com/user-attachments/assets/9ba6894b-4c4e-42d3-baf4-10ce37205d99" />

# async / await / async let / ObjC interoperability
<img width="759" alt="Screenshot 2025-01-14 at 8 55 08 PM" src="https://github.com/user-attachments/assets/f72f6d4d-87b5-4368-bbc5-e5289d611b36" />
<img width="691" alt="Screenshot 2025-01-14 at 7 58 27 PM" src="https://github.com/user-attachments/assets/5d853561-a2b5-47f1-96ad-6e9c7f2cdde9" />

<img width="759" alt="Screenshot 2025-01-14 at 8 54 59 PM" src="https://github.com/user-attachments/assets/d5314bdf-a044-4b29-ab56-c37de027ccb3" />
<img width="1275" alt="Screenshot 2025-01-14 at 8 54 47 PM" src="https://github.com/user-attachments/assets/a9423bb6-8487-403e-88db-f2504182054b" />

## Closures plus async/await
<img width="751" alt="Screenshot 2025-01-18 at 7 28 48 PM" src="https://github.com/user-attachments/assets/673b5380-d32c-4eb5-92c7-360f8435ed08" />

# Async Sequences
<img width="1006" alt="Screenshot 2025-01-18 at 7 29 34 PM" src="https://github.com/user-attachments/assets/fd42c64e-78af-4966-8d8b-a661b960ed47" />

# Async streams
<img width="1009" alt="Screenshot 2025-01-18 at 7 29 43 PM" src="https://github.com/user-attachments/assets/ce2a3fac-cf64-451b-bd0d-98a1fc05369a" />

## Async streams and view controllers
<img width="1013" alt="Screenshot 2025-01-18 at 7 29 53 PM" src="https://github.com/user-attachments/assets/1a326748-a8f1-482f-8ddd-f7d7c3fedc14" />

```swift
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
            // some very long calculation
        }
        aTaskReference = Task {
            for await value in aWorker.getAsyncStream() {
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
```

# Structured Concurrency
<img width="1108" alt="Screenshot 2025-01-25 at 8 06 57 PM" src="https://github.com/user-attachments/assets/b894e19d-8ef6-47de-9f27-e78d3b8c5796" />

## Task's states
<img width="1104" alt="Screenshot 2025-01-25 at 8 08 37 PM" src="https://github.com/user-attachments/assets/ca120fbe-4b8c-4f22-a0e7-a1aa2dbf7645" />

## Task's structure
<img width="1100" alt="Screenshot 2025-01-25 at 8 08 46 PM" src="https://github.com/user-attachments/assets/222b71b1-8c67-47d4-9e6d-a31734d25977" />

## Task and child taks
<img width="1107" alt="Screenshot 2025-01-25 at 8 08 53 PM" src="https://github.com/user-attachments/assets/14007ebb-a1d8-4e87-ab3a-065c7e53ad56" />

## Tasks and jobs
<img width="1100" alt="Screenshot 2025-01-25 at 8 09 00 PM" src="https://github.com/user-attachments/assets/621a407a-2bc6-4275-8c48-7fe58f2c9ea9" />

# Executors
<img width="1098" alt="Screenshot 2025-01-25 at 8 09 08 PM" src="https://github.com/user-attachments/assets/8ea71f70-6da2-48c6-ab90-46249c1fbc03" />

## Executors and priority
<img width="1101" alt="Screenshot 2025-01-25 at 8 09 15 PM" src="https://github.com/user-attachments/assets/eb15e27f-ff62-4365-a750-4b5eb93f5e8f" />

## Task and main
<img width="1106" alt="Screenshot 2025-01-25 at 8 09 22 PM" src="https://github.com/user-attachments/assets/e9cbb0c5-dd82-4282-b56a-e15146eb0621" />

## Task and cancellation
<img width="1111" alt="Screenshot 2025-01-25 at 8 09 30 PM" src="https://github.com/user-attachments/assets/c159c4a8-7f94-476e-ac40-892cdc15f876" />

## Unstructure Task
<img width="1109" alt="Screenshot 2025-01-25 at 8 09 37 PM" src="https://github.com/user-attachments/assets/daed6b88-b18c-4bb5-9067-a0ebe89b120a" />

## TaskGroups and discardable task groups
<img width="441" alt="Screenshot 2025-01-25 at 8 09 52 PM" src="https://github.com/user-attachments/assets/c4cb9ab6-c034-4711-86ce-63289e431fc2" />

# Where do async functions run?
<img width="1110" alt="Screenshot 2025-01-25 at 8 06 42 PM" src="https://github.com/user-attachments/assets/7ae65025-3a8f-47db-9bf7-7003f9dd866a" />

# Task executor preference
<img width="884" alt="Screenshot 2025-01-27 at 2 37 48 PM" src="https://github.com/user-attachments/assets/2484fea8-338a-4b50-940d-c45fb4de4bf1" />

<img width="871" alt="Screenshot 2025-01-27 at 2 37 59 PM" src="https://github.com/user-attachments/assets/c6d1aaef-a99f-401a-ba92-936ab9aac073" />

# Actor context inheritance
<img width="880" alt="Screenshot 2025-01-27 at 2 38 08 PM" src="https://github.com/user-attachments/assets/60fa4aa0-6926-48a8-929c-975c04feb1ac" />


# List of readings I recommend
While working on these conceptual maps and summaries, I based them in the following Swift Proposals and Apple Documentation:

- https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/
- https://developer.apple.com/documentation/swift/sendable
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0316-global-actors.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0313-actor-isolation-control.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0392-custom-actor-executors.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0423-dynamic-actor-isolation.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0337-support-incremental-migration-to-concurrency-checking.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0282-atomics.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0296-async-await.md
- https://www.swift.org/migration/documentation/migrationguide/
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0313-actor-isolation-control.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0327-actor-initializers.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0336-distributed-actor-isolation.md
- https://github.com/ktoso/swift-evolution/blob/distributed-revised/proposals/nnnn-distributed-actors.md#distributed-actors
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0337-support-incremental-migration-to-concurrency-checking.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0343-top-level-concurrency.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0381-task-group-discard-results.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0388-async-stream-factory.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0418-inferring-sendable-for-methods.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0420-inheritance-of-actor-isolation.md
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md

