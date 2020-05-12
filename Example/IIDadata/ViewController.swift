//
//  ViewController.swift
//  IIDadata
//
//  Created by Ilya Yachin on 05/11/2020.
//  Copyright (c) 2020 Ilya Yachin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var confirmApiKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        confirmApiKeyButton.addTarget(self, action: #selector(presentAddressSearch), for: .touchUpInside)
        apiKeyTextField.clearButtonMode = .always
        apiKeyTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func presentAddressSearch(){
        guard let apiKey = apiKeyTextField.text else { return }
        if #available(iOS 13.0, *) {
            if let asvc = storyboard?.instantiateViewController(identifier: "AddressSearch") as? AddressSearchViewController {
                asvc.setupDadata(with: apiKey)
                asvc.modalPresentationStyle = .formSheet
                present(asvc, animated: true, completion: nil)
            }
        } else {
            if let asvc = storyboard?.instantiateViewController(withIdentifier: "AddressSearch") as? AddressSearchViewController {
                asvc.setupDadata(with: apiKey)
                navigationController?.pushViewController(asvc, animated: true)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presentAddressSearch()
        return true
    }
}

