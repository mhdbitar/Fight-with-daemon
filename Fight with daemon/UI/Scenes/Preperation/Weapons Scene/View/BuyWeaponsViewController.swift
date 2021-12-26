//
//  BuyWeaponsViewController.swift
//  Fight with daemon
//
//  Created by Mohammad Bitar on 12/21/21.
//

import UIKit
import Combine

final class BuyWeaponsViewController: UIViewController {
    
    @IBOutlet weak var boardView: UIView! {
        didSet {
            self.boardView.setRoundedConrerWith(corner: 12, width: 1, color: .black.withAlphaComponent(0.2))
        }
    }
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var weaponsCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    
    private var viewModel: BuyWeaponsViewModel!
    private var delegate: GameFlowViewDelegate?
    private var cancellables: Set<AnyCancellable> = []
    private let padding: CGFloat = 20
    
    convenience init(viewModel: BuyWeaponsViewModel, delegate: GameFlowViewDelegate) {
        self.init()
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.title
        
        setupCollectionView()
        
        viewModel.fetchWeapons()
        bindViewModel()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WeaponCollectionViewCell.self)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.reloadData()
    }
    
    private func bindViewModel() {
        bindWeapons()
        bindAmount()
        bindSelectedWeapons()
    }
    
    private func bindWeapons() {
        viewModel.$weapons.sink { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }.store(in: &cancellables)
    }
    
    private func bindAmount() {
        viewModel.$amount.sink { [weak self] amount in
            guard let self = self else { return }
            self.amountLabel.text = "Amount: \(amount)"
        }.store(in: &cancellables)
    }
    
    private func bindSelectedWeapons() {
        viewModel.$selectedWeapons.sink { [weak self] weapons in
            guard let self = self else { return }
            self.weaponsCountLabel.text = "Selected Weapons count: \(weapons.count)"
            self.startButton.isEnabled = !weapons.isEmpty
        }.store(in: &cancellables)
    }
        
    @IBAction func startBtnTapped(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        delegate.didReceiveWeapons(weapons: viewModel.selectedWeapons, remainingAmount: viewModel.amount)
    }
    
    @IBAction func resetBtnTapped(_ sender: UIButton) {
        viewModel.reset()
    }
}

extension BuyWeaponsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.weapons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(WeaponCollectionViewCell.self, indexPath: indexPath) else { return UICollectionViewCell() }        
        cell.weapon = viewModel.weapons[indexPath.row]
        return cell
    }
}

extension BuyWeaponsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - padding) / 2
        return CGSize(width: width, height: width)
    }
}

extension BuyWeaponsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectWeapon(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.removeWeapon(at: indexPath.row)
    }
}