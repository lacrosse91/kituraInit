//
//  Application.swift
//  KituraTIL
//
//  Created by 川内翔一朗 on 2019/02/19.
//

import CouchDB
import Foundation
import Kitura
import LoggerAPI

public class App {

    // 2
    var client: CouchDBClient?
    var database: Database?

    let router = Router()

    private func postInit() {
        // 1
        let connectionProperties = ConnectionProperties(host: "localhost", port: 5984, secured: false)
        client = CouchDBClient(connectionProperties: connectionProperties)
        // 2
        client!.dbExists("acronyms") { exists, _ in
            guard exists else {
                // 3
                self.createNewDatabase()
                return
            }
            // 4
            Log.info("Acronyms database located - loading...")
            self.finalizeRoutes(with: Database(connProperties: connectionProperties, dbName: "acronyms"))
        }
    }

    private func createNewDatabase() {
        Log.info("Database does not exist - creating new database")
        // 1
        client?.createDB("acronyms") { database, error in
            // 2
            guard let database = database else {
                let errorReason = String(describing: error?.localizedDescription)
                Log.error("Could not create new database: (\(errorReason)) - acronym routes not created")
                return
            }
            self.finalizeRoutes(with: database)
        }
    }

    private func finalizeRoutes(with database: Database) {
        self.database = database
        initializeAcronymRoutes(app: self)
        Log.info("Acronym routes created")
    }

    public func run() {
        // 6
        postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
