import UIKit

class LoopCollectionViewController: UIViewController {

    private var colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple
    ]

    private let cellId = "Cell"
    private var isPagination = false

    private lazy var loopView: LoopCollectionView = {
        let v = LoopCollectionView()
        v.scrollDirection = .horizontal
        v.cellLayout = LCInfiniteScrollCellLayout(size: 120, spacing: 12)
        v.dataSource = self
        v.delegate = self
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        return v
    }()

    private let modeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LoopCollectionView"
        view.backgroundColor = .lightGray
        setupUI()
        loopView.reloadData()
    }

    private func setupUI() {
        modeLabel.text = "Carousel (size: 120, spacing: 12)"
        modeLabel.font = .boldSystemFont(ofSize: 16)
        modeLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [modeLabel, loopView])
        stack.axis = .vertical
        stack.spacing = 8

        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle("Pagination", for: .normal)
        toggleButton.setTitleColor(.blue.withAlphaComponent(0.7), for: .normal)
        toggleButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        toggleButton.addTarget(self, action: #selector(toggleLayout), for: .touchUpInside)

        let shuffleButton = UIButton(type: .system)
        shuffleButton.setTitle("Shuffle", for: .normal)
        shuffleButton.setTitleColor(.blue.withAlphaComponent(0.7), for: .normal)
        shuffleButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        shuffleButton.addTarget(self, action: #selector(shuffleData), for: .touchUpInside)

        let randomButton = UIButton(type: .system)
        randomButton.setTitle("Random", for: .normal)
        randomButton.setTitleColor(.blue.withAlphaComponent(0.7), for: .normal)
        randomButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        randomButton.addTarget(self, action: #selector(randomData), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [toggleButton, shuffleButton, randomButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually

        let rootStack = UIStackView(arrangedSubviews: [stack, buttonStack])
        rootStack.axis = .vertical
        rootStack.spacing = 24
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loopView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    @objc private func toggleLayout() {
        isPagination.toggle()
        if isPagination {
            loopView.cellLayout = .pagination
            modeLabel.text = "Pagination"
        } else {
            loopView.cellLayout = LCInfiniteScrollCellLayout(size: 120, spacing: 12)
            modeLabel.text = "Carousel (size: 120, spacing: 12)"
        }
        loopView.reloadData()

    }

    @objc private func shuffleData() {
        colors.shuffle()
        loopView.reloadData()
    }

    @objc private func randomData() {
        let allColors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemTeal, .systemPink, .systemYellow, .systemIndigo, .systemMint,
            .systemBrown, .systemCyan, .systemGray
        ]
        colors = allColors.randomElements(minCount: 3)
        loopView.reloadData()
    }
}

extension Array {
    func randomElements(minCount: Int = 3) -> [Element] {
        guard !isEmpty else { return [] }
        guard count >= minCount else { return self }
        let randomCount = Int.random(in: minCount...count)
        return Array(shuffled().prefix(randomCount))
    }
}

// MARK: - LoopCollectionViewDataSource

extension LoopCollectionViewController: LoopCollectionViewDataSource {

    func numberOfItems(in loopCollectionView: LoopCollectionView) -> Int {
        colors.count
    }

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = loopCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: index)
        cell.backgroundColor = colors[index]
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = "\(index + 1)"
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

// MARK: - LoopCollectionViewDelegate

extension LoopCollectionViewController: LoopCollectionViewDelegate {

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, didSelectItemAt index: Int) {
        print("Tapped index: \(index)")
    }
}
