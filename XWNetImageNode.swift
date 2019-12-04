//
//  XWNetImageNode.swift
//  MIKS
//
//  Created by Civel Xu on 2019/11/27.
//  Copyright © 2019 xuxiwen. All rights reserved.
//

import UIKit
import Kingfisher

public class XWNetImageNode: ASControlNode {

    private lazy var imageView: AnimatedImageView = {
        let _imageView = AnimatedImageView()
        _imageView.contentMode = .scaleAspectFill
        _imageView.clipsToBounds = true
        return _imageView
    }()

    public func safeImageView(handle: @escaping (_ imageView: UIImageView) -> Void) {
        safeMainQueue { [weak self] in
            guard let `self` = self else { return }
            handle(self.imageView)
        }
    }

    lazy var imageNode: ASDisplayNode = {
        let _imageNode = ASDisplayNode { [weak self] () -> UIView in
            return (self?.imageView ?? UIView())
        }
        return _imageNode
    }()

    override init() {
        super.init()
        addSubnode(imageNode)
    }

    private func safeMainQueue(closure: @escaping () -> Void) {
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }

    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: imageNode)
    }

}
