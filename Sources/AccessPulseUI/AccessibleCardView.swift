#if canImport(UIKit)
import UIKit

public final class AccessibleCardView: UIView {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let stackView = UIStackView()

    public init(title: String, detail: String) {
        super.init(frame: .zero)
        configure(title: title, detail: detail)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, detail: String) {
        isAccessibilityElement = true
        accessibilityTraits = [.staticText]
        accessibilityLabel = title
        accessibilityValue = detail

        layer.cornerRadius = 16
        backgroundColor = .secondarySystemBackground

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = title

        detailLabel.font = .preferredFont(forTextStyle: .body)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.numberOfLines = 0
        detailLabel.text = detail

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
}
#endif
