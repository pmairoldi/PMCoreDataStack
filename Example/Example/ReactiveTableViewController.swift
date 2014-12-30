import UIKit

class ReactiveTableViewController: CoreDataTableViewController {

    let dateFormatter = NSDateFormatter();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem();
        
        // Do any additional setup after loading the view.
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(sender: UIBarButtonItem) {
        
        let todo = ToDo(context: self.viewModel.managedObjectContext)
        todo.task = "hello world"
        todo.date = NSDate();
        
        switch self.viewModel.managedObjectContext.save() {
        case .Success:
            break
        case .Failure(let error):
            println(error)
        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let todo = self.viewModel.objectAtIndexPath(indexPath) as ToDo
        
        self.viewModel.managedObjectContext.deleteObject(todo);
        self.viewModel.managedObjectContext.save()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReactiveCell", forIndexPath: indexPath) as UITableViewCell
        
        let todo = self.viewModel.objectAtIndexPath(indexPath) as ToDo
        cell.textLabel?.text = todo.task
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(todo.date);
        
        return cell;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
