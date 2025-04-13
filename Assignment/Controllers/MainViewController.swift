//
//  MainViewController.swift
//  Assignment
//
//  Created by Muhammad Irfan Tarar on 13/04/2025.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")

        tableView.rowHeight = 80
    }

    func loadItems() {
        // Load items from a data source
        items = [
            Item(name: "Red Sneakers", imageName: "image1", shortDescription: "Stylish red sneakers", detailedDescription: "Perfect for casual walks and running errands."),
            Item(name: "Wireless Headphones", imageName: "image1", shortDescription: "Noise cancelling", detailedDescription: "Experience high quality sound without distractions."),
            Item(name: "Mountain Bike", imageName: "image1", shortDescription: "All-terrain bike", detailedDescription: "Conquer trails and rugged terrain with this sturdy bike."),
            Item(name: "Smartwatch", imageName: "image1", shortDescription: "Track your fitness", detailedDescription: "Stay connected and monitor your health easily."),
            Item(name: "Leather Wallet", imageName: "image1", shortDescription: "Premium leather", detailedDescription: "Handcrafted with genuine leather for durability."),
            Item(name: "Gaming Laptop", imageName: "image1", shortDescription: "High performance", detailedDescription: "Perfect for gaming and multitasking."),
            Item(name: "Travel Backpack", imageName: "image1", shortDescription: "Spacious and durable", detailedDescription: "Ideal for travelers and daily commuters."),
            Item(name: "Running Shoes", imageName: "image1", shortDescription: "Comfort and speed", detailedDescription: "Engineered for runners who seek maximum performance."),
            Item(name: "Bluetooth Speaker", imageName: "image1", shortDescription: "Portable sound", detailedDescription: "Enjoy music anywhere with powerful bass."),
            Item(name: "Coffee Maker", imageName: "image1", shortDescription: "Brew perfect coffee", detailedDescription: "Wake up to fresh, hot coffee every morning."),
            Item(name: "Electric Guitar", imageName: "image1", shortDescription: "Rock on", detailedDescription: "Perfect for beginners and pros alike."),
            Item(name: "Digital Camera", imageName: "image1", shortDescription: "Capture memories", detailedDescription: "High-resolution photos and 4K video recording."),
            Item(name: "Office Chair", imageName: "image1", shortDescription: "Ergonomic design", detailedDescription: "Stay comfortable during long working hours."),
            Item(name: "Yoga Mat", imageName: "image1", shortDescription: "Non-slip surface", detailedDescription: "Support your poses with extra grip and comfort."),
            Item(name: "Desk Lamp", imageName: "image1", shortDescription: "Adjustable brightness", detailedDescription: "Light up your workspace with style.")
        ]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let detailVC = ItemDetailViewController()
        detailVC.item = item
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
