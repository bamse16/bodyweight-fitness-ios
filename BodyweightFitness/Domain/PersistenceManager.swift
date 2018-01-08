import Foundation

public extension String {
    var NS: NSString { return (self as NSString) }
}

class UserDefaults {
    func showRestTimer() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "showRestTimer")
    }
    
    func showRestTimerAfterWarmup() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "showRestTimerAfterWarmup")
    }
    
    func showRestTimerAfterBodylineDrills() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "showRestTimerAfterBodylineDrills")
    }
    
    func showRestTimerAfterFlexibilityExercises() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "showRestTimerAfterFlexibilityExercises")
    }
}

class PersistenceManager {
    class func getWeightUnit() -> String {
        let fileManager = FileManager.default
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("weightUnit.archive")
        
        if(fileManager.fileExists(atPath: dataFilePath)) {
            if let weightUnit = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath) as? String {
                return weightUnit
            }
        }
        
        return "kg"
    }
    
    class func setWeightUnit(_ weightUnit: String) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("weightUnit.archive")
        
        NSKeyedArchiver.archiveRootObject(weightUnit, toFile: dataFilePath)
    }
    
    class func getRestTime() -> Int {
        let fileManager = FileManager.default
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("restTime.archive")
        
        if(fileManager.fileExists(atPath: dataFilePath)) {
            if let restTime = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath) as? Int {
                return restTime
            }
        }
        
        return 60
    }
    
    class func setRestTime(_ restTime: Int) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("restTime.archive")
        
        NSKeyedArchiver.archiveRootObject(restTime, toFile: dataFilePath)
    }
    
    class func getNumberOfReps(_ id: String) -> Int {
        let fileManager = FileManager.default
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("reps.\(id).archive")
        
        if(fileManager.fileExists(atPath: dataFilePath)) {
            if let seconds = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath) as? Int {
                return seconds
            }
        }
        
        return 5
    }
    
    class func storeNumberOfReps(_ id: String, numberOfReps: Int) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("reps.\(id).archive")
        
        NSKeyedArchiver.archiveRootObject(numberOfReps, toFile: dataFilePath)
    }
    
    class func getTimer(_ id: String) -> Int {
        let fileManager = FileManager.default
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("timer.\(id).archive")
        
        if(fileManager.fileExists(atPath: dataFilePath)) {
            if let seconds = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath) as? Int {
                return seconds
            }
        }
        
        return 60
    }
    
    class func storeTimer(_ id: String, seconds: Int) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPath[0] 
        let dataFilePath = documentsDirectory.NS.appendingPathComponent("timer.\(id).archive")
        
        NSKeyedArchiver.archiveRootObject(seconds, toFile: dataFilePath)
    }
    
    class func getRoutine(_ routineId: String) -> Routine {
        let fileManager = FileManager.default
        let directoryPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)
        
        var fileName = ""
        var id = ""
        
        if (routineId == ExternalRoutineMap.BodyweightFitness.id) {
            fileName = ExternalRoutineMap.BodyweightFitness.fileName
            id = "routine"
        } else if (routineId == ExternalRoutineMap.StartingStretching.id) {
            fileName = ExternalRoutineMap.StartingStretching.fileName
            id = ExternalRoutineMap.StartingStretching.id
        } else {
            fileName = ExternalRoutineMap.MoldingMobility.fileName
            id = ExternalRoutineMap.MoldingMobility.id
        }
        
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent(id + ".archive")
        
        if(fileManager.fileExists(atPath: dataFilePath)) {
            if let currentExercises = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath) as? Dictionary<String, String> {
                return Routine(fileName: fileName, dictionary: currentExercises)
            }
        }
        
        return Routine(fileName: fileName)
    }
    
    class func storeRoutine(_ routine: Routine) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)
        
        var id = ""
        
        if (routine.routineId == ExternalRoutineMap.BodyweightFitness.id) {
            id = "routine"
        } else {
            id = routine.routineId
        }
        
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.appendingPathComponent(id + ".archive")
        
        var currentExercises = Dictionary<String, String>()
        for anySection in routine.sections {
            if let section = anySection as? Section {
                if(section.mode == SectionMode.pick || section.mode == SectionMode.levels) {
                    currentExercises[section.sectionId] = section.currentExercise?.exerciseId
                }
            }
        }
        
        NSKeyedArchiver.archiveRootObject(currentExercises, toFile: dataFilePath)
    }
}
