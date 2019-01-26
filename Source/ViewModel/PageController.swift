//
//  PageController.swift
//  InteractiveStory
//
//  Created by David McCann.
//  Copyright © David McCann. All rights reserved.
//

import UIKit

// MARK: - Extensions

// Extension so we don't have to use a constant or type in NSMakeRange constantly for different string stylings
extension NSAttributedString {
    var stringRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}

// Extension for styling the text in the story
extension Story {
    var attributedText: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: attributedString.stringRange)
        return attributedString
    }
}

// Extension for whether or not we want to style the text or leave default
extension Page {
    func story(attributed: Bool) -> NSAttributedString {
        if attributed {
            return story.attributedText
        } else {
            return NSAttributedString(string: story.text)
        }
    }
}

class PageController: UIViewController {

    var page: Page?
    var soundEffectsPlayer = SoundEffectsPlayer()

    // MARK: - User Interface Properties

    // Lazy load so we can use .page? and keep viewDidLoad clean
    lazy var artworkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = self.page?.story.artwork
        return imageView
    }()

    // Lazy load so we can use .page? and keep viewDidLoad clean
    lazy var storyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = self.page?.story(attributed: true)
        return label
    }()

    lazy var firstChoiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        // If the first choice does not have a page title, use "Play Again"
        let title = self.page?.firstChoice?.title ?? "Play Again"
        // If the first choice exists, use loadFirstChoice, else use playAgain
        let selector = self.page?.firstChoice != nil ? #selector(PageController.loadFirstChoice) : #selector(PageController.playAgain)

        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)

        return button
    }()

    lazy var secondChoiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(self.page?.secondChoice?.title, for: .normal)
        button.addTarget(self, action: #selector(PageController.loadSecondChoice), for: .touchUpInside)

        return button
    }()

    // MARK: - Inits

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Add the artwork subview and constraints
        view.addSubview(artworkView)
        NSLayoutConstraint.activate([
            artworkView.topAnchor.constraint(equalTo: view.topAnchor),
            artworkView.leftAnchor.constraint(equalTo: view.leftAnchor),
            artworkView.rightAnchor.constraint(equalTo: view.rightAnchor),
            artworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add the story label subview and constraints
        view.addSubview(storyLabel)
        NSLayoutConstraint.activate([
            storyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            storyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            storyLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -48.0)
        ])

        // Add first choice button
        view.addSubview(firstChoiceButton)
        NSLayoutConstraint.activate([
            firstChoiceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstChoiceButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80.0)
        ])

        // Add second choice button
        view.addSubview(secondChoiceButton)
        NSLayoutConstraint.activate([
            secondChoiceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondChoiceButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.0)
        ])
    }

    // MARK: - Custom functions

    // Checks to make sure a choice exists on the current page
    // Then loads the page connected to the button and pushes it to the view
    @objc func loadFirstChoice() {
        if let page = page, let firstChoice = page.firstChoice {
            let nextPage = firstChoice.page
            let pageController = PageController(page: nextPage)

            soundEffectsPlayer.playSound(for: firstChoice.page.story)
            navigationController?.pushViewController(pageController, animated: true)
        }
    }

    // Checks to make sure a choice exists on the current page
    // Then loads the page connected to the button and pushes it to the view
    @objc func loadSecondChoice() {
        if let page = page, let secondChoice = page.secondChoice {
            let nextPage = secondChoice.page
            let pageController = PageController(page: nextPage)

            soundEffectsPlayer.playSound(for: secondChoice.page.story)
            navigationController?.pushViewController(pageController, animated: true)
        }
    }

    @objc func playAgain() {
        navigationController?.popToRootViewController(animated: true)
    }
}
