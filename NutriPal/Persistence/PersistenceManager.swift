//
//  PersistenceManager.swift
//  Prototype
//
//  Created by Dhruv Suhird on 5/25/25.
//


import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let foodsKey = "LoggedFoods"
    private let profileKey = "UserProfile"
    private let macroGoalKey = "MacroGoal"
    private let unitPrefKey = "UnitPreference"
    
    func saveLoggedFoods(_ foods: [LoggedFood]) {
        let data = try? JSONEncoder().encode(foods)
        UserDefaults.standard.set(data, forKey: foodsKey)
    }
    
    func loadLoggedFoods() -> [LoggedFood] {
        guard let data = UserDefaults.standard.data(forKey: foodsKey),
            let foods = try? JSONDecoder().decode([LoggedFood].self, from: data) else {
            return []
        }
        return foods
    }
    
    
    func saveMacroGoal(_ goal: MacroGoal) {
        let data = try? JSONEncoder().encode(goal)
        UserDefaults.standard.set(data, forKey: macroGoalKey)
    }
    
    func loadMacroGoal() -> MacroGoal? {
        guard let data = UserDefaults.standard.data(forKey: macroGoalKey),
            let goal = try? JSONDecoder().decode(MacroGoal.self, from: data) else {
            return nil
        }
        return goal
    }
    
    func saveUnitPreference(_ unit: UnitPreference) {
        UserDefaults.standard.set(unit.rawValue, forKey: unitPrefKey)
    }
    
    func loadUnitPreference() -> UnitPreference? {
        guard let raw = UserDefaults.standard.string(forKey: unitPrefKey) else { return nil }
        return UnitPreference(rawValue: raw)
    }
}
