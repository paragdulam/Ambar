//
//  Helpers.swift
//  RTSwiftCoreDataStack
//
//  Created by Aleksandar Vacić on 24.10.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
	typealias Callback = (Error?) -> Void

	func save(withCallback callback: Callback? = nil) {
		let resultCallback : Callback = callback ?? { _ in }

		if !self.hasChanges {
			resultCallback(nil)
		}

		//	async save, to not block the thread it's called on
		self.performAndWait {
			do {
				try self.save()

				//	if there's a parentContext, save that one too
				if let parentContext = self.parent {
					parentContext.save(withCallback: callback)
					return;
				}

				resultCallback(nil)

			} catch(let error) {
				let log = String(format: "E | %@:%@/%@ Error saving context:\n%@",
								 String(describing: self), #file, #line, error.localizedDescription)
				print(log)
				resultCallback(error)
			}
		}
	}
}