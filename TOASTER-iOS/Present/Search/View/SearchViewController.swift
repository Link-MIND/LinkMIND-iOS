//
//  SearchViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import UIKit

import SnapKit
import Then

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = SearchViewModel()
    
    private var isSearching: Bool = true {
        didSet {
            searchButton.isHidden = !isSearching
            clearButton.isHidden = isSearching
            searchResultCollectionView.isHidden = isSearching
        }
    }
    
    // MARK: - UI Properties
    
    private let navigationBar: UIView = UIView()
    private let searchTextField: UITextField = UITextField()
    private let backButton: UIButton = UIButton()
    private let searchButton: UIButton = UIButton()
    private let clearButton: UIButton = UIButton()
    
    private let emptyView: SearchEmptyResultView = SearchEmptyResultView()
    private let searchResultCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar()
    }
}

// MARK: - Private Extensions

private extension SearchViewController {
    func setupStyle() {
        isSearching = true
        hideKeyboard()
        
        view.backgroundColor = .toasterBackground
        
        navigationBar.do {
            $0.backgroundColor = .toasterBackground
        }
        
        backButton.do {
            $0.setImage(ImageLiterals.Common.arrowLeft, for: .normal)
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        
        searchButton.do {
            $0.setImage(ImageLiterals.Search.searchIcon, for: .normal)
            $0.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        }
        
        clearButton.do {
            $0.setImage(ImageLiterals.Search.searchCancle, for: .normal)
            $0.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        }
        
        searchTextField.do {
            $0.makeRounded(radius: 12)
            $0.addPadding(left: 12, right: 44)
            $0.backgroundColor = .gray50
            $0.placeholder = "검색어를 입력해주세요"
            $0.becomeFirstResponder()
        }
        
        emptyView.do {
            $0.isHidden = true
        }
        
        searchResultCollectionView.do {
            $0.register(ClipListCollectionViewCell.self, forCellWithReuseIdentifier: ClipListCollectionViewCell.className)
            $0.register(DetailClipListCollectionViewCell.self, forCellWithReuseIdentifier: DetailClipListCollectionViewCell.className)
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.clipsToBounds = true
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(navigationBar, emptyView, searchResultCollectionView)
        navigationBar.addSubviews(backButton, searchTextField)
        searchTextField.addSubviews(searchButton, clearButton)
    }
    
    func setupLayout() {
        navigationBar.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        [searchButton, clearButton].forEach {
            $0.snp.makeConstraints {
                $0.width.height.equalTo(20)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(12)
            }
        }
        
        searchTextField.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(backButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        emptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom).offset(view.convertByHeightRatio(176))
        }
        
        searchResultCollectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupDelegate() {
        searchTextField.delegate = self
        searchResultCollectionView.delegate = self
        searchResultCollectionView.dataSource = self
    }
    
    func setupViewModel() {
        viewModel.setupDataChangeAction(changeAction: reloadCollectionView,
                                        emptyAction: reloadEmptyView,
                                        forUnAuthorizedAction: unAuthorizedAction)
    }
    
    func reloadCollectionView() {
        emptyView.isHidden = true
        searchResultCollectionView.reloadData()
        searchResultCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func reloadEmptyView() {
        emptyView.isHidden = false
        searchResultCollectionView.reloadData()
        searchResultCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func fetchSearchResult() {
        isSearching = false
        view.endEditing(true)
        
        if let text = searchTextField.text {
            viewModel.fetchSearchResult(forText: text)
        }
    }
    
    func unAuthorizedAction() {
        self.changeViewController(viewController: LoginViewController())
    }
    
    @objc func searchButtonTapped() {
        fetchSearchResult()
    }
    
    @objc func clearButtonTapped() {
        isSearching = true
        searchTextField.text = nil
        searchTextField.becomeFirstResponder()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fetchSearchResult()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isSearching = true
        return true
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate { }

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.searchResultData.detailClipList.count
        case 1:
            return viewModel.searchResultData.clipList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailClipListCollectionViewCell.className, for: indexPath) as? DetailClipListCollectionViewCell,
                    let text = searchTextField.text else { return UICollectionViewCell() }
            cell.configureCell(forModel: viewModel.searchResultData.detailClipList[indexPath.item],
                               forText: text)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClipListCollectionViewCell.className, for: indexPath) as? ClipListCollectionViewCell,
                  let text = searchTextField.text
            else { return UICollectionViewCell() }
            cell.configureCell(forModel: viewModel.searchResultData.clipList[indexPath.item], forText: text)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.convertByWidthRatio(335), height: 98)
        case 1:
            return CGSize(width: collectionView.convertByWidthRatio(335), height: 52)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
