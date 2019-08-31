//
//  EndPoint.swift
//  Networking
//
//  Created by Sateesh Yegireddi on 31/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

extension UIView {
    /**
     Anchors a view using the input constraints.
     - Parameter top: The top constraint.
     - Parameter leading: The leading or left contraint.
     - Parameter bottom: The bottom constraint.
     - Parameter trailing: The trailing or right contraint.
     - Parameter padding: The padding to be applied to the constraints. Requires init with UIEdgeInsets.
     - Parameter size: The size to be added to the view. Requires init with CGSize. If all other constraints are set, sizes do not have any effect.
     */
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top { topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true }
        if let leading = leading { leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true }
        if let bottom = bottom { bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true }
        if let trailing = trailing { trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true }
        if size.width != 0 { widthAnchor.constraint(equalToConstant: size.width).isActive = true }
        if size.height != 0 { heightAnchor.constraint(equalToConstant: size.height).isActive = true }
    }
}
