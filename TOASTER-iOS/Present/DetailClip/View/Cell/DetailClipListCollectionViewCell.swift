//
//  DetailClipListCollectionViewCell.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

protocol DetailClipListCollectionViewCellDelegate: AnyObject {
    func modifiedButtonTapped(toastId: Int)
}

final class DetailClipListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var buttonAction: (() -> Void)?
    
    private var toastId: Int = 0
    private var isReadDimmedView: Bool = false {
        didSet {
            dimmedView.isHidden = !isReadDimmedView
            readLabel.isHidden = !isReadDimmedView
        }
    }
    
    private lazy var isClipNameLabelHidden: Bool = clipNameLabel.isHidden {
        didSet {
            clipNameLabel.isHidden = isClipNameLabelHidden
            clipNameLabel.snp.updateConstraints {
                $0.width.equalTo(clipNameLabel.intrinsicContentSize.width+16)
            }
            setupHiddenLayout(forHidden: isClipNameLabelHidden)
        }
    }
    weak var detailClipListCollectionViewCellDelegate: DetailClipListCollectionViewCellDelegate?
    
    // MARK: - UI Components
    
    private let linkImage = UIImageView()
    private let clipNameLabel = UILabel()
    private let linkTitleLabel = UILabel()
    private let linkLabel = UILabel()
    private let modifiedButton = UIButton()
    private let dimmedView = UIView()
    private let readLabel = UILabel()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension DetailClipListCollectionViewCell {
    func configureCell(forModel: DetailClipModel, index: Int, isClipHidden: Bool) {
        modifiedButton.isHidden = false
        clipNameLabel.text = forModel.toastList[index].clipTitle
        linkTitleLabel.text = forModel.toastList[index].title
        linkLabel.text = forModel.toastList[index].url
        isClipNameLabelHidden = forModel.toastList[index].clipTitle != nil ? true : false
        isReadDimmedView = forModel.toastList[index].isRead
        toastId = forModel.toastList[index].id
        
        if forModel.toastList[index].clipTitle != nil && !isClipHidden {
            clipNameLabel.text = forModel.toastList[index].clipTitle
            isClipNameLabelHidden = false
        } else {
            isClipNameLabelHidden = true
        }
        
        if let imageURL = forModel.toastList[index].imageURL {
            linkImage.kf.setImage(with: URL(string: imageURL))
        } else {
            linkImage.image = .imgThumbnail
        }
    }
    
    func configureCell(forModel: RecentLinkModel, isClipHidden: Bool) {
        modifiedButton.isHidden = false
        clipNameLabel.text = forModel.toastTitle
        linkTitleLabel.text = forModel.toastTitle
        linkLabel.text = forModel.linkUrl
        isClipNameLabelHidden = forModel.categoryTitle != nil ? true : false
        isReadDimmedView = forModel.isRead
        toastId = forModel.toastId
        
        if forModel.categoryTitle != nil && !isClipHidden {
            clipNameLabel.text = forModel.categoryTitle
            isClipNameLabelHidden = false
        } else {
            isClipNameLabelHidden = true
        }
        
        if let imageURL = forModel.thumbnailUrl {
            linkImage.kf.setImage(with: URL(string: imageURL))
        } else {
            linkImage.image = .imgThumbnail
        }
    }
    
    func configureCell(forModel: SearchResultDetailClipModel, forText: String) {
        modifiedButton.isHidden = true
        linkTitleLabel.text = forModel.title
        linkTitleLabel.asFont(targetString: forText, font: .suitBold(size: 16))
        linkLabel.text = forModel.link
        isReadDimmedView = forModel.isRead
        
        if let clipTitle = forModel.clipTitle {
            clipNameLabel.text = clipTitle
            isClipNameLabelHidden = false
        } else {
            isClipNameLabelHidden = true
        }
        
        if let imageURL = forModel.imageURL {
            linkImage.kf.setImage(with: URL(string: imageURL))
        } else {
            linkImage.image = .imgThumbnail
        }
    }
}

// MARK: - Private Extensions

private extension DetailClipListCollectionViewCell {
    func setupStyle() {
        backgroundColor = .toasterWhite
        makeRounded(radius: 12)
        
        linkImage.do {
            $0.makeRounded(radius: 8)
        }
        
        clipNameLabel.do {
            $0.backgroundColor = .toaster50
            $0.makeRounded(radius: 8)
            $0.textColor = .toasterPrimary
            $0.font = .suitMedium(size: 10)
            $0.textAlignment = .center
        }
        
        linkTitleLabel.do {
            $0.font = .suitMedium(size: 16)
            $0.textColor = .black850
        }
        
        linkLabel.do {
            $0.font = .suitMedium(size: 10)
            $0.textColor = .gray200
        }
        
        modifiedButton.do {
            $0.setImage(.icMore24, for: .normal)
            $0.frame = contentView.bounds
        }
        
        dimmedView.do {
            $0.backgroundColor = .black900.withAlphaComponent(0.5)
            $0.makeRounded(radius: 8)
        }
        
        readLabel.do {
            $0.text = "열람"
            $0.font = .suitMedium(size: 12)
            $0.textColor = .gray100
        }
    }
    
    func setupHierarchy() {
        contentView.addSubviews(linkImage, clipNameLabel, linkTitleLabel, linkLabel, modifiedButton)
        linkImage.addSubviews(dimmedView, readLabel)
    }
    
    func setupLayout() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        linkImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.leading.equalToSuperview().inset(12)
            $0.size.equalTo(74)
        }
        
        linkLabel.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(12)
            $0.leading.equalTo(linkImage.snp.trailing).offset(12)
        }
        
        modifiedButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.trailing.equalToSuperview().inset(8)
        }
        
        clipNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(linkImage.snp.trailing).offset(12)
            $0.height.equalTo(20)
            $0.width.equalTo(clipNameLabel.intrinsicContentSize.width+16)
        }
        
        linkTitleLabel.snp.makeConstraints {
            $0.top.equalTo(clipNameLabel.snp.bottom).offset(6)
            $0.leading.equalTo(linkImage.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(44)
        }
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        readLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupHiddenLayout(forHidden: Bool) {
        if forHidden {
            linkTitleLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.leading.equalTo(linkImage.snp.trailing).offset(12)
                $0.trailing.equalToSuperview().inset(44)
            }
        } else {
            linkTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(clipNameLabel.snp.bottom).offset(6)
                $0.leading.equalTo(linkImage.snp.trailing).offset(12)
                $0.trailing.equalToSuperview().inset(12)
            }
        }
    }
    
    func setupAddTarget() {
        modifiedButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc
    func buttonTapped() {
        buttonAction?()
        detailClipListCollectionViewCellDelegate?.modifiedButtonTapped(toastId: toastId)
    }
}
