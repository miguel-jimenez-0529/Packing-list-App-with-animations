/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class ViewController: UIViewController {
    
    //MARK:- IB outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonMenu: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var menuHeighContraint : NSLayoutConstraint!
    @IBOutlet weak var addBtnTrailingContraint : NSLayoutConstraint!
    
    @IBOutlet weak var titleLabelCenterY_OpenContraint : NSLayoutConstraint!
    @IBOutlet weak var titleLabelCenterYContraint : NSLayoutConstraint!
    
    //MARK:- further class variables
    
    var slider: HorizontalItemList!
    var menuIsOpen = false
    var items: [Int] = [5, 6, 7]
    
    //MARK:- class methods
    
    @IBAction func toggleMenu(_ sender: AnyObject) {
        menuIsOpen = !menuIsOpen
        
        titleLabelCenterYContraint.isActive = !menuIsOpen
        titleLabelCenterY_OpenContraint.isActive = menuIsOpen
        
        titleLabel.superview?.constraints.forEach({ (constraint) in
            if  constraint.firstItem === titleLabel &&
                constraint.firstAttribute == .centerX {
                constraint.constant = menuIsOpen ? -100 : 0
            }
//            if constraint.identifier == "TItleCenterY" {
//                constraint.isActive = false
//
//                let newConstraint = NSLayoutConstraint(
//                    item: titleLabel,
//                    attribute: NSLayoutAttribute.centerY,
//                    relatedBy: NSLayoutRelation.equal,
//                    toItem: titleLabel.superview!,
//                    attribute: NSLayoutAttribute.centerY,
//                    multiplier: menuIsOpen ? 0.67 : 1.0,
//                    constant: 5)
//                newConstraint.identifier = "TItleCenterY"
//                newConstraint.isActive = true
//            }

        })
        
        addBtnTrailingContraint.constant = menuIsOpen ? 16 : 8
        menuHeighContraint.constant = menuIsOpen ? 200 : 60
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 10.0,
                       options: [.allowUserInteraction],
                       animations: {
            let angle : CGFloat = self.menuIsOpen ? CGFloat.pi / 4 : 0
            self.view.layoutIfNeeded()
            
            self.buttonMenu.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: nil)
    }
    
    func showItem(_ index: Int) {
        let imageView = makeImageView(index: index)
        view.addSubview(imageView)
        let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height)
        let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -50)
        let conRatio = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        NSLayoutConstraint.activate([conX,conBottom,conWidth,conRatio])
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            conBottom.constant =  -imageView.frame.height / 2
            conWidth.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        delay(seconds: 1) {
            UIView.transition(with: imageView, duration: 1, options: [.transitionFlipFromBottom], animations: {
                imageView.isHidden  = true
            }, completion: { _  in
                imageView.removeFromSuperview()
            })
        }
    }
    
    func transitionCloseMenu() {
        delay(seconds: 0.35, completion: {
            self.toggleMenu(self)
        })
        
        let titleBar = slider.superview!
        
        UIView.transition(
            with: titleBar,
            duration: 0.5,
            options: [.curveEaseOut , .transitionFlipFromBottom] ,
            animations: {
                self.slider.removeFromSuperview()
        }) { (_) in
            titleBar.addSubview(self.slider)
        }
    }
}

let itemTitles = ["Icecream money", "Great weather", "Beach ball", "Swim suit for him", "Swim suit for her", "Beach games", "Ironing board", "Cocktail mood", "Sunglasses", "Flip flops"]

// MARK:- View Controller

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func makeImageView(index: Int) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "summericons_100px_0\(index).png"))
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    func makeSlider() {
        slider = HorizontalItemList(inView: view)
        slider.didSelectItem = {index in
            self.items.append(index)
            self.tableView.reloadData()
            self.transitionCloseMenu()
        }
        self.titleLabel.superview?.addSubview(slider)
    }
    
    // MARK: View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSlider()
        self.tableView?.rowHeight = 54.0
    }
    
    // MARK: Table View methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.accessoryType = .none
        cell.textLabel?.text = itemTitles[items[indexPath.row]]
        cell.imageView?.image = UIImage(named: "summericons_100px_0\(items[indexPath.row]).png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItem(items[indexPath.row])
    }
    
}

