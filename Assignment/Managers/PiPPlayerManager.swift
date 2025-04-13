//
//  PiPPlayerManager.swift
//  Assignment
//
//  Created by Muhammad Irfan Tarar on 13/04/2025.
//
import UIKit
import AVKit
import GoogleInteractiveMediaAds


class PiPPlayerManager: NSObject {
    
    static let shared = PiPPlayerManager()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var adsLoader: IMAAdsLoader?
    private var adsManager: IMAAdsManager?
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var adWindow: UIWindow?
    private var adContainerView: UIView?
    private var dummyViewController: UIViewController?
    private var onAdCompleted: (() -> Void)?
    private var overlayControlsView: UIView?
    private var playPauseButton: UIButton?
    private var closeButton: UIButton?
    
    private override init() {
        super.init()
        let settings = IMASettings()
        settings.enableBackgroundPlayback = true
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader?.delegate = self
        
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
    }
    
    func playAdThenLive(onAdCompleted: @escaping () -> Void) {
        stopPlayback()
        
        // Setup a transparent window on top of everything
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        adWindow = UIWindow(windowScene: windowScene!)
        adWindow?.frame = UIScreen.main.bounds
        adWindow?.windowLevel = .alert + 1
        
        dummyViewController = UIViewController()
        dummyViewController?.view.backgroundColor = .clear
        
        adContainerView = UIView(frame: adWindow!.bounds)
        dummyViewController?.view.addSubview(adContainerView!)
        
        adWindow?.rootViewController = dummyViewController
        adWindow?.isHidden = false
        
        self.onAdCompleted = { [weak self] in
            self?.adWindow?.isHidden = true
            self?.adWindow = nil
            onAdCompleted()
        }
        
        let dummyPlayer = AVPlayer()
        self.contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: dummyPlayer)
        
        let adDisplayContainer = IMAAdDisplayContainer(
            adContainer: adContainerView!,
            viewController: dummyViewController!,
            companionSlots: nil
        )
        
        let adTagURL = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/omid_ad_samples&env=vp&gdfp_req=1&output=vast&sz=640x480&description_url=http%3A%2F%2Ftest_site.com%2Fhomepage&vpmute=0&vpa=0&vad_format=linear&url=http%3A%2F%2Ftest_site.com&vpos=preroll&unviewed_position_start=1&correlator="
        
        let request = IMAAdsRequest(
            adTagUrl: adTagURL,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil
        )
        
        adsLoader?.requestAds(with: request)
    }
    
    func stopPlayback() {
        pipController?.stopPictureInPicture()
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        pipController = nil
        if let adWindow = adWindow {
            adWindow.isHidden = true
            adWindow.rootViewController = nil
            self.adWindow = nil
        }
        dummyViewController?.removeFromParent()
        adContainerView = nil
    }
    
    func startPiPForBackgroundPlayback() {
        guard let adWindow = adWindow else { return }
        
        // Animate the adWindow to move to bottom
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            adWindow.frame = CGRect(
                x: 110,
                y: UIScreen.main.bounds.height - 200,
                width: UIScreen.main.bounds.width - 113,
                height: 150
            )
            self.playerLayer?.cornerRadius = 10
            self.playerLayer?.frame = adWindow.bounds
            self.setupOverlayControls()
        }
        
        if let playerLayer = self.playerLayer, AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.delegate = self
            pipController?.startPictureInPicture()
        }
    }
    
    private func startLivePlayback() {
        guard let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else { return }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        if let container = adContainerView {
            container.layer.addSublayer(playerLayer!)
        }
        
        adWindow?.frame = CGRect(x: 15, y: UIScreen.main.bounds.height/2, width: UIScreen.main.bounds.width - 30, height: 200)
        self.playerLayer?.frame = adWindow?.bounds ?? CGRect()
        self.setupOverlayControls()
        
        if let layer = playerLayer, AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: layer)
            pipController?.delegate = self
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
            pipController?.startPictureInPicture()
        }
        
        
        player?.play()
    }
    
    private func setupOverlayControls() {
        guard let containerView = adContainerView, let playerLayer = playerLayer else { return }
        
        overlayControlsView?.removeFromSuperview() // Clean up if already there
        
        let overlay = UIView(frame: playerLayer.bounds)
        overlay.backgroundColor = UIColor.clear
        containerView.addSubview(overlay)
        overlayControlsView = overlay
        
        // Play/Pause Button
        let playPause = UIButton(type: .system)
        playPause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPause.tintColor = .white
        playPause.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        overlay.addSubview(playPause)
        self.playPauseButton = playPause
        
        // Close Button
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        close.tintColor = .white
        close.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        overlay.addSubview(close)
        self.closeButton = close
        
        // Layout
        playPause.translatesAutoresizingMaskIntoConstraints = false
        close.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playPause.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            playPause.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            playPause.widthAnchor.constraint(equalToConstant: 50),
            playPause.heightAnchor.constraint(equalToConstant: 50),
            
            close.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 20),
            close.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -10),
            close.widthAnchor.constraint(equalToConstant: 40),
            close.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc private func didTapPlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc private func didTapClose() {
        stopPlayback()
    }
}

// MARK: - IMAAdsLoaderDelegate, IMAAdsManagerDelegate

extension PiPPlayerManager: IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Ad failed to load: \(String(describing: adErrorData.adError.message))")
        startLivePlayback()
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive adEvent: IMAAdEvent) {
        switch adEvent.type {
        case .LOADED:
            adsManager.start()
        case .ALL_ADS_COMPLETED:
            print("All ads completed")
            startLivePlayback()
        default:
            break
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        print("Ad manager error: \(String(describing: error.message))")
        startLivePlayback()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        print("Content pause requested")
        player?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        print("Content resume requested")
        player?.play()
    }
}

// MARK: - AVPictureInPictureControllerDelegate

extension PiPPlayerManager: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP stopped")
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP started")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Handle UI restoration when PiP is stopped
        completionHandler(true)
    }
}
