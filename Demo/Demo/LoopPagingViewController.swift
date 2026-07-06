import UIKit

class LoopPagingViewController: UIViewController {

    private var colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple
    ]

    private let cellId = "PagingCell"

    private lazy var pagingView: LoopPagingView = {
        let v = LoopPagingView()
        v.scrollDirection = .horizontal
        v.autoScrollTimeInterval = 2.5
        v.dataSource = self
        v.delegate = self
        v.disableLoopForSingleItem = true
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        return v
    }()

    private let pageControl = UIPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LoopPagingView"
        view.backgroundColor = .lightGray
        setupUI()
        pagingView.reloadData()
    }

    private func setupUI() {
        let label = UILabel()
        label.text = "Auto-Scroll Paging (2.5s)"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center

        pageControl.numberOfPages = colors.count

        let pagingStack = UIStackView(arrangedSubviews: [label, pagingView, pageControl])
        pagingStack.axis = .vertical
        pagingStack.spacing = 8

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

        let buttonStack = UIStackView(arrangedSubviews: [shuffleButton, randomButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually

        let rootStack = UIStackView(arrangedSubviews: [pagingStack, buttonStack])
        rootStack.axis = .vertical
        rootStack.spacing = 24
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pagingView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }

    @objc private func shuffleData() {
        colors.shuffle()
        pagingView.reloadData()
    }

    @objc private func randomData() {
        let allColors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemTeal, .systemPink, .systemYellow, .systemIndigo, .systemMint,
            .systemBrown, .systemCyan, .systemGray
        ]
        colors = allColors.randomElements(minCount: 3)
        pagingView.reloadData()
    }
}

// MARK: - LoopCollectionViewDataSource

extension LoopPagingViewController: LoopCollectionViewDataSource {

    func numberOfItems(in loopCollectionView: LoopCollectionView) -> Int {
        let count = colors.count
        pageControl.numberOfPages = colors.count
        return count
    }

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = loopCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: index)
        cell.backgroundColor = colors[index]
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = "Page \(index + 1)"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 32)
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

extension LoopPagingViewController: LoopCollectionViewDelegate {

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, didSelectItemAt index: Int) {
        print("Paging tapped index: \(index)")
    }

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        pageControl.currentPage = index
    }
}
