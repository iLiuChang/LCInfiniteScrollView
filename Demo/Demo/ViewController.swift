import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LCInfiniteScrollView"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Demo"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        let loopCollectionButton = UIButton(type: .system)
        loopCollectionButton.setTitle("LoopCollectionView Demo", for: .normal)
        loopCollectionButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loopCollectionButton.backgroundColor = .systemBlue
        loopCollectionButton.setTitleColor(.white, for: .normal)
        loopCollectionButton.layer.cornerRadius = 12
        loopCollectionButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loopCollectionButton.addTarget(self, action: #selector(pushLoopCollection), for: .touchUpInside)

        let loopPagingButton = UIButton(type: .system)
        loopPagingButton.setTitle("LoopPagingView Demo", for: .normal)
        loopPagingButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loopPagingButton.backgroundColor = .systemOrange
        loopPagingButton.setTitleColor(.white, for: .normal)
        loopPagingButton.layer.cornerRadius = 12
        loopPagingButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loopPagingButton.addTarget(self, action: #selector(pushLoopPaging), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, loopCollectionButton, loopPagingButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    @objc private func pushLoopCollection() {
        navigationController?.pushViewController(LoopCollectionViewController(), animated: true)
    }

    @objc private func pushLoopPaging() {
        navigationController?.pushViewController(LoopPagingViewController(), animated: true)
    }
}
