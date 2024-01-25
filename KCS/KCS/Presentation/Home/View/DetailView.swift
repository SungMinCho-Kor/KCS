//
//  DetailView.swift
//  KCS
//
//  Created by 조성민 on 1/24/24.
//

import UIKit
import RxSwift
import RxRelay

final class DetailView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private lazy var storeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 24, weight: .bold)
        label.textColor = UIColor.primary2
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var category: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        label.textColor = UIColor.grayLabel
        
        return label
    }()
    
    private lazy var certificationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    private let divideView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.divideView
        
        return view
    }()
    
    private let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLayerCorner(cornerRadius: 6)
        imageView.clipsToBounds = true
        imageView.image = UIImage.basicStore
        
        return imageView
    }()
    
    private let clockIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage.clockIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var storeOpenClosed: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        
        return label
    }()
    
    private lazy var openingHour: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 12, weight: .regular)
        label.textColor = UIColor.grayLabel
        
        return label
    }()
    
    private let openingHoursStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let phoneIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage.phoneIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let phoneNumber: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        
        return label
    }()
    
    private let addressIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage.addressIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let address: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendard(size: 13, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let dismissIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.swipeBar
        view.layer.cornerRadius = 2
        
        return view
    }()
    
    private let viewModel: DetailViewModel
    private lazy var addressConstraint = address.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
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

private extension DetailView {
    
    func bind() {
        viewModel.thumbnailImageOutput
            .subscribe(onNext: { [weak self] data in
                self?.storeImageView.image = UIImage(data: data)
            })
            .disposed(by: disposeBag)
        
        viewModel.openClosedOutput
            .subscribe(onNext: { [weak self] openClosedInformation in
                self?.removeOpeningHourStackView()
                let openClosedContent = openClosedInformation.openClosedContent
                if openClosedContent.openClosedType == .none {
                    self?.storeOpenClosed.text = "영업시간 정보 없음"
                    self?.storeOpenClosed.textColor = .black
                    self?.openingHour.text = openClosedContent.openClosedType.rawValue
                    self?.addressConstraint.constant = -174
                } else {
                    self?.storeOpenClosed.text = openClosedContent.openClosedType.rawValue
                    self?.storeOpenClosed.textColor = UIColor.goodPrice
                    self?.openingHour.text = openClosedContent.openingHour
                    self?.addressConstraint.constant = -16
                    
                    let today = Date().weekDay
                    let detailOpeningHour = openClosedInformation.detailOpeningHour
                    for idx in today..<today + 7 {
                        let weekDayIndex = idx % 7 == 0 ? 7 : idx % 7
                        if let weekday = Day.allCases.filter({ $0.index == weekDayIndex }).first,
                           let openingHour = detailOpeningHour[weekday] {
                            var cell: OpeningHoursCellView
                            if weekDayIndex == today {
                                cell = OpeningHoursCellView(
                                    weekday: weekday,
                                    openingHour: openingHour,
                                    isToday: true
                                )
                            } else {
                                cell = OpeningHoursCellView(
                                    weekday: weekday,
                                    openingHour: openingHour
                                )
                            }
                            self?.openingHoursStackView.addArrangedSubview(cell)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
}

private extension DetailView {
    
    func setBackgroundColor() {
        backgroundColor = .white
    }
    
    func addUIComponents() {
        addSubview(storeTitle)
        addSubview(category)
        addSubview(certificationStackView)
        addSubview(divideView)
        addSubview(storeImageView)
        addSubview(clockIcon)
        addSubview(storeOpenClosed)
        addSubview(openingHour)
        addSubview(openingHoursStackView)
        addSubview(phoneIcon)
        addSubview(phoneNumber)
        addSubview(addressIcon)
        addSubview(address)
        addSubview(dismissIndicatorView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            storeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            storeTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            category.topAnchor.constraint(equalTo: storeTitle.bottomAnchor, constant: 8),
            category.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            certificationStackView.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 11),
            certificationStackView.leadingAnchor.constraint(equalTo: storeTitle.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            divideView.topAnchor.constraint(equalTo: certificationStackView.bottomAnchor, constant: 20),
            divideView.leadingAnchor.constraint(equalTo: leadingAnchor),
            divideView.trailingAnchor.constraint(equalTo: trailingAnchor),
            divideView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        NSLayoutConstraint.activate([
            storeImageView.topAnchor.constraint(equalTo: divideView.bottomAnchor, constant: 16),
            storeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            storeImageView.widthAnchor.constraint(equalToConstant: 150),
            storeImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        NSLayoutConstraint.activate([
            clockIcon.centerYAnchor.constraint(equalTo: storeOpenClosed.centerYAnchor),
            clockIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            clockIcon.heightAnchor.constraint(equalToConstant: 14),
            clockIcon.widthAnchor.constraint(equalToConstant: 14)
        ])
        
        NSLayoutConstraint.activate([
            storeOpenClosed.topAnchor.constraint(equalTo: divideView.bottomAnchor, constant: 16),
            storeOpenClosed.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        ])
        
        NSLayoutConstraint.activate([
            openingHour.bottomAnchor.constraint(equalTo: storeOpenClosed.bottomAnchor),
            openingHour.leadingAnchor.constraint(equalTo: storeOpenClosed.trailingAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            openingHoursStackView.topAnchor.constraint(equalTo: storeOpenClosed.bottomAnchor, constant: 8),
            openingHoursStackView.leadingAnchor.constraint(equalTo: storeOpenClosed.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            phoneIcon.centerYAnchor.constraint(equalTo: phoneNumber.centerYAnchor),
            phoneIcon.leadingAnchor.constraint(equalTo: clockIcon.leadingAnchor),
            phoneIcon.heightAnchor.constraint(equalToConstant: 14),
            phoneIcon.widthAnchor.constraint(equalToConstant: 13)
        ])
        
        NSLayoutConstraint.activate([
            phoneNumber.topAnchor.constraint(equalTo: openingHoursStackView.bottomAnchor, constant: 20),
            phoneNumber.leadingAnchor.constraint(equalTo: phoneIcon.trailingAnchor, constant: 11)
        ])
        
        NSLayoutConstraint.activate([
            addressIcon.centerYAnchor.constraint(equalTo: address.centerYAnchor),
            addressIcon.leadingAnchor.constraint(equalTo: clockIcon.leadingAnchor),
            addressIcon.heightAnchor.constraint(equalToConstant: 16),
            addressIcon.widthAnchor.constraint(equalToConstant: 11)
        ])
        
        NSLayoutConstraint.activate([
            address.topAnchor.constraint(equalTo: phoneNumber.bottomAnchor, constant: 20),
            address.leadingAnchor.constraint(equalTo: addressIcon.trailingAnchor, constant: 13),
            addressConstraint
        ])
        
        NSLayoutConstraint.activate([
            dismissIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dismissIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dismissIndicatorView.widthAnchor.constraint(equalToConstant: 35),
            dismissIndicatorView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func removeOpeningHourStackView() {
        let subviews = openingHoursStackView.arrangedSubviews
        openingHoursStackView.arrangedSubviews.forEach {
            openingHoursStackView.removeArrangedSubview($0)
        }
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func removeCertificationStackView() {
        let subviews = certificationStackView.arrangedSubviews
        certificationStackView.arrangedSubviews.forEach {
            certificationStackView.removeArrangedSubview($0)
        }
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func callTapped() {
        if let number = phoneNumber.text, let url = URL(string: "tel://" + "\(number.filter { $0.isNumber })") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension DetailView {
    
    func setUIContents(store: Store) {
        storeTitle.text = store.title
        category.text = store.category
        address.text = store.address
        removeCertificationStackView()
        store.certificationTypes
            .map({
                CertificationLabel(certificationType: $0, fontSize: 11)
            })
            .forEach {
                certificationStackView.addArrangedSubview($0)
            }
        if let phoneNum = store.phoneNumber {
            phoneNumber.text = phoneNum
        } else {
            phoneNumber.text = "전화번호 정보 없음"
        }
        if let url = store.localPhotos.first {
            viewModel.action(input: .setInformationView(
                openingHour: store.openingHour,
                url: url)
            )
        } else {
            storeImageView.image = UIImage.basicStore
        }
    }
    
}
