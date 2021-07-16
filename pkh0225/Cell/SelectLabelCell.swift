//
//  SelectLabelCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit
struct SelectLabelCellModel {
    var title: String = ""
}

class SelectLabelCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var titleLabel: UILabel!

    var actionClosure: ActionClosure?
    var data: SelectLabelCellModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromNibSize().h)
    }

    func configure(_ data: Any?) {
        guard let data = data as? SelectLabelCellModel else { return }
        self.data = data

        titleLabel.text = data.title
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
        print("title: \(data?.title ?? "")")

        actionClosure?(#function, data)
    }

}