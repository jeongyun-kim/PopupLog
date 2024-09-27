//
//  CalendarCell.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//


import UIKit
import FSCalendar
import SnapKit

final class CalendarCell: FSCalendarCell {
    static let identifier = "CalendarCell"
    
    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.opacity = 0.5
        imageView.layer.cornerRadius = Resources.Radius.image
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarhchy()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        thumbImageView.layer.opacity = 0.5
    }
    
    private func setupHierarhchy() {
        contentView.addSubview(thumbImageView)
    }
    
    private func setupConstraints() {
        thumbImageView.snp.makeConstraints { make in
            make.center.equalTo(titleLabel)
            make.size.equalTo((contentView.bounds.height-12))
        }
    }
    
    func configureCell(_ log: Log?) {
        guard let log else { return }
        var image = DocumentManager.shared.loadImage(id: "\(log.id)") ?? Resources.Images.ticket
        thumbImageView.image = image
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                thumbImageView.layer.opacity = 0.1
            } else {
                thumbImageView.layer.opacity = 0.5
            }
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
