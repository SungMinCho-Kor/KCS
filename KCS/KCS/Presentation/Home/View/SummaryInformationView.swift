//
//  SummaryInformationView.swift
//  KCS
//
//  Created by 김영현 on 1/11/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SummaryInformationView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private lazy var storeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 22, weight: .bold)
        label.textColor = UIColor.primary1
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var certificationStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillProportionally
        
        return stack
    }()
    
    private lazy var category: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        label.textColor = UIColor.grayLabel
        
        return label
    }()
    
    private lazy var storeOpenClosed: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 15, weight: .regular)
        label.textColor = UIColor.goodPrice
        
        return label
    }()
    
    private lazy var openingHour: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        label.textColor = UIColor.grayLabel
        
        return label
    }()
    
    private let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLayerCorner(cornerRadius: 6)
        imageView.clipsToBounds = true
        imageView.image = UIImage.basicStore
        
        return imageView
    }()
    
    private let storeCallButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.image = SystemImage.phone
        config.cornerStyle = .capsule
        config.baseForegroundColor = .primary3
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        
        return button
    }()
    
    private var callDisposable: Disposable?
    
    private let dismissIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.swipeBar
        view.layer.cornerRadius = 2
        
        return view
    }()
    
    private let viewModel: SummaryViewModel
    private let summaryInformationHeightObserver: PublishRelay<CGFloat>
    
    init(viewModel: SummaryViewModel, summaryInformationHeightObserver: PublishRelay<CGFloat>) {
        self.viewModel = viewModel
        self.summaryInformationHeightObserver = summaryInformationHeightObserver
        super.init(frame: .zero)
        
        setBackgroundColor()
        setLayerCorner(cornerRadius: 15, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        addUIComponents()
        configureConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SummaryInformationView {
    
    func bind() {
        viewModel.setUIContentsOutput
            .bind { [weak self] contents in
                guard let self = self else { return }
                storeTitle.text = contents.storeTitle
                if storeTitle.numberOfVisibleLines == 1 {
                    summaryInformationHeightObserver.accept(230)
                } else {
                    summaryInformationHeightObserver.accept(253)
                }
                storeOpenClosed.text = contents.openClosedContent.openClosedType.rawValue
                openingHour.text = contents.openClosedContent.nextOpeningHour
                category.text = contents.category
                contents.certificationTypes
                    .map({
                        CertificationLabel(certificationType: $0)
                    })
                    .forEach { [weak self] in
                        self?.certificationStackView.addArrangedSubview($0)
                    }
            }
            .disposed(by: disposeBag)
        
        viewModel.thumbnailImageOutput
            .subscribe(onNext: { [weak self] data in
                self?.storeImageView.image = UIImage(data: data)
            })
            .disposed(by: disposeBag)
        
        viewModel.callButtonOutput
            .bind { [weak self] phoneNumber in
                guard let self = self else { return }
                storeCallButton.isHidden = false
                callDisposable = storeCallButton.rx.tap
                    .bind { [weak self] _ in
                        self?.callButtonTapped(phoneNum: phoneNumber)
                    }
            }
            .disposed(by: disposeBag)
    }
    
}

private extension SummaryInformationView {
    
    func setBackgroundColor() {
        backgroundColor = .white
    }
    
    func addUIComponents() {
        addSubview(storeTitle)
        addSubview(certificationStackView)
        addSubview(category)
        addSubview(storeOpenClosed)
        addSubview(openingHour)
        addSubview(storeImageView)
        addSubview(storeCallButton)
        addSubview(dismissIndicatorView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            storeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            storeTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            storeTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -156)
        ])
        
        NSLayoutConstraint.activate([
            category.topAnchor.constraint(equalTo: storeTitle.bottomAnchor, constant: 4),
            category.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            certificationStackView.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 9),
            certificationStackView.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            storeOpenClosed.topAnchor.constraint(equalTo: certificationStackView.bottomAnchor, constant: 8),
            storeOpenClosed.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            openingHour.centerYAnchor.constraint(equalTo: storeOpenClosed.centerYAnchor),
            openingHour.leadingAnchor.constraint(equalTo: storeOpenClosed.trailingAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            storeCallButton.topAnchor.constraint(equalTo: storeOpenClosed.bottomAnchor, constant: 21),
            storeCallButton.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor),
            storeCallButton.widthAnchor.constraint(equalToConstant: 69),
            storeCallButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            storeImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 27),
            storeImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            storeImageView.widthAnchor.constraint(equalToConstant: 132),
            storeImageView.heightAnchor.constraint(equalToConstant: 132)
        ])
        
        NSLayoutConstraint.activate([
            dismissIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dismissIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dismissIndicatorView.widthAnchor.constraint(equalToConstant: 35),
            dismissIndicatorView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func callButtonTapped(phoneNum: String) {
        if let url = URL(string: "tel://" + "\(phoneNum.filter { $0.isNumber })") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension SummaryInformationView {
    
    func setUIContents(store: Store) {
        resetUIContents()
        viewModel.action(input: .setUIContents(store: store))
    }
    
    func resetUIContents() {
        storeTitle.text = nil
        category.text = nil
        storeOpenClosed.text = nil
        openingHour.text = nil
        certificationStackView.clear()
        callDisposable?.dispose()
        storeCallButton.isHidden = true
        storeImageView.image = .basicStore
    }
    
}
