//
//  LocationsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import MapKit
import UIKit

protocol LocationsDelegate: AnyObject {
    func locations(didSelectAddress address: AddressModel)
}

struct AddressModel {
    let fullAddress: String
    let latitude: Double
    let longitude: Double
}

class LocationsViewController: BaseViewController, Nibbable {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchResultsTable: UITableView!

    weak var delegate: LocationsDelegate?

    // Create a seach completer object
    var searchCompleter = MKLocalSearchCompleter()

    // These are the results that are returned from the searchCompleter & what we are displaying
    // on the searchResultsTable
    var searchResults = [MKLocalSearchCompletion]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the delgates & the dataSources of both the searchbar & searchResultsTableView
        searchCompleter.delegate = self
        searchBar.delegate = self
        searchResultsTable.keyboardDismissMode = .onDrag
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
    }
}

// MARK: - UISearchBarDelegate

extension LocationsViewController: UISearchBarDelegate {
    // This method declares that whenever the text in the searchbar is change to also update
    // the query that the searchCompleter will search based off of
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationsViewController: MKLocalSearchCompleterDelegate {
    // This method declares gets called whenever the searchCompleter has new search results
    // If you wanted to do any filter of the locations that are displayed on the the table view
    // this would be the place to do it.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searcResults variable to the results that the searchCompleter returned
        searchResults = completer.results

        // Reload the tableview with our new searchResults
        searchResultsTable.reloadData()
    }

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Error
    }
}

// MARK: - UITableViewDataSource

extension LocationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle

        return cell
    }
}

// MARK: - UITableViewDelegate

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)

        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }

            guard let name = response?.mapItems[0].placemark.title else {
                return
            }

            let latitude = coordinate.latitude
            let longitude = coordinate.longitude

            self.delegate?.locations(didSelectAddress: AddressModel(fullAddress: name, latitude: latitude, longitude: longitude))
            self.dismiss(animated: true)
        }
    }
}
