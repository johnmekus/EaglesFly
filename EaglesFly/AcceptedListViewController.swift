//
//  AcceptedListViewController.swift
//  EaglesFly
//
//  Created by John Mekus on 12/4/21.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    print("Just created the date formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter
}()

class AcceptedListViewController: UIViewController
{
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var acceptedEvents: [Event] = []
    var events: Events!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if events == nil
        {
            events = Events()
        }
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "My Accepted Events"
        for event in events.eventArray
        {
            if event.attendedBy.contains(Auth.auth().currentUser!.uid)
            {
                acceptedEvents.append(event)
            }
        }
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
    
    func sortBasedOnSegmentPressed()
    {
        switch sortSegmentedControl.selectedSegmentIndex
        {
        case 0: // a-z
            acceptedEvents.sort(by: {$0.location < $1.location})
        case 1:
            acceptedEvents.sort(by: {dateFormatter.date(from: String($0.dateAndTime.components(separatedBy: ",")[0])) ?? Date() < dateFormatter.date(from: String($1.dateAndTime.components(separatedBy: ",")[0])) ?? Date()})
        default:
            print("How'd you get here...")
        }
        tableView.reloadData()
    }
    
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl)
    {
        sortBasedOnSegmentPressed()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem)
    {
        leaveViewController()
    }
    
    func leaveViewController()
    {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode
        {
            dismiss(animated: true, completion: nil)
        }
        else
        {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension AcceptedListViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return acceptedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptedCell") as! AcceptedTableViewCell
        cell.locationLabel.text = acceptedEvents[indexPath.row].location
        cell.contactNumberLabel.text = acceptedEvents[indexPath.row].contactNumber
        cell.dateAndTimeLabel.text = acceptedEvents[indexPath.row].dateAndTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    
}


