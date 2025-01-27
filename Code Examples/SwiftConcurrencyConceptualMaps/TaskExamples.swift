import Foundation

// MARK: - Very basic models just to use as examples

protocol Ingredient {}

struct Meal {}

struct Vegetable: Ingredient {
    func chopped() async throws -> Vegetable {
        try? await Task.sleep(for: .seconds(0.3))
        // if this task would be long, we need to check for cancellations
        try Task.checkCancellation()
        // you can also check directly for isCancelled,
        // if you are not in a throwing function for example
        if Task.isCancelled { return  Vegetable() }
        // if it is still not cancelled, we can continue
        return self
    }
}

struct Meat: Ingredient {}

struct Oven {
    func cook(_ dish: Dish, duration: Duration) async throws -> Meal {
        Meal()
    }
}

struct Dish {
    let ingredients: [Ingredient]
    
    init(ingredients: [Ingredient]) {
        self.ingredients = ingredients
    }
}

// MARK: - Example of async function

func makeDinner() async throws -> Meal {
    // Prepare some variables to receive results from our concurrent child tasks
    var veggies: [Ingredient] = []
    var meat: Ingredient = Meat()
    var oven: Oven?
    
    enum CookingStep {
        case veggies([Vegetable])
        case meat(Meat)
        case oven(Oven)
    }
    
    // Create a task group to scope the lifetime of our three child tasks
    try await withThrowingTaskGroup(of: CookingStep.self) { group in
        group.addTask {
            try await .veggies(chopVegetables())
        }
        group.addTask {
            try await .meat(marinateMeat())
        }
        group.addTask {
            try await .oven(preheatOven(temperature: 350))
        }
        
        for try await finishedStep in group {
            switch finishedStep {
            case .veggies(let v): veggies = v
            case .meat(let m): meat = m
            case .oven(let o): oven = o
            }
        }
    }
    
    // If execution resumes normally after `withTaskGroup`, then we can assume
    // that all child tasks added to the group completed successfully. That means
    // we can confidently force-unwrap the variables containing the child task
    // results here.
    let dish = Dish(ingredients: veggies + [meat])
    return try await oven!.cook(dish, duration: .seconds(3))
    
}

// MARK: - Version of chop, which does not have concurrency

private func chopVegetables() async throws -> [Vegetable] {
    try? await Task.sleep(for: .seconds(0.3))
    return [Vegetable(), Vegetable()]
}

// MARK: - Version of chop with concurrency


private func chopVegetablesConcurrent() async throws -> [Vegetable] {
    // Create a task group where each child task produces a Vegetable.
    try await withThrowingTaskGroup(of: Vegetable.self) { group in
        let rawVeggies: [Vegetable] = [Vegetable(), Vegetable()]
        var choppedVeggies: [Vegetable] = []
        
        // Create a new child task for each vegetable that needs to be chopped.
        for v in rawVeggies {
            group.addTask {
                try await v.chopped()
            }
        }
        
        // Wait for all of the chopping to complete, collecting the veggies into
        // the result array in whatever order they're ready.
        while let choppedVeggie = try await group.next() {
            choppedVeggies.append(choppedVeggie)
        }
        
        return choppedVeggies
    }
}

// MARK: - Marinate

private func marinateMeat() async throws -> Meat {
    try? await Task.sleep(for: .seconds(0.3))
    return Meat()
}

// MARK: - Preheat Oven

private func preheatOven(temperature: Double) async throws -> Oven {
    try? await Task.sleep(for: .seconds(0.3))
    return Oven()
}

// MARK: - Cancellation examples

func chopVegetablesCancellation() async throws -> [Vegetable] {
    return try await withThrowingTaskGroup(of: Vegetable.self) { group in
        var veggies: [Vegetable] = []
        
        group.addTask {
            try await Vegetable().chopped() // (1) let's assume it throws UnfortunateAccidentWithKnifeError()
            // Suppose that this call to the chop function throws an error.
            // Because this is asynchronous, that error is not immediately observed in chopVegetables,
            // and we proceed to start a second child task
        }
        group.addTask {
            try await Vegetable().chopped() // (2)
        }
        
        for try await veggie in group { // (3)
            veggies.append(veggie)
            // Since we do not handle this error, we exit the scope without having yet awaited the
            // (2) chopping task. This causes that task to be automatically cancelled.
            // Because cancellation is cooperative, and because structured concurrency does not allow child
            // tasks to outlast their parent context, control does not actually return until the
            // (2))-chopping task actually completes; any value it returns or throws will be discarded.
        }
        
        return veggies
    }
}
