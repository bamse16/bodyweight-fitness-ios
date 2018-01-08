//
//  HealthManager.swift
//  BodyweightFitness
//
//  Created by Marius Ursache on 6/1/18.
//  Copyright © 2018 Damian Mazurkiewicz. All rights reserved.
//

import HealthKit

class HealthManager {

    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    class func healthKitIsAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HealthManager.healthKitIsAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }

        let healthKitTypesToWrite: Set<HKSampleType> = [HKObjectType.workoutType()]
        let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }

struct HealthKitWorkout {
    var start: Date
    var end: Date
    var routineId: String

    var duration: TimeInterval {
        let defaultDuration: TimeInterval = 60 // one minute
        var currentDuration = self.end.timeIntervalSince(self.start)
        if defaultDuration > currentDuration {
            currentDuration = defaultDuration
        }

        return currentDuration
    }

    var totalEnergyBurned: Double {
        let caloriesPerHour = ExternalRoutineMap.calories(routineId: self.routineId)
        let hours = self.duration / 3600

        let totalCalories = caloriesPerHour * hours
        return totalCalories
    }

    init(repositoryRoutine: RepositoryRoutine) {
        self.start = repositoryRoutine.startTime
        self.end = repositoryRoutine.lastUpdatedTime
        self.routineId = repositoryRoutine.routineId
    }
}
