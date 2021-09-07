import UIKit
import AVFoundation

final class Util {

    private let arr: Array<String>
    private let song: Array<String>
    private var index: Int

    init() {
        self.index = 0
        self.arr = ["avrilLavigne", "coldPlay", "jayChou", "maroon5", "michaelJackson", "nameWee"]
        self.song = ["When You Are Gone", "Viva La Vida", "爱在西元前", "Moves Like Jagger", "Bad", "漂向北方"]
    }
    
    public func updateIndex(index: Int) {
        self.index = index
    }

    public func incrementCount() {
        if (self.index == self.arr.count - 1) {
            self.index = 0
        } else {
            self.index += 1
        }
    }

    public func decrementCount() {
        if (self.index == 0) {
            self.index = self.arr.count - 1
        } else {
            self.index -= 1
        }
    }
    
    public func getIndex() -> Int {
        return self.index
    }
    
    public func getImageFromIndex(index: Int) -> String {
        return "util/\(self.arr[index]).jpg"
    }

    public func getImagePath() -> String {
        return "util/\(self.arr[self.index]).jpg"
    }
    
    public func getSongPathFromIndex(index: Int) -> String {
        return "\(self.arr[index])"
    }
    
    public func getSongPath() -> String {
        return self.arr[self.index]
    }
    
    public func getSongName(index: Int) -> String {
        return self.song[index]
    }

    public func getPlayButtonPath() -> String {
        return "util/play.jpg"
    }

    public func getPauseButtonPath() -> String {
        return "util/pause.jpg"
    }

    public func getPrevButtonPath() -> String {
        return "util/prev.jpg"
    }

    public func getNextButtonPath() -> String {
        return "util/next.jpg"
    }
    
    public func getCount() -> Int {
        return arr.count
    }
}

final class ViewController: UIViewController {

    private static let IDENTIFIER = "TABLE_CELL"
    private static let INDEX = "INDEX"

    private let util: Util = Util()
    private var pressPlay = false
    private var audioPlayer: AVAudioPlayer?

    @IBOutlet weak var musicImg: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        
        playButton.setImage(UIImage(named: self.util.getPlayButtonPath()), for: .normal)
        prevButton.setImage(UIImage(named: self.util.getPrevButtonPath()), for: .normal)
        nextButton.setImage(UIImage(named: self.util.getNextButtonPath()), for: .normal)
        
        let defaults = UserDefaults.standard

        if let index: Int = defaults.integer(forKey: ViewController.INDEX) {
            pressPlay = true
            self.setUp(index: index)
        } else {
            self.setUp(index: 0)
        }
    }
    
    private func setUp(index: Int) {
        musicImg.image = UIImage(named: self.util.getImageFromIndex(index: index))
        musicLabel.text = self.util.getSongName(index: index)
        let audioSelected = Bundle.main.path(forResource: self.util.getSongPathFromIndex(index: index), ofType: "mp3")
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioSelected!))
        } catch{
            print(error)
        }
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        self.start(play: !pressPlay)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        self.util.incrementCount()
        musicImg.image = UIImage(named: self.util.getImagePath())
        musicLabel.text = self.util.getSongName(index: self.util.getIndex())
        self.start(play: true)
    }

    @IBAction func prevButtonPressed(_ sender: Any) {
        self.util.decrementCount()
        musicImg.image = UIImage(named: self.util.getImagePath())
        musicLabel.text = self.util.getSongName(index: self.util.getIndex())
        self.start(play: true)
    }
    
    private func start(play: Bool) {
        pressPlay = play
        playLabel.text = (pressPlay ? "Pause" : "Play").localized()
        let img = pressPlay ? UIImage(named: self.util.getPauseButtonPath()) : UIImage(named: self.util.getPlayButtonPath())
        playButton.setImage(img, for: .normal)
        self.playMusic(index: self.util.getIndex())
    }
    
    private func playMusic(index: Int) {
        
        if let audioPlayer = audioPlayer, !pressPlay {
            audioPlayer.stop()
        } else {
            let urlMusic = Bundle.main.path(forResource: self.util.getSongPathFromIndex(index: index), ofType: "mp3")
            
            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                guard let urlMusic = urlMusic else {
                    return
                }
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlMusic))
                
                guard let audioPlayer = self.audioPlayer else {
                    return
                }
                
                let defaults = UserDefaults.standard
                defaults.setValue(index, forKey: ViewController.INDEX)
                audioPlayer.play()
                
            } catch {
                print("Error playing")
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.util.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: ViewController.IDENTIFIER)
        
        if cell == nil {
            let newCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: ViewController.IDENTIFIER)
            newCell.imageView?.image = UIImage(named: self.util.getImageFromIndex(index: indexPath.row))
            newCell.textLabel!.text = self.util.getSongName(index: indexPath.row)
            return newCell
        }
        
        cell!.imageView?.image = UIImage(named: self.util.getImageFromIndex(index: indexPath.row))
        cell!.textLabel!.text = self.util.getSongName(index: indexPath.row)
        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        musicLabel.text = self.util.getSongName(index: indexPath.row)
        self.pressPlay = true
        musicImg.image = UIImage(named: self.util.getImageFromIndex(index: indexPath.row))
        self.util.updateIndex(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        self.start(play: true)
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
