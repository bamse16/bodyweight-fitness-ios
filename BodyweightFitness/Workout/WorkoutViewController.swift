import UIKit
import AVFoundation

protocol WorkoutInteractionDelegate {
    func selectPreviousExercise()
    func selectNextExercise()
    func restTimerShouldStart()
    func restTimerShouldStop()
    func timerDidFinish()

    func log(reps: Int, for exercise: Exercise)
    func log(seconds: Int, for exercise: Exercise)
}

class WorkoutNavigationController: UINavigationController {}

class WorkoutViewController: UIViewController, WorkoutInteractionDelegate {
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var topView: UIView!

    @IBOutlet var mainView: UIView!
    @IBOutlet var videoView: UIView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    let restTimerViewController: RestTimerViewController = RestTimerViewController()
    let timedViewController: TimedViewController = TimedViewController()
    let weightedViewController: WeightedViewController = WeightedViewController()
    
    let userDefaults: UserDefaults = UserDefaults()
    
    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()

    let audioManager: AudioManager = AudioManager()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timedViewController.rootViewController = self
        self.weightedViewController.rootViewController = self

        self.weightedViewController.delegate = self
        self.timedViewController.delegate = self
        self.weightedViewController.delegate = self
        
        self.restTimerViewController.view.frame = self.topView.frame
        self.restTimerViewController.willMove(toParentViewController: self)
        self.addChildViewController(self.restTimerViewController)
        self.topView.addSubview(self.restTimerViewController.view)
        self.restTimerViewController.didMove(toParentViewController: self)
        
        self.timedViewController.view.frame = self.topView.frame
        self.timedViewController.willMove(toParentViewController: self)
        self.addChildViewController(self.timedViewController)
        self.topView.addSubview(self.timedViewController.view)
        self.timedViewController.didMove(toParentViewController: self)
        
        self.weightedViewController.view.frame = self.topView.frame
        self.weightedViewController.willMove(toParentViewController: self)
        self.addChildViewController(self.weightedViewController)
        self.topView.addSubview(self.weightedViewController.view)
        self.weightedViewController.didMove(toParentViewController: self)
        
        self.setNavigationBar()
        self.timedViewController.updateLabel()
        
        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: {
            self.current = $0.getFirstExercise()
            self.changeExercise(self.current)
        })
        
        self.setTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.changeExercise(current, updateTitle: false)
    }
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.text = self.current.title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 0, height: 0))

        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.primaryDark()
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.text = self.current.section!.title + ", " + self.current.desc
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))

        if titleLabel.frame.width >= subtitleLabel.frame.width {
            var adjustment = subtitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subtitleLabel.frame.width/2)
            subtitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }

        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        self.navigationItem.titleView = titleView
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dashboard(_ sender: UIBarButtonItem) {
        let dashboard = DashboardViewController()
        dashboard.currentExercise = current
        dashboard.rootViewController = self
        
        let controller = UINavigationController(rootViewController: dashboard)
        
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onClickLogWorkoutAction(_ sender: AnyObject) {
        self.timedViewController.stopTimer()
        
        let logWorkoutController = LogWorkoutController()
        
        logWorkoutController.parentController = self.navigationController
        logWorkoutController.setRepositoryRoutine(
            current,
            repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
        
        logWorkoutController.modalTransitionStyle = .coverVertical
        logWorkoutController.modalPresentationStyle = .custom
    
        self.navigationController?.dim(.in, alpha: 0.5, speed: 0.5)
        self.navigationController?.present(logWorkoutController, animated: true, completion: nil)
    }

    fileprivate func showRestTimer() {
        self.restTimerViewController.startTimer()
        self.restTimerViewController.view.isHidden = false
        
        self.timedViewController.view.isHidden = true
        self.weightedViewController.view.isHidden = true
    }

    internal func changeExercise(_ currentExercise: Exercise, updateTitle: Bool = true) {
        self.current = currentExercise
        
        self.restTimerViewController.changeExercise(currentExercise)
        self.timedViewController.changeExercise(currentExercise)
        self.weightedViewController.changeExercise(currentExercise)
        
        self.setVideo(currentExercise.videoId)
        
        if (currentExercise.section?.mode == SectionMode.all) {
            if let image = UIImage(named: "plus") {
                actionButton.setImage(image, for: UIControlState())
            }
        } else {
            if let image = UIImage(named: "progression") {
                actionButton.setImage(image, for: UIControlState())
            }
        }
        
        if self.restTimerViewController.isPlaying {
            self.restTimerViewController.view.isHidden = false
            self.timedViewController.view.isHidden = true
            self.weightedViewController.view.isHidden = true
        } else {
            if current.isTimed() {
                self.timedViewController.view.isHidden = false
                self.weightedViewController.view.isHidden = true
            } else {
                self.timedViewController.view.isHidden = true
                self.weightedViewController.view.isHidden = false
            }
        }

        if (updateTitle) {
            self.setTitle()
        }
    }
    
    func setVideo(_ videoId: String) {
        if !videoId.isEmpty {
            if let player = self.player {
                player.pause()
                self.player = nil
                
            }
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
                self.playerLayer = nil
            }
            
            self.videoView.layer.sublayers?.removeAll()
            
            let path = Bundle.main.path(forResource: videoId, ofType: "mp4")
            
            player = AVPlayer(url: URL(fileURLWithPath: path!))
            player!.actionAtItemEnd = AVPlayerActionAtItemEnd.none;
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            
            self.videoView.layer.insertSublayer(playerLayer, at: 0)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(WorkoutViewController.playerItemDidReachEnd),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player!.currentItem)
            
            player!.seek(to: kCMTimeZero)
            player!.play()
        } else {
            if let player = self.player {
                player.pause()
                self.player = nil
                
            }
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
                self.playerLayer = nil
            }
            
            self.videoView.layer.sublayers?.removeAll()
        }
    }
    
    func playerItemDidReachEnd() {
        player!.seek(to: kCMTimeZero)
    }
    
    @IBAction func actionButtonClicked(_ sender: AnyObject) {
        guard let button = sender as? UIView else {
            return
        }
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        alertController.modalPresentationStyle = .popover
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = button;
            presenter.sourceRect = button.bounds;
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if self.current.youTubeId != "" {
            alertController.addAction(UIAlertAction(title: "Watch Full Video", style: .default) { (action) in
                if let requestUrl = URL(string: "https://www.youtube.com/watch?v=" + self.current.youTubeId) {
                    UIApplication.shared.openURL(requestUrl)
                }
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Today's Workout", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "WorkoutLog", bundle: Bundle.main)
            
            let p = storyboard.instantiateViewController(
                withIdentifier: "WorkoutLogViewController"
                ) as! WorkoutLogViewController
            
            p.date = Date()
            p.repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
            p.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(p, animated: true)
        })
        
        if let currentSection = current.section {
            if (currentSection.mode == .levels || currentSection.mode == .pick) {
                // ... Choose Progression
                alertController.addAction(
                    UIAlertAction(title: "Choose Progression", style: .default) { (action) in
                        if let exercises = self.current.section?.exercises {
                            let alertController = UIAlertController(
                                title: "Choose Progression",
                                message: nil,
                                preferredStyle: .actionSheet)
                            
                            alertController.modalPresentationStyle = .popover
                            
                            if let presenter = alertController.popoverPresentationController {
                                presenter.sourceView = button;
                                presenter.sourceRect = button.bounds;
                            }
                            
                            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            for anyExercise in exercises {
                                if let exercise = anyExercise as? Exercise {
                                    var title = ""
                                    
                                    if(exercise.section?.mode == SectionMode.levels) {
                                        title = "\(exercise.level): \(exercise.title)"
                                    } else {
                                        title = "\(exercise.title)"
                                    }
                                    
                                    alertController.addAction(
                                        UIAlertAction(title: title, style: .default) { (action) in
                                            let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
                                            let currentExerciseId = currentSection.currentExercise?.exerciseId
                                            let exerciseId = exercise.exerciseId
                                            
                                            let realm = RepositoryStream.sharedInstance.getRealm()
                                            
                                            try! realm.write {
                                                repositoryRoutine.exercises.filter { $0.exerciseId == currentExerciseId }.first?.visible = false
                                                repositoryRoutine.exercises.filter { $0.exerciseId == exerciseId }.first?.visible = true
                                            }
                                            
                                            RoutineStream.sharedInstance.routine.setProgression(exercise)
                                            self.changeExercise(exercise)
                                            PersistenceManager.storeRoutine(RoutineStream.sharedInstance.routine)
                                        }
                                    )
                                }
                            }
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                )
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - WorkoutInteractionDelegate

    func selectPreviousExercise() {
        if let previous = self.current.previous {
            changeExercise(previous)
        }
    }

    func selectNextExercise() {
        if let next = self.current.next {
            changeExercise(next)
        }
    }

    func restTimerShouldStart() {
        if userDefaults.showRestTimer() {
            let routineId = RoutineStream.sharedInstance.routine.routineId

            if let section = current.section {
                if (section.sectionId == "section0") {
                    if userDefaults.showRestTimerAfterWarmup() {
                        showRestTimer()
                    }
                } else if (section.sectionId == "section1") {
                    if userDefaults.showRestTimerAfterBodylineDrills() {
                        showRestTimer()
                    }
                } else {
                    if (routineId != ExternalRoutineMap.BodyweightFitness.id) {
                        if userDefaults.showRestTimerAfterFlexibilityExercises() {
                            showRestTimer()
                        }
                    } else {
                        showRestTimer()
                    }
                }
            } else {
                showRestTimer()
            }
        }
    }

    func restTimerShouldStop() {
        self.restTimerViewController.stopTimer()
        self.restTimerViewController.view.isHidden = true

        if current.isTimed() {
            self.timedViewController.view.isHidden = false
            self.weightedViewController.view.isHidden = true
        } else {
            self.timedViewController.view.isHidden = true
            self.weightedViewController.view.isHidden = false
        }
    }

    func timerDidFinish() {
        let defaults = Foundation.UserDefaults.standard
        if(defaults.object(forKey: "playAudioWhenTimerStops") != nil) {
            let playAudioWhenTimerStops = defaults.bool(forKey: "playAudioWhenTimerStops")
            if(playAudioWhenTimerStops) {
                self.audioManager.playFinished()
            }
        } else {
            self.audioManager.playFinished()
        }
    }

    func log(reps: Int, for exercise: Exercise) {
        if (exercise.isTimed()) {
            return
        }

        let numberOfRepsIsValid = reps >= 1 && reps <= 25
        if (!numberOfRepsIsValid) {
            return
        }

        let realm = RepositoryStream.sharedInstance.getRealm()
        let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

        if let repositoryExercise = repositoryRoutine.exercises.filter({
            $0.exerciseId == exercise.exerciseId
        }).first {
            let sets = repositoryExercise.sets

            try! realm.write {
                if (sets.count == 1 && sets[0].reps == 0) {
                    sets[0].reps = reps
                } else if (sets.count >= 1 && sets.count < 9) {
                    let repositorySet = RepositorySet()

                    repositorySet.exercise = repositoryExercise
                    repositorySet.isTimed = false
                    repositorySet.reps = reps

                    sets.append(repositorySet)

                    repositoryRoutine.lastUpdatedTime = Date()
                }

                realm.add(repositoryRoutine, update: true)

                let message = "Logged Set \(sets.count) - \(reps) reps"
                self.show(message: message, for: exercise)
                self.showRestTimer()
            }

            RoutineStream.sharedInstance.setRepository()
        }
    }

    func log(seconds: Int, for exercise: Exercise) {
        if (!exercise.isTimed()) {
            return
        }

        if (seconds <= 0) {
            return
        }

        let realm = RepositoryStream.sharedInstance.getRealm()
        let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

        if let repositoryExercise = repositoryRoutine.exercises.filter({
            $0.exerciseId == exercise.exerciseId
        }).first {
            let sets = repositoryExercise.sets

            try! realm.write {
                if (sets.count == 1 && sets[0].seconds == 0) {
                    sets[0].seconds = seconds
                } else if (sets.count >= 1 && sets.count < 9) {
                    let repositorySet = RepositorySet()

                    repositorySet.exercise = repositoryExercise
                    repositorySet.isTimed = true
                    repositorySet.seconds = seconds

                    sets.append(repositorySet)

                    repositoryRoutine.lastUpdatedTime = Date()

                }

                realm.add(repositoryRoutine, update: true)

                let message = "Logged \(seconds) seconds"
                self.show(message: message, for: exercise)
                self.showRestTimer()
            }

            RoutineStream.sharedInstance.setRepository()
        }
    }

    func show(message: String, for exercise: Exercise) {
        if exercise.isTimed() {
            self.timedViewController.showNotification(message: message)
        } else {
            self.weightedViewController.showNotification(message: message)
        }
    }
}
