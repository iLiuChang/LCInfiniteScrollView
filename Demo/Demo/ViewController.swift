//
//  ViewController.swift
//  Demo
//
//  Created by LC on 2026/7/1.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties

    private let horizontalColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple
    ]
    private let verticalColors: [UIColor] = [
        .systemTeal, .systemPink, .systemYellow, .systemIndigo, .systemMint
    ]

    private let horizontalCellId = "HorizontalCell"
    private let verticalCellId = "VerticalCell"

    // MARK: - UI

    private lazy var horizontalScrollView: LCInfiniteScrollView = {
        let sv = LCInfiniteScrollView()
        sv.scrollDirection = .horizontal
        sv.autoScrollTimeInterval = 2.5
        sv.interitemSpacing = 10
        sv.dataSource = self
        sv.delegate = self
        sv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: horizontalCellId)
        return sv
    }()

    private lazy var verticalScrollView: LCInfiniteScrollView = {
        let sv = LCInfiniteScrollView()
        sv.scrollDirection = .vertical
        sv.autoScrollTimeInterval = 2.5
        sv.interitemSpacing = 10
        sv.dataSource = self
        sv.delegate = self
        sv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: verticalCellId)
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Infinite Scroll Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        // Horizontal section label
        let hLabel = UILabel()
        hLabel.text = "Horizontal Infinite Scroll"
        hLabel.font = .boldSystemFont(ofSize: 16)
        hLabel.textAlignment = .center

        // Vertical section label
        let vLabel = UILabel()
        vLabel.text = "Vertical Infinite Scroll"
        vLabel.font = .boldSystemFont(ofSize: 16)
        vLabel.textAlignment = .center

        // Horizontal page indicator
        let hIndicator = UIPageControl()
        hIndicator.numberOfPages = horizontalColors.count
        hIndicator.currentPage = 0
        hIndicator.tag = 100

        // Vertical page indicator
        let vIndicator = UIPageControl()
        vIndicator.numberOfPages = verticalColors.count
        vIndicator.currentPage = 0
        vIndicator.tag = 200

        // Stack views
        let hStack = UIStackView(arrangedSubviews: [hLabel, horizontalScrollView, hIndicator])
        hStack.axis = .vertical
        hStack.spacing = 8

        let vStack = UIStackView(arrangedSubviews: [vLabel, verticalScrollView, vIndicator])
        vStack.axis = .vertical
        vStack.spacing = 8

        let rootStack = UIStackView(arrangedSubviews: [hStack, vStack])
        rootStack.axis = .vertical
        rootStack.spacing = 24
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            horizontalScrollView.heightAnchor.constraint(equalToConstant: 200),
            verticalScrollView.heightAnchor.constraint(equalToConstant: 300),
        ])
        
    }
}

// MARK: - LCInfiniteScrollViewDataSource

extension ViewController: LCInfiniteScrollViewDataSource {

    func numberOfItems(in infiniteScrollView: LCInfiniteScrollView) -> Int {
        if infiniteScrollView === horizontalScrollView {
            return horizontalColors.count
        } else {
            return verticalColors.count
        }
    }

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, cellForItemAt index: Int) -> UICollectionViewCell {
        if infiniteScrollView === horizontalScrollView {
            let cell = infiniteScrollView.dequeueReusableCell(withReuseIdentifier: horizontalCellId, at: index)
            cell.backgroundColor = horizontalColors[index]
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel()
            label.text = "H-Page \(index + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 28)
            label.textAlignment = .center
            label.frame = cell.contentView.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.contentView.addSubview(label)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        } else {
            let cell = infiniteScrollView.dequeueReusableCell(withReuseIdentifier: verticalCellId, at: index)
            cell.backgroundColor = verticalColors[index]
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel()
            label.text = "V-Page \(index + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 28)
            label.textAlignment = .center
            label.frame = cell.contentView.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.contentView.addSubview(label)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        }
    }
}

// MARK: - LCInfiniteScrollViewDelegate

extension ViewController: LCInfiniteScrollViewDelegate {

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didSelectItemAt index: Int) {
        let direction = infiniteScrollView === horizontalScrollView ? "Horizontal" : "Vertical"
        print("\(direction) item tapped at index: \(index)")
    }

    func infiniteScrollViewDidScroll(_ infiniteScrollView: LCInfiniteScrollView) {
        let tag = infiniteScrollView === horizontalScrollView ? 100 : 200
        guard let indicator = view.viewWithTag(tag) as? UIPageControl else { return }
        indicator.currentPage = infiniteScrollView.currentIndex
    }

    func infiniteScrollViewDidEndScrollAnimation(_ infiniteScrollView: LCInfiniteScrollView) {
        let tag = infiniteScrollView === horizontalScrollView ? 100 : 200
        guard let indicator = view.viewWithTag(tag) as? UIPageControl else { return }
        indicator.currentPage = infiniteScrollView.currentIndex
    }

    func infiniteScrollViewDidEndDecelerating(_ infiniteScrollView: LCInfiniteScrollView) {
        let tag = infiniteScrollView === horizontalScrollView ? 100 : 200
        guard let indicator = view.viewWithTag(tag) as? UIPageControl else { return }
        indicator.currentPage = infiniteScrollView.currentIndex
    }
    
    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didHighlightItemAt index: Int) {
        let direction = infiniteScrollView === horizontalScrollView ? "Horizontal" : "Vertical"
        print("\(direction) didHighlightItemAt index: \(index)")
    }
}

