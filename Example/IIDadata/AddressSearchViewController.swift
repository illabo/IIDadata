//
//  AddressSearchViewController.swift
//  IIDadata_Example
//
//  Created by Yachin Ilya on 12.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import IIDadata

class AddressSearchViewController: UIViewController {
    
    @IBOutlet weak var grabberView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var dadata: DadataSuggestions?
    private var suggestions: [String] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    private var indicator: IndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchBar.searchBarStyle = .minimal
        if #available(iOS 13.0, *) {
            drawGrabber()
        } else {
            grabberView.constraints.forEach{
                if $0.constant == 20 {
                    $0.constant = 0
                }
            }
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "JustCell")
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func setupDadata(with apiKey: String){
        dadata = DadataSuggestions(apiKey: apiKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicator?.removeFromSuperview()
        indicator = nil
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func drawGrabber(){
        
        let shape = CAShapeLayer()
        grabberView.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 5
        shape.lineJoin = .round
        shape.strokeColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        
        let path = UIBezierPath()//roundedRect: CGRect(x: (view.frame.size.width/2)-10, y: 10, width: 20, height: 5), cornerRadius: 2.5
        path.move(to: CGPoint(x: (view.frame.size.width/2)-15, y: 15))
        path.addLine(to: CGPoint(x: (view.frame.size.width/2)+15, y: 15))
        path.close()
        
        shape.path = path.cgPath
    }
    
}

extension AddressSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JustCell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
}

extension AddressSearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let indicator = IndicatorView()
        self.view.addSubview(indicator)
        indicator.bounds = CGRect(x: 0, y: 0, width: 180, height: 180)
        indicator.center = self.view.center
        self.indicator = indicator
        dadata?.suggestAddress(text){[weak self] r in
            DispatchQueue.main.async {
                self?.indicator?.removeFromSuperview()
                self?.indicator = nil
                switch r{
                case .success(let dadataData):
                    print(dadataData)
                    if let dsr = dadataData.suggestions?.compactMap({ $0.value }) {
                        self?.suggestions = dsr
                    }
                case .failure(let e):
                    print(e)
                    self?.suggestions = [e.localizedDescription]
                }
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            suggestions = []
        }
    }
}
