# Canoe

Canoe
============

Canoe simplifies table view mangment by wrapping it arund a `TableViewHelper`. However Canoe doesn't force you to use custom delegates and data sources. Table view managment uses existing protocols you just dont need to manage index paths anymore.

## Installation

### SPM

PiuPiu supports SPM. Not sure what else to say :)

## Usage

### 1. Import canue on your UIViewController

```swift
import Canoe
```

### 2. Define a `Section` and `Row`

```swift
/// Object representing simple rows on a table view
struct SimpleRow: TableViewHelperSection {
    // Add anything you like here.
    // ....
}

/// Object representing simple sections on a table view
/// Must conform to `TableViewHelperSection`
struct SimpleSection: TableViewHelperSection {
    // Title is not required for the protocol but its usually useful
    let title: String?
    
    // The rows of the section
    var rows: [SimpleRow]
}
```

All you need to do is define is a `TableViewHelperSection` which in turn needs to have rows. Rows can be an array of anything: enums, structs, classes, integers, etc.

In this example we used a struct for both the section and row. Did we need to use a struct? No! We just decided to use a struct. It fit our needs better.

### 3. Add `TableViewHelper` to our UIViewController

```swift
class ViewController: UIViewController {
    private lazy var tableViewHelper: TableViewHelper<SimpleSection> = {
        return TableViewHelper(tableView: self.tableView)
    }()
    
    ...
}
```

### 4. Use Add your `UITableViewDataSource` and `UITableViewDelegate`

```swift
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewHelper.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewHelper.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewHelper.sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let row = tableViewHelper.row(for: indexPath)
        
        // Configure your cell based based the row.
        // It may be a good idea to even use an enum for our rows if we're supporting different types of cells
        
        return cell
    }
}
```

```swift
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = tableViewHelper.row(for: indexPath)
        
        // Do something after selecting this row
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Here we can see an example of where tableViewHelper does some common things for us
        tableViewHelper.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // Here is another common table view helper operation
            tableViewHelper.removeRow(at: indexPath)
            
        case .insert, .none:
            break

        @unknown default:
            break
        }
    }
}
```

Most of what we do here is pretty straightforward: configure a cell, move cells, delete cells. In a simpe example, it's difficult how truly useful this is. 
But even with these basic examples, `TableViewHelper` made it much easher and quicker to do these operations. 
Imagine a much much much more complex screen with different row types and differnt types of interactions.

## Advanced example
TODO

## Dependencies

Canoe includes...nothing. This is a light-weight library.

## Credits

Canoe is owned and maintained by Jacob Sikorski.

## License

Canoe is released under the MIT license. [See LICENSE](https://github.com/cuba/Canoe/blob/master/LICENSE) for details
