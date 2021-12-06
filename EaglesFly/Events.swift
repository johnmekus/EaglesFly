//
//  Events.swift
//  EaglesFly
//
//  Created by John Mekus on 12/2/21.
//

import Foundation
import Firebase

class Events
{
    var eventArray: [Event] = []
    var db: Firestore!
    
    init()
    {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())
    {
        db.collection("events").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.eventArray = [] // clean out existing spotArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sre you have a dictionary initializer in the singular class
                let event = Event(dictionary: document.data())
                event.documentID = document.documentID
                self.eventArray.append(event)
            }
            completed()
        }
    }
}
