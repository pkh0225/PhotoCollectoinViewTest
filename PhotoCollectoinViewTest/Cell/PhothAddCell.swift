//
//  PhothAddCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class PhothAddCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1
    @IBOutlet weak var countLabel: UILabel!

    var actionClosure: ActionClosure?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any? = nil, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return fromXibSize()
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? Int else { return }
        countLabel.text = "\(data)"
        if data > 0 {
            countLabel.textColor = .orange
        }
        else {
            countLabel.textColor = .darkGray
        }
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {

    }
    @IBAction func onAddButton(_ sender: UIButton) {
        actionClosure?(#function, nil)
    }
}
