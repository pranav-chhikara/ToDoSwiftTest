//
//  NewToDoViewController.swift
//  To DO
//
//  Created by Shikhar Singhal on 26/11/16.
//  Copyright © 2016 Pranav Chhikara. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NewToDoViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate
{

    @IBOutlet weak var itemLocationMap: MKMapView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    var selectedDate:NSString!
    var itemCoordinates: NSString!
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        itemLocationMap.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(NewToDoViewController.handleTap(gestureReconizer:)))
        gestureRecognizer.delegate = self
        itemLocationMap.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject)
    {
        if ((itemNameTextField.text?.trimmingCharacters(in: .whitespaces).characters.count) == 0)
        {
            self.displayAlert(title: "Error", message: "Please enter item name", button: "OK")
        }
        else if (descriptionTextView.text == "Description")
        {
            self.displayAlert(title: "Error", message: "Please enter Descriprtion", button: "OK")
        }
        else if (dateTimePicker.date<Date())
        {
            self.displayAlert(title: "Error", message: "Please enter new date time", button: "OK")
        }
        else if (itemCoordinates == nil)
        {
            self.displayAlert(title: "Error", message: "Please enter item location", button: "OK")
        }
        else
        {
            let dateToString = DateFormatter()
            dateToString.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let myList = NSEntityDescription.entity(forEntityName: "ToDoItems", in: managedObjectContext)
            let toDoItem = NSManagedObject(entity: myList!, insertInto: managedObjectContext)
            toDoItem.setValue(itemNameTextField.text, forKey: "itemName")
            toDoItem.setValue(descriptionTextView.text, forKey: "itemDescription")
            toDoItem.setValue(dateToString.string(from: dateTimePicker.date), forKey: "itemDateTime")
            toDoItem.setValue(itemCoordinates, forKey: "itemLocation")
            do
            {
                try managedObjectContext.save()
            }
            catch let error as NSError
            {
                print("Save error \(error),\(error.userInfo)")
            }
            
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title:String, message:String, button:String)
    {
        var alertView: UIAlertController!
        alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.itemLocationMap.setRegion(region, animated: true)
    }

    func handleTap(gestureReconizer: UITapGestureRecognizer)
    {
        itemLocationMap.removeAnnotations(itemLocationMap.annotations)
        let location = gestureReconizer.location(in: itemLocationMap)
        let coordinate = itemLocationMap.convert(location,toCoordinateFrom: itemLocationMap)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        itemLocationMap.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyAnnotation")
        annotationView.pinTintColor = UIColor.red
        annotationView.animatesDrop = true
        itemCoordinates = "\(annotation.coordinate.latitude) \(annotation.coordinate.longitude)" as NSString!
        return annotationView
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
