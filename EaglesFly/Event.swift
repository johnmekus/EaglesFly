//
//  Event.swift
//  EaglesFly
//
//  Created by John Mekus on 12/1/21.
//

import Foundation
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class Event
{
    var location: String
    var dateAndTime: String
    var contactNumber: String
    var full: Bool
    var postingUserID: String
    var documentID: String
    var attendedBy: [String]
    
    var dictionary: [String: Any]
    {
        return ["location": location, "dateAndTime": dateAndTime, "contactNumber": contactNumber, "full": full, "postingUserID": postingUserID, "attendedBy": attendedBy]
    }
    
    init(location: String, dateAndTime: String, contactNumber: String, full: Bool, postingUserID: String, documentID: String, attendedBy: [String])
    {
        self.location = location
        self.dateAndTime = dateAndTime
        self.contactNumber = contactNumber
        self.full = full
        self.postingUserID = postingUserID
        self.documentID = documentID
        self.attendedBy = attendedBy
    }
    
    convenience init()
    {
        self.init(location: "", dateAndTime: "", contactNumber: "", full: false, postingUserID: "", documentID: "", attendedBy: [])
    }
    
    convenience init(dictionary: [String: Any])
    {
        let location = dictionary["location"] as! String? ?? ""
        let dateAndTime = dictionary["dateAndTime"] as! String? ?? ""
        let contactNumber = dictionary["contactNumber"] as! String? ?? ""
        //let attending = dictionary["attending"] as! Bool? ?? false
        let full = dictionary["full"] as! Bool? ?? false
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let attendedBy = dictionary["attendedBy"] as! [String]? ?? []
        self.init(location: location, dateAndTime: dateAndTime, contactNumber: contactNumber, full: full, postingUserID: postingUserID, documentID: "", attendedBy: attendedBy)
    }
    
    func saveData(completion: @escaping (Bool) -> ())
    {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: Could not save data becase we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID, otherwise .addDocument will create one.
        if self.documentID == "" { // Create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("events").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("💨 Added document: \(self.documentID)") // It worked!
                completion(true)
            }
            
        } else {// else save to the existing documentID w/ .setData
            let ref = db.collection("events").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("💨 Updated document: \(self.documentID)") // It worked!
                completion(true)
            }
        }
    }
    
    func saveSaves(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //get user id
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("Error: could not save data without valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        //create dictionary representation of data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we have saved a record, we'll have a doc ID, otherwise .addDocument will create one
        if self.documentID == "" { //create a new document via .addDocument
            var ref: DocumentReference? = nil //firestore will create new id
            ref = db.collection("attendence").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("Error: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document \(self.documentID) successfully")
                completion(true)
            }
        } else { //else save to existing documentID with setData using setData
            let ref = db.collection("attendence").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("Error: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Added document \(self.documentID) successfully")
                completion(true)
            }
        }
    }
    
    func deleteData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("events").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review id \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            }
            else {
                print("👍 Successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
}
