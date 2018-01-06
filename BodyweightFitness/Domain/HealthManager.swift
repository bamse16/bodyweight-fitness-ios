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
}
