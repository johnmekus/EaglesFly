//
//  Accepted.swift
//  EaglesFly
//
//  Created by John Mekus on 12/4/21.
//

import Foundation
import Firebase
import UIKit


class Attendence
{
    var attendingArray: [Event] = []
    var db: Firestore!
    
    init()
    {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())
    {
        db.collection("attendence").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            
//            guard let currentUserID = Auth.auth().currentUser?.uid else {
//                print("😡 ERROR: Could not save data becase we don't have a valid postingUserID.")
//                return completed()
//            }
            
            self.attendingArray = []
            //there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                let saved = Event(dictionary: document.data())
                
                saved.documentID = document.documentID
                self.attendingArray.append(saved)
            }
            completed()
        }
    }
}
