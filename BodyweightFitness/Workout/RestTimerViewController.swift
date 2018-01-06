import UIKit

class RestTimerViewController: UIViewController {
    @IBOutlet var timerMinutesButton: UIButton!
    @IBOutlet var timerSecondsButton: UIButton!
    
    @IBOutlet var timerPlayButton: UIButton!
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    var delegate: WorkoutInteractionDelegate?

    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()

    var timer = Timer()
    var isPlaying = false
    
    var seconds = PersistenceManager.getRestTime()
    var defaultSeconds = PersistenceManager.getRestTime()
    
    init() {
        super.init(nibName: "RestTimerView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeExercise(_ currentExercise: Exercise) {
        self.current = currentExercise
        self.defaultSeconds = PersistenceManager.getRestTime()
        
        if let _ = self.current.previous {
            self.previousButton.isHidden = false
        } else {
            self.previousButton.isHidden = true
        }
        
        if let _ = self.current.next {
            self.nextButton.isHidden = false
        } else {
            self.nextButton.isHidden = true
        }
    }
    
    func updateLabel() {
        let (_, m, s) = secondsToHoursMinutesSeconds(seconds)
        
        timerMinutesButton.setTitle(printTimerValue(m), for: UIControlState())
        timerSecondsButton.setTitle(printTimerValue(s), for: UIControlState())
    }
    
    func printTimerValue(_ value: Int) -> String {
        if(value > 9) {
            return String(value)
        } else {
            return "0" + String(value)
        }
    }
    
    func stopTimer() {
        isPlaying = false
        
        timer.invalidate()
    }
    
    func startTimer() {
        restartTimer(defaultSeconds)
        
        isPlaying = true
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func restartTimer(_ seconds: Int) {
        stopTimer()
        
        self.seconds = seconds
        
        updateLabel()
    }
    
    func updateTimer() {
        seconds -= 1
        
        if(seconds <= 0) {
            self.delegate?.restTimerShouldStop()
            self.delegate?.timerDidFinish()
        }
        
        updateLabel()
    }
    
    @IBAction func stopButtonClicked(_ sender: AnyObject) {
        self.delegate?.restTimerShouldStop()
    }
    
    @IBAction func previousButtonClicked(_ sender: AnyObject) {
        self.delegate?.selectPreviousExercise()
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        self.delegate?.selectNextExercise()
    }
}
