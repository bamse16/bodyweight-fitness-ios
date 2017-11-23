import Quick
import Nimble

@testable import Bodyweight_Fitness

class DomainTests: QuickSpec {
    override func spec() {
        describe("Repository Routine Companion") {
            it("initializes") {
                let repositoryRoutine = RepositoryRoutine()
                let companion = RepositoryRoutineCompanion(repositoryRoutine)
                
                expect(companion.repositoryRoutine).to(equal(repositoryRoutine))
            }
        }
        
        describe("Repository Category Companion") {
            context("numberOfExercises()") {
                it("does not count invisible exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = false

                    repositoryCategory.exercises.append(repositoryExercise)

                    expect(companion.numberOfExercises()).to(equal(0))
                }

                it("counts visible exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true

                    repositoryCategory.exercises.append(repositoryExercise)

                    expect(companion.numberOfExercises()).to(equal(1))
                }

                it("counts multiple visible exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = false

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)
                    repositoryCategory.exercises.append(thirdExercise)

                    expect(companion.numberOfExercises()).to(equal(2))
                }
            }

            context("numberOfCompletedExercises()") {
                it("does not count invisible exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = false
                    repositoryExercise.sets.append(repositorySet)

                    repositoryCategory.exercises.append(repositoryExercise)

                    expect(companion.numberOfCompletedExercises()).to(equal(0))
                }

                it("does not count incomplete exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true
                    repositoryExercise.sets.append(repositorySet)

                    repositoryCategory.exercises.append(repositoryExercise)

                    expect(companion.numberOfCompletedExercises()).to(equal(0))
                }

                it("counts visible and completed exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 10

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true
                    repositoryExercise.sets.append(repositorySet)

                    repositoryCategory.exercises.append(repositoryExercise)

                    expect(companion.numberOfCompletedExercises()).to(equal(1))
                }

                it("counts multiple visible and completed exercises") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 10

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)
                    repositoryCategory.exercises.append(thirdExercise)

                    expect(companion.numberOfCompletedExercises()).to(equal(2))
                }
            }

            context("getCompletionRate()") {
                it("should return 0% if number of exercises is 0") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(0))
                    expect(completionRate.label).to(equal("0%"))
                }

                it("should return 0% if number of completed exercises is 0") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(notCompletedSet)

                    repositoryCategory.exercises.append(firstExercise)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(0))
                    expect(completionRate.label).to(equal("0%"))
                }

                it("should return 50% if number of completed exercises is 1 out of 2") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(notCompletedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(50))
                    expect(completionRate.label).to(equal("50%"))
                }

                it("should return 100% if number of completed exercises is 2 out of 2") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(100))
                    expect(completionRate.label).to(equal("100%"))
                }

                it("should return 33% if number of completed exercises is 1 out of 3") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(notCompletedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)
                    repositoryCategory.exercises.append(thirdExercise)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(33))
                    expect(completionRate.label).to(equal("33%"))
                }

                it("should return 66% if number of completed exercises is 2 out of 3") {
                    let repositoryCategory = RepositoryCategory()
                    let companion = RepositoryCategoryCompanion(repositoryCategory)

                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    repositoryCategory.exercises.append(firstExercise)
                    repositoryCategory.exercises.append(secondExercise)
                    repositoryCategory.exercises.append(thirdExercise)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(66))
                    expect(completionRate.label).to(equal("66%"))
                }
            }
        }

        describe("Repository Exercise Companion") {
            context("isCompleted()") {
                it("is not completed when number of sets is 0") {
                    let repositoryExercise = RepositoryExercise()
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }
                
                it("is not completed when first set is timed and time is set to 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when multiple sets are timed and time is set to 0") {
                    let firstSet = RepositorySet()
                    firstSet.isTimed = true
                    firstSet.seconds = 0

                    let secondSet = RepositorySet()
                    secondSet.isTimed = true
                    secondSet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(firstSet)
                    repositoryExercise.sets.append(secondSet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when first set is weighted and repetitions are set to 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = false
                    repositorySet.reps = 0
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when multiple sets are weighted and repetitions are set to 0") {
                    let firstSet = RepositorySet()
                    firstSet.isTimed = false
                    firstSet.reps = 0

                    let secondSet = RepositorySet()
                    secondSet.isTimed = false
                    secondSet.reps = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(firstSet)
                    repositoryExercise.sets.append(secondSet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(false))
                }
                
                it("is completed when first set is timed and time is bigger than 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 10
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(true))
                }

                it("is completed when first set is weighted and repetitions are bigger than 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = false
                    repositorySet.reps = 1

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(true))
                }
            }
        }
    }
}
