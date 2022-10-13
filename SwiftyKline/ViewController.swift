//
//  ViewController.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2022/10/2.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    // Do any additional setup after loading the view.

    view.addSubview(btn)
    btn.sizeToFit()
    btn.center = view.center
  }

  lazy var btn: UIButton = {
    let ret = UIButton(type: .custom)
    ret.setTitle("go", for: .normal)
    ret.setTitleColor(.black, for: .normal)
    ret.addTarget(self, action: #selector(jump), for: .touchUpInside)
    return ret
  }()

  @objc func jump() {
    let vc = KlineViewController()
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }

}

