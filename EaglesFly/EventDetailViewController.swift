//
//  EventDetailViewController.swift
//  EaglesFly
//
//  Created by John Mekus on 12/1/21.
//

import UIKit
import Firebase
import AVFoundation

private let dateFormatter: DateFormatter =
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class EventDetailViewController: UIViewController
{
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var attendingLabel: UILabel!
    @IBOutlet weak var fullLabel: UILabel!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var fullSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    var event: Event!
    var attendence: Attendence!
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad()
    {
        //hide keyboard if we tap outside of the field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        super.viewDidLoad()
        if event == nil
        {
            event = Event()
        }
        if attendence == nil
        {
            attendence = Attendence()
        }
        updateUserInterface()
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
    
    func updateUserInterface()
    {
        locationTextField.text = event.location
        dateAndTimeLabel.text = event.dateAndTime
        contactTextField.text = event.contactNumber
        fullSwitch.isOn = event.full
        if event.documentID == ""
        {
            acceptedButton.isEnabled = false
            deleteEventButton.isEnabled = false
        }
        else
        {
            if event.postingUserID == Auth.auth().currentUser?.uid
            {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                if fullSwitch.isOn
                {
                    acceptedButton.isHidden = true
                }
            }
            else
            {
                saveBarButton.isEnabled = false
                saveBarButton.tintColor = .clear
                //cancelBarButton.isEnabled = false
                //cancelBarButton.tintColor = .clear
                fullSwitch.isUserInteractionEnabled = false
                locationTextField.isEnabled = false
                contactTextField.isEnabled = false
                datePicker.isEnabled = false
                deleteEventButton.isEnabled = false
                //deleteEventButton.isHidden = true
                if fullSwitch.isOn
                {
                    acceptedButton.isHidden = true
                }
            }
        }
    }
    
    func updateFromUserInterface()
    {
        event.location = locationTextField.text!
        event.dateAndTime = dateAndTimeLabel.text!
        event.contactNumber = contactTextField.text!
        event.full = fullSwitch.isOn
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem)
    {
        updateFromUserInterface()
        if locationTextField.text == "" || contactTextField.text == ""
        {
            self.oneButtonAlert(title: "Incomplete Event", message: "Please fill out all fields to save this event.")
            return
        }
        event.saveData { success in
            if success
            {
                self.leaveViewController()
            }
            else
            {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data wouldn't save to the cloud.")
            }
        }
    }
    
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker)
    {
        self.view.endEditing(true)
        dateAndTimeLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem)
    {
        leaveViewController()
    }
    
    @IBAction func acceptedButtonPressed(_ sender: UIButton)
    {
        playSound(name: "beep")
        //NOTE: Playing a sound throws an exception in this case. I looked up the issue and on apple's website they say it is a known issue. It works fine if you simulate on a phone!
        event.attendedBy.append(Auth.auth().currentUser!.uid)
        event.saveData { success in
            if success
            {
                self.oneButtonAlert(title: "You've been added!", message: "You are now included on this event. Please view your calender to confirm.")
                self.leaveViewController()
            }
            else
            {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data wouldn't save to the cloud.")
            }
        }
    }
    
    
    @IBAction func returnKeyPressedAlso(_ sender: UITextField)
    {
        locationTextField.resignFirstResponder()
    }
    
    @IBAction func returnKeyPressed(_ sender: UITextField) {
        contactTextField.resignFirstResponder()
    }
    
    @IBAction func deleteEventButtonPressed(_ sender: UIButton)
    {
        event.deleteData { success in
            if success
            {
                self.leaveViewController()
            } else {
                print("Delete unsuccessful")
            }
        }
    }
    
    func playSound(name: String)
    {
        if let sound = NSDataAsset(name: name)
        {
            do
            {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            }
            catch
            {
                print("ERROR: \(error.localizedDescription) Could not real error from file sound0.")
            }
        }
        else
        {
            print("ERROR: Could not real error from file sound0.")
        }
    }
}
