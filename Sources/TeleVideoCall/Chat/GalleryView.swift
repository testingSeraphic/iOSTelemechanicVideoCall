//
//  GalleryView.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Manpreet Singh on 03/12/24.
//

import Foundation
import UIKit
import Photos

@IBDesignable
class GalleryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {

    var onImageTap: ((UIImage, String) -> Void)?

    private var assets: [PHAsset] = []
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.resizeMode = .none
        return options
    }()
    
    private let targetSize = PHImageManagerMaximumSize

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 141, height: 141)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        checkPhotoLibraryPermission()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        checkPhotoLibraryPermission()
    }

    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func scrollToFirstItem() {
        // check if there are any items in the collection view
        if assets.count > 0 {
            let inset = collectionView.contentInset
            let offset = CGPoint(x: -inset.left, y: -inset.top)
            collectionView.setContentOffset(offset, animated: false)
        }
    }
    
    private func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if #available(iOS 14, *) {
                if status == .authorized || status == .limited {
                    self.fetchAssets()
                } else {
                    print("Permission denied")
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private func fetchAssets() {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            self.assets = fetchResult.objects(at: IndexSet(0..<fetchResult.count))

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        let asset = assets[indexPath.item]
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: imageRequestOptions) { image, _ in
            cell.imageView.image = image
        }

        return cell
    }

    // MARK: - UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let assetsToPrefetch = indexPaths.map { assets[$0.item] }
        imageManager.startCachingImages(for: assetsToPrefetch, targetSize: targetSize, contentMode: .aspectFill, options: imageRequestOptions)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let assetsToCancel = indexPaths.map { assets[$0.item] }
        imageManager.stopCachingImages(for: assetsToCancel, targetSize: targetSize, contentMode: .aspectFill, options: imageRequestOptions)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        
        // Get the image name from the PHAssetResource
        let assetResources = PHAssetResource.assetResources(for: asset)
        let imageName = assetResources.first?.originalFilename ?? "Unknown"
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: imageRequestOptions) { [weak self] image, _ in
            if let image = image {
                // Pass both the image and its name using a tuple
                self?.onImageTap?(image, imageName)
            }
        }
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 0.929, green: 0.933, blue: 0.949, alpha: 0.8).cgColor
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
