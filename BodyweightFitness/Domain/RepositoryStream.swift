import Foundation
import RealmSwift

final class RepositoryStream {
    static let sharedInstance = RepositoryStream()

    private init() {}
    
    func getRealm() -> Realm {
        let realm = try! Realm()
        
        return realm
    }

    func getNumberOfWorkouts() -> Int {
        return getRealm().objects(RepositoryRoutine.self).count
    }

    func getNumberOfWorkouts(_ days: Int) -> Int {
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", Date.changeDaysBy(days) as CVarArg, Date() as CVarArg)

        return getRealm()
            .objects(RepositoryRoutine.self)
            .filter(predicate)
            .count
    }

    func getLastWorkout() -> RepositoryRoutine? {
        let date = Calendar.current.startOfDay(for: Date())
        let predicate = NSPredicate(format: "startTime < %@", date as CVarArg)

        return getRealm()
            .objects(RepositoryRoutine.self)
            .filter(predicate)
            .last
    }

    func repositoryRoutineForTodayExists() -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options(rawValue: 0))
      
        if let _ = getRealm()
            .objects(RepositoryRoutine.self)
            .filter(NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay as CVarArg, endOfDay! as CVarArg))
            .filter(NSPredicate(format: "routineId == %@", RoutineStream.sharedInstance.routine.routineId))
            .first {
            return true
        } else {
            return false
        }
    }
    
    func getRepositoryRoutineForToday() -> RepositoryRoutine {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options(rawValue: 0))

        if let firstRoutine = getRealm()
            .objects(RepositoryRoutine.self)
            .filter(NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay as CVarArg, endOfDay! as CVarArg))
            .filter(NSPredicate(format: "routineId == %@", RoutineStream.sharedInstance.routine.routineId))
            .first {
                return firstRoutine
        } else {
            return buildRoutine(RoutineStream.sharedInstance.routine)
        }
    }
    
    func getRoutinesForDate(_ date: Date) -> Results<RepositoryRoutine> {
        let startOfDay = NSCalendar.current.startOfDay(for: date)
        
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.current.date(byAdding: components, to: startOfDay)

        let predicate = NSPredicate(
            format: "startTime > %@ AND startTime < %@",
            startOfDay as CVarArg,
            endOfDay! as CVarArg
        )
        
        return getRealm().objects(RepositoryRoutine.self).filter(predicate)
    }
    
    func buildRoutine(_ routine: Routine) -> RepositoryRoutine {
        let repositoryRoutine = RepositoryRoutine()
        
        repositoryRoutine.routineId = routine.routineId
        repositoryRoutine.title = routine.title
        repositoryRoutine.subtitle = routine.subtitle
        repositoryRoutine.startTime = Date()
        repositoryRoutine.lastUpdatedTime = Date()
        
        var repositoryCategory: RepositoryCategory?
        var repositorySection: RepositorySection?
        
        for exercise in routine.exercises {
            if let exercise = exercise as? Exercise {
                
                let repositoryExercise = RepositoryExercise()
                repositoryExercise.exerciseId = exercise.exerciseId
                repositoryExercise.title = exercise.title
                repositoryExercise.desc = exercise.desc
                repositoryExercise.defaultSet = exercise.defaultSet
                
                let repositorySet = RepositorySet()
                repositorySet.exercise = repositoryExercise
                
                if(repositoryExercise.defaultSet == "weighted") {
                    repositorySet.isTimed = false
                } else {
                    repositorySet.isTimed = true
                }
                
                repositoryExercise.sets.append(repositorySet)
                
                if((repositoryCategory == nil) || !(repositoryCategory?.categoryId == exercise.category?.categoryId)) {
                    let category = exercise.category!
                    
                    repositoryCategory = RepositoryCategory()
                    repositoryCategory?.categoryId = category.categoryId
                    repositoryCategory?.title = category.title
                    repositoryCategory?.routine = repositoryRoutine
                    
                    repositoryRoutine.categories.append(repositoryCategory!)
                }
                
                if((repositorySection == nil) || !(repositorySection?.sectionId == exercise.section?.sectionId)) {
                    let section = exercise.section!
                    
                    repositorySection = RepositorySection()
                    repositorySection?.sectionId = section.sectionId
                    repositorySection?.title = section.title
                    
                    if (section.mode == SectionMode.all) {
                        repositorySection?.mode = "all"
                    } else if (section.mode == SectionMode.pick) {
                        repositorySection?.mode = "pick"
                    } else {
                        repositorySection?.mode = "levels"
                    }
                    
                    repositorySection?.routine = repositoryRoutine
                    repositorySection?.category = repositoryCategory!
                    
                    repositoryRoutine.sections.append(repositorySection!)
                    repositoryCategory?.sections.append(repositorySection!)
                }
                
                repositoryExercise.routine = repositoryRoutine
                repositoryExercise.category = repositoryCategory!
                repositoryExercise.section = repositorySection!
                
                if(exercise.section?.mode == SectionMode.all) {
                    repositoryExercise.visible = true
                } else {
                    if let currentExercise = exercise.section?.currentExercise {
                        if exercise === currentExercise {
                            repositoryExercise.visible = true
                        } else {
                            repositoryExercise.visible = false
                        }
                    } else {
                        repositoryExercise.visible = false
                    }
                }
                
                repositoryRoutine.exercises.append(repositoryExercise)
                repositoryCategory?.exercises.append(repositoryExercise)
                repositorySection?.exercises.append(repositoryExercise)
            }
        }
        
        return repositoryRoutine
    }
}
















