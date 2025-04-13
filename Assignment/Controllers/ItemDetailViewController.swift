//
//  ItemDetailViewController.swift
//  Assignment
//
//  Created by Muhammad Irfan Tarar on 13/04/2025.
//

import UIKit
import AVKit
import GoogleInteractiveMediaAds

class ItemDetailViewController: UIViewController {
    
    // MARK: - Properties
    var item: Item? {
        didSet {
            configureView()
        }
    }
    
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let videoContainerView = UIView()
    private var adFinished = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureView()
        setupNavigation()
        playAdThenLiveContent()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkText
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        
        [imageView, descriptionLabel, videoContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            videoContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigation() {
        title = item?.name ?? "Item Details"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func configureView() {
        guard isViewLoaded else { return }
        
        if let imageName = item?.imageName, let image = UIImage(named: imageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo") // fallback image
        }
        
        descriptionLabel.text = item?.detailedDescription ?? "No description available."
    }
    
    private func playAdThenLiveContent() {
        PiPPlayerManager.shared.playAdThenLive { [weak self] in
            DispatchQueue.main.async {
                self?.adFinished = true
                // Potentially start live content here if needed
            }
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        PiPPlayerManager.shared.startPiPForBackgroundPlayback()
        navigationController?.popViewController(animated: true)
    }
}
