//
//  ViewController.swift
//  RxSwift+TableView
//
//  Created by Irvin Leon on 8/26/19.
//  Copyright © 2019 Irvin Leon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let places: BehaviorRelay<[Place]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
        drawData()
        removeItem()
        
    }
    @IBAction func addAction(_ sender: Any) {
        let new = Place(name: "customized", desc: "rofl this is example", url: "http://google.com")
        places.accept(places.value + [new])
    }
    
    func drawData() {
        places.bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, model, cell in
            cell.textLabel?.text = "\(model.name), \(model.desc)"
            }.disposed(by: disposeBag)
    }
    
    func removeItem() {
        tableView.rx.itemDeleted
            .subscribe {
                var newPlaces = self.places.value
                newPlaces.remove(at: $0.element?.row ?? 0)
                self.places.accept(newPlaces)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        if let url = URL(string: "https://api.myjson.com/bins/16w6h0") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let places = try JSONDecoder().decode([Place].self, from: data)
                        self.places.accept(places)
                    } catch let error {
                        print(error)
                    }
                }
                }.resume()
        }
    }


}

struct Place: Decodable {
    let name: String
    let desc: String
    let url: String
}
