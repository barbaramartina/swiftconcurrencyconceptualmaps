//
//  IsolationExamples.swift
//  SwiftConcurrencyConceptualMaps
//
//  Created by Barbara Personal on 2025-01-25.
//

import Foundation

// An actor
actor Course {
    // with 2 actor-isolated propertie
    var name = "Maths"
    var studentNames = [String]()
}

// another function with a parameter
// marked as 'isolated'
func debugLogWithActorContextInheritance(course: isolated Course) {
    // it is possible to access actor-
    // isolated parameters
    print("Name: \(course.name)")
    print("Students: \(course.studentNames)")
}

// another function with no parameter
// marked as 'isolated'
func debugLog(course: Course) {
    // it is possible to access actor-
    // isolated parameters
    print("Name: \(course.name)")
    print("Students: \(course.studentNames)")
}

func exampleContextInheritance() {
    Task {
        let course = Course()
        // but now we need to use await even
        // if debugLog is not async
        debugLogWithActorContextInheritance(course: course)
    }
}

