//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by Sebastian Stark on 04.03.26.
//

import UIKit
import MapKit

// Controller für die Detailansicht eines ToDos.
// Hier kann der Nutzer Titel, Datum, Notizen, Erinnerung und Ort bearbeiten.
class ToDoDetailTableViewController: UITableViewController {
    
    
    // MARK: - Outlets
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var reminderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Eigenschaften
    
    // Geocoder für die Umwandlung von Adressen → Koordinaten.
    let geocoder = CLGeocoder()
    
    // Liste der möglichen Erinnerungszeiten in Minuten.
    // -1 bedeutet: Keine Erinnerung.
    let reminderOffsets = [-1, 15, 30, 60, 120, 1440]
    
    // Steuert, ob der DatePicker sichtbar ist.
    var isDatePickerHidden = true
    
    // IndexPaths für die dynamischen Zellen.
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    
    // Das ToDo, das bearbeitet wird.
    // Wenn nil → neues ToDo wird erstellt.
    var toDo: ToDo?
    
    
    // MARK: - Save-Button
    
    // Wird aufgerufen, wenn sich der Text im Titel-Feld ändert.
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // Aktiviert/Deaktiviert den Save-Button abhängig davon, ob ein Titel eingegeben wurde.
    func updateSaveButtonState() {
        // shouldEnableSaveButton ist ein Boolean
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    
    // MARK: - Ausblenden der UI-Tastatur
    
    // Sorgt dafür, dass beim Drücken der Enter-Taste auf der UI-Tastatur
    // die Tastatur ausgeblendet wird.
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    
    // MARK: - Umschalten des "Erledigt-Hakens"
    
    // Schaltet den Button um. Setzt bzw. löscht das Häkchen.
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }
    
    
    // MARK: - Datum
    
    // Aktualisiert das Label, das das Fälligkeitsdatum anzeigt.
    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.defaultDigits).hour().minute())
    }
    
    // Ruft bei jeder Änderung am DatePicker updateDueDateLabel() auf und übergibt dabei das neue Datum.
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    
    // MARK: - Dynamische Tabellenzellen
    
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
    
    // Öffnet/Schließt den DatePicker beim Tippen auf das Datumslabel.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelIndexPath {
            isDatePickerHidden.toggle()
            updateDueDateLabel(date: dueDateDatePicker.date)
            
            // Animiert die Änderung der Zellenhöhe.
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    // MARK: - Segue
    
    // Übergibt die eingegebenen Werte zurück an den vorherigen Controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        // Werte aus UI lesen
        let title = titleTextField.text!
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDateDatePicker.date
        let notes = notesTextView.text
        let reminderOffset = reminderOffsets[reminderSegmentedControl.selectedSegmentIndex]
        let location = locationTextField.text
        
        // Wenn toDo bereits existiert, werden die vorhandenen Werte überschrieben ...
        if toDo != nil {
            toDo?.title = title
            toDo?.isComplete = isComplete
            toDo?.dueDate = dueDate
            toDo?.notes = notes
            toDo?.reminderOffsetMinutes = reminderOffset
            toDo?.locationName = location
            
            // ... ansonsten ein neues toDo-Objekt erstellt.
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes, reminderOffsetMinutes: reminderOffset)
            toDo?.locationName = location
        }
    }
    
    
    // MARK: - Erinnerung
    
    // Wird aufgerufen, wenn der Nutzer eine neue Erinnerungszeit auswählt.
    // Logik wird im prepare() verarbeitet.
    @IBAction func reminderChanged(_ sender: UISegmentedControl) {
    }
    
    
    // MARK: - Map / Geocoding
    
    // Wird aufgerufen, wenn der Nutzer die Adresse ändert.
    @IBAction func locationEditingChanged(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else { return }
        updateMapForLocation(text)
    }
    
    // Wandelt eine Adresse in Koordinaten um und aktualisiert die Karte.
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
    
    
    // MARK: - Lifecycle
    
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
            
            // Erinnerung setzen
            if let index = reminderOffsets.firstIndex(of: toDo.reminderOffsetMinutes) {
                reminderSegmentedControl.selectedSegmentIndex = index
            }
            
            // Karte setzen, falls Koordinaten vorhanden
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
            // Setzt Standarddatum für neue Aufgabe auf morgen.
            currentDueDate = Date().addingTimeInterval(86400)
        }
        
        // UI aktualisieren
        dueDateDatePicker.date = currentDueDate
        updateDueDateLabel(date: currentDueDate)
        updateSaveButtonState()
    }
}
