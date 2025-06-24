//
//  HealthKitManager.swift
//  Prototype
//
//  Created by Dhruv Suhird on 5/25/25.
//


import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        let typesToShare: Set = [
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.quantityType(forIdentifier: .dietarySugar)!,
            HKObjectType.quantityType(forIdentifier: .dietarySodium)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCalcium)!
        ]
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToShare) { success, _ in
            completion(success)
        }
    }
}
