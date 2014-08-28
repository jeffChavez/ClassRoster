//
//  ViewController.swift
//  Class Roster Part 5
//
//  Created by Jeff Chavez on 8/23/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

/*questions

    - Will not load from array
    - does not save new person data

*/

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //allow access to tableView properties throughout this code
    @IBOutlet weak var tableView: UITableView!
    
    //create two empty arrays of Person class, one for students and one for teachers
    var studentArray = [Person]()
    var teacherArray = [Person]()
    var classArray = [[Person]]()
    var sectionTitles = ["Teachers", "Students"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) [0] as String
        if let people = NSKeyedUnarchiver.unarchiveObjectWithFile(documentPath + "/archive3") as? [[Person]] {
            self.classArray = people
        }
        else {
            var studentNames = ["Birkholz": "Nate", "Brightbill": "Matthew", "Chavez": "Jeff", "Ferderer": "Chrstie",
                "Fry": "David", "Gherle": "Adrian", "Hawken": "Jake", "Kazi": "Shams", "Klein": "Cameron",
                "Kolodziejczak": "Kori", "Lewis": "Parker", "Ma": "Nathan", "MacPhee": "Casey",
                "McAleer":"Brendan","Mendez":"Brian", "Morris": "Mark", "North": "Rowan", "Pham": "Kevin", "Richman": "Will",
                "Thueringer": "Heather", "Vu": "Tuan", "Walkingstick": "Zack", "Wong": "Sara", "Zhang": "Hongyao"]
            var teacherNames = ["Clem": "John", "Johnson": "Brad"]
            for (lastName, firstName) in studentNames {
                
                self.studentArray.append(Person(firstName: firstName, lastName: lastName))
            }
            for (lastName, firstName) in teacherNames {
                
                self.teacherArray.append(Person(firstName: firstName, lastName: lastName))
            }
            classArray = [teacherArray, studentArray]
            NSKeyedArchiver.archiveRootObject(classArray, toFile: documentPath + "/archive3")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var people = NSKeyedArchiver.archiveRootObject(classArray, toFile: documentsPath + "/archive3")
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mark: UITableViewDataSource
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = classArray[indexPath.section][indexPath.row].fullName()
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        var arrayForSection = self.classArray[section]
        return arrayForSection.count
        
//        if section == 0 {
//            return teacherArray.count
//        } else {
//            return studentArray.count
//        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return sectionTitles.count
    }

    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return sectionTitles[section]
    }

    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            classArray[indexPath.section].removeAtIndex(indexPath!.row)
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    //Mark: Segue
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        if segue.identifier == "showPersonSegue" {
            let destination = segue.destinationViewController as DetailViewController
            destination.selectedPerson = classArray[indexPath.section][indexPath.row]
        }
        
        if segue.identifier == "addNewPerson" {
            let destination = segue.destinationViewController as DetailViewController
            destination.selectedPerson = Person(firstName: "", lastName: "")
            var students = self.classArray[1] as [Person]
            students.append(destination.selectedPerson!)
            self.classArray[1] = students
        }
    }
}
