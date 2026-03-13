//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 04.03.26.
//

import UIKit
import MapKit

class ToDoDetailTableViewController: UITableViewController {
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    
    @IBOutlet var reminderSegmentedControl: UISegmentedControl!
    let reminderOffsets = [-1, 15, 30, 60, 120, 1440]   // Minuten vorher
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    let geocoder = CLGeocoder()
    
    var isDatePickerHidden = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    
    var toDo: ToDo?
    
    // MARK: Status des Save-Buttons
    
    //Ruft bei jeder Änderung des Textfeldes updateSaveButtonState auf.
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // Setzt den Status des Save-Buttons in Abhängigkeit zum Inhalt des Textfeldes.
    func updateSaveButtonState() {
        // shouldEnableSaveButton ist ein Boolean
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    // MARK: Ausblenden der UI-Tastatur
    
    // Sorgt dafür, dass beim Drücken der Enter-Taste auf der UI-Tastatur
    // die Tastatur ausgeblendet wird.
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: Umschalten des "Erledigt-Hakens"
    
    // Schaltet den Button um. Setzt bzw. löscht das Häkchen.
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }
    
    // MARK: Datumstextfeld updaten
    
    // Formatiert und setzt den Text in das Datumstextfeld.
    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.defaultDigits).hour().minute())
    }
    
    // Ruft bei jeder Änderung am DatePicker updateDueDateLabel() auf
    // und übergibt dabei das neue Datum.
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    // MARK: Ein- und Ausblenden des DatePickers
    
    // Wenn der übergebene Index der des DatePickers ist, wird in Abhängigkeit
    // vom Flag die Höhe der Zeile ggf. auf 0 gesetzt.
    // Die Zeile für die Notizen erhält eine feste Höhe von 200.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case datePickerIndexPath where isDatePickerHidden == true:
            return 0
        case datePickerIndexPath:
            return 216
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    // Wenn der Index der des DateLabels betätigt wird, wird das Flag umgeschaltet.
    // Das Label aufgefrischt und die tableView geupdated.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelIndexPath {
            isDatePickerHidden.toggle()
            updateDueDateLabel(date: dueDateDatePicker.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: Daten für Übergabe vorbereiten
    
    // Wenn sichergestellt ist, das die saveUnwind-Segue ausgeführt werden soll,
    // werden die Werte aus der Eingabe in Konstanten gespeichert und für die Segue vorbereitet.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        // Holt die Werte aus den UI-Elementen
        let title = titleTextField.text!
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDateDatePicker.date
        let notes = notesTextView.text
        let reminderOffset = reminderOffsets[reminderSegmentedControl.selectedSegmentIndex]
        let location = locationTextField.text
        
        // Wenn toDo bereits existiert, werden die vorhandenen Werte überschrieben.
        // Ansonsten ein neues toDo-Objekt erstellt.
        if toDo != nil {
            toDo?.title = title
            toDo?.isComplete = isComplete
            toDo?.dueDate = dueDate
            toDo?.notes = notes
            toDo?.reminderOffsetMinutes = reminderOffset
            toDo?.locationName = location
            
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes, reminderOffsetMinutes: reminderOffset)
            toDo?.locationName = location
        }
    }
    
    @IBAction func reminderChanged(_ sender: UISegmentedControl) {
        // Wird aufgerufen, wenn der User ein Segment auswählt
    }
    
    
    // Action für das Textfeld der Map-View
    @IBAction func locationEditingChanged(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else { return }
        updateMapForLocation(text)
    }
    
    func updateMapForLocation(_ address: String) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            
            let coordinate = location.coordinate
            
            // Karte zentrieren
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.mapView.setRegion(region, animated: true)
            
            // Pin setzen
            self.mapView.removeAnnotations(self.mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = address
            self.mapView.addAnnotation(annotation)
            
            // Werte speichern
            self.toDo?.latitude = coordinate.latitude
            self.toDo?.longitude = coordinate.longitude
            self.toDo?.locationName = address
        }
    }
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDueDate: Date
        
        
        // Wenn dem Controller ein vorhandenes ToDo übergeben wird,
        // werden die Werte in die jeweiligen UI-Elemente gesetzt.
        if let toDo = toDo {
            navigationItem.title = "Aufgabe"
            titleTextField.text = toDo.title
            isCompleteButton.isSelected = toDo.isComplete
            currentDueDate = toDo.dueDate
            notesTextView.text = toDo.notes
            locationTextField.text = toDo.locationName
            
            if let index = reminderOffsets.firstIndex(of: toDo.reminderOffsetMinutes) {
                reminderSegmentedControl.selectedSegmentIndex = index
            }
            
            if let lat = toDo.latitude, let lon = toDo.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                mapView.setRegion(region, animated: false)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = toDo.locationName
                mapView.addAnnotation(annotation)
            }
            
            
        } else {
            // Setzt das angezeigte Datum im Textfeld 24h in die Zukunft.
            currentDueDate = Date().addingTimeInterval(86400)
        }
        
        dueDateDatePicker.date = currentDueDate
        updateDueDateLabel(date: currentDueDate)
        updateSaveButtonState()
    }
}
