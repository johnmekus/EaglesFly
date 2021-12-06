//
//  EventsViewController.swift
//  EaglesFly
//
//  Created by John Mekus on 11/30/21.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    print("Just created the date formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter
}()

class EventListViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var acceptedButton: UIBarButtonItem!
    
    var events: Events!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        events = Events()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        events.loadData
        {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowDetail"
        {
            let destination = segue.destination as! EventDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.event = events.eventArray[selectedIndexPath.row]
        }
        else if segue.identifier == "ShowAccepted" {
            let destination = segue.destination as! AcceptedListViewController
            destination.events = events
        }
    }
    
    func sortBasedOnSegmentPressed()
    {
        switch sortSegmentedControl.selectedSegmentIndex
        {
        case 0: // a-z
            events.eventArray.sort(by: {$0.location < $1.location})
        case 1:
            events.eventArray.sort(by: {dateFormatter.date(from: String($0.dateAndTime.components(separatedBy: ",")[0])) ?? Date() < dateFormatter.date(from: String($1.dateAndTime.components(separatedBy: ",")[0])) ?? Date()})
        default:
            print("How'd you get here...")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl)
    {
        sortBasedOnSegmentPressed()
    }
    
    @IBAction func acceptedButtonPressed(_ sender: UIBarButtonItem)
    {
        
    }
    
}

extension EventListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return events.eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell
        if events.eventArray[indexPath.row].full == true
        {
            cell.locationNameLabel?.text = events.eventArray[indexPath.row].location + " (Full)"
            cell.locationNameLabel.textColor = .red
        }
        else
        {
            cell.locationNameLabel?.text = events.eventArray[indexPath.row].location
            cell.locationNameLabel.textColor = .black
        }
        cell.dateAndTimeLabel?.text = events.eventArray[indexPath.row].dateAndTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
}

