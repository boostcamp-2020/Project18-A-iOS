//
//  TravelProfileViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

protocol TravelProfileDelegate: AnyObject {
    func deleteTravel(id: UUID?)
    func updateTravel(id: UUID?, newTitle: String?, newMemo: String?, newStartDate: Date?, newEndDate: Date?, newCoverImage: Data?, newBudget: Double?, newExchangeRate: Double?)
}

class TravelProfileViewController: UIViewController {
    // TODO: - private으로 감추고 주입하는 방법 생각해보기
    weak var travelItemViewModel: TravelItemPresentable?
    weak var profileDelegate: TravelProfileDelegate?
    
    @IBOutlet weak var travelMemoLabel: UILabel!
    @IBOutlet weak var travelTitleLabel: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarBackground: UIView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        let memoTap = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        let coverImageTap = UITapGestureRecognizer(target: self, action: #selector(coverImageTapped))
        
        travelTitleLabel.addGestureRecognizer(titleTap)
        travelMemoLabel.addGestureRecognizer(memoTap)
        coverImage.addGestureRecognizer(coverImageTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTravelProfile()
    }
    
    private func setupTravelProfile() {
        self.travelTitleLabel.text = travelItemViewModel?.title
        if let memo = travelItemViewModel?.memo, !memo.isEmpty {
            travelMemoLabel.text = memo
        } else {
            travelMemoLabel.text = "여행을 위한 메모를 입력해보세요"
        }
        self.countryNameLabel.text = travelItemViewModel?.countryName
        self.flagImage.image = UIImage(data: travelItemViewModel?.flagImage ?? Data())
        self.startDatePicker.date = travelItemViewModel?.startDate ?? Date()
        self.endDatePicker.date = travelItemViewModel?.endDate ?? Date()
        self.coverImage.image = UIImage(data: travelItemViewModel?.coverImage ?? Data())
        
        let percentage = travelItemViewModel?.expensePercentage ?? 0
        self.progressPercentageLabel.text = String(format: "%d%%", Int(percentage * 100))
        self.progressBarWidthConstraint.constant = progressBarBackground.frame.width * CGFloat(percentage)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "여행을 삭제하시겠습니까?", message: "저장된 여행 정보가 사라집니다.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            self.profileDelegate?.deleteTravel(id: self.travelItemViewModel?.id)
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func startDateSelected(_ sender: UIDatePicker) {
        endDatePicker.minimumDate = startDatePicker.date
        profileDelegate?.updateTravel(id: travelItemViewModel?.id, newTitle: travelItemViewModel?.title, newMemo: travelItemViewModel?.memo, newStartDate: sender.date, newEndDate: endDatePicker?.date, newCoverImage: travelItemViewModel?.coverImage, newBudget: travelItemViewModel?.budget, newExchangeRate: travelItemViewModel?.exchangeRate)
    }
    
    @IBAction func endDateSelected(_ sender: UIDatePicker) {
        startDatePicker.maximumDate = endDatePicker.date
        profileDelegate?.updateTravel(id: travelItemViewModel?.id, newTitle: travelItemViewModel?.title, newMemo: travelItemViewModel?.memo, newStartDate: startDatePicker.date, newEndDate: sender.date, newCoverImage: travelItemViewModel?.coverImage, newBudget: travelItemViewModel?.budget, newExchangeRate: travelItemViewModel?.exchangeRate)
    }
    
    @objc func titleLabelTapped() {
        TitleEditViewController.present(at: self, previousTitle: travelTitleLabel.text ?? "") { [weak self] (newTitle) in
            let updatingTitle = newTitle.isEmpty ? self?.travelItemViewModel?.countryName : newTitle
            self?.travelTitleLabel.text = updatingTitle
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: updatingTitle, newMemo: self?.travelItemViewModel?.memo, newStartDate: self?.travelItemViewModel?.startDate, newEndDate: self?.travelItemViewModel?.endDate, newCoverImage: self?.travelItemViewModel?.coverImage, newBudget: self?.travelItemViewModel?.budget, newExchangeRate: self?.travelItemViewModel?.exchangeRate)
        }
    }
    
    @objc func memoLabelTapped() {
        MemoEditViewController.present(at: self, memoType: .travelMemo, previousMemo: self.travelItemViewModel?.memo) { [weak self] (newMemo) in
            self?.travelMemoLabel.text = newMemo.isEmpty ? "여행을 위한 메모를 입력해보세요" : newMemo
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: self?.travelItemViewModel?.title, newMemo: newMemo, newStartDate: self?.travelItemViewModel?.startDate, newEndDate: self?.travelItemViewModel?.endDate, newCoverImage: self?.travelItemViewModel?.coverImage, newBudget: self?.travelItemViewModel?.budget, newExchangeRate: self?.travelItemViewModel?.exchangeRate)
        }
    }
    
    @objc func coverImageTapped() {
        openPhotoLibrary()
    }
    
    private func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
}

extension TravelProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            coverImage.image = newImage
            
            profileDelegate?.updateTravel(id: travelItemViewModel?.id, newTitle: travelItemViewModel?.title, newMemo: travelItemViewModel?.memo, newStartDate: travelItemViewModel?.startDate, newEndDate: travelItemViewModel?.endDate, newCoverImage: newImage.pngData(), newBudget: travelItemViewModel?.budget, newExchangeRate: travelItemViewModel?.exchangeRate)
        }
        dismiss(animated: true, completion: nil)
    }
}
