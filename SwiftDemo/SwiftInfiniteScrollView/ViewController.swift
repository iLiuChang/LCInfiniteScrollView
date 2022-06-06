//
//  ViewController.swift
//  SwiftInfiniteScrollView
//
//  Created by 刘畅 on 2022/6/6.
//

import UIKit

class ViewController: UIViewController,LCInfiniteScrollViewDelegate {

    let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.magenta]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let banner = LCInfiniteScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
        banner.delegate = self
        banner.autoScroll = true
        self.view.addSubview(banner)
    }

    func numberOfIndexes(in infiniteScrollView: LCInfiniteScrollView) -> Int {
        colors.count
    }
    
    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, displayReusableView view: UIView, forIndex index: Int) {
        view.backgroundColor = colors[index]
    }
    
    func reusableView(in infiniteScrollView: LCInfiniteScrollView) -> UIView {
        return UIView()
    }
    
    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didScrollAt index: Int) {
        print("didScrollAt:\(index)")
    }
    
    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didSelectAt index: Int) {
        print("didSelectedAt:\(index)")
    }


}

