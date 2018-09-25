let sourceDirectory = "/Users/prohorov/Sources/trunk/app"

import Foundation

func lintSource(content: String, fullPath: String) -> Bool {
    
    let rawCode = content.replacingOccurrences(of: "\n", with: "")
    
    var block = false
    var deepLevel = 0
    var blockContent = ""
    

    
    for character in rawCode {
        if character == "^" {
            if block == false {
                block = true
            }
            else {
                //assertionFailure("block opened twice??")
            }
        }
        else if block == true, character == "{" {
            deepLevel += 1
        }
        else if block == true, character == "}" {
            deepLevel -= 1
            
            if deepLevel == 0 {
                block = false
                
                if blockContent.contains("[self ") {
                    return false
                }
                
                blockContent = ""
            }
        }
        
        if block == true {
            blockContent += String(character)
        }
    }
    
    return true
}

let fileSystem = FileManager.default
let rootPath = sourceDirectory

var filePathsSet = Set<String>()

if let fsTree = fileSystem.enumerator(atPath: rootPath) {
    
    while let fsNodeName = fsTree.nextObject() as? NSString {
        
        let fullPath = "\(rootPath)/\(fsNodeName)"
        
        var isDir: ObjCBool = false
        fileSystem.fileExists(atPath: fullPath, isDirectory: &isDir)
        
        if !isDir.boolValue && fsNodeName.pathExtension == "m" {
            let url = URL.init(fileURLWithPath: fullPath)
            let content = try! String(contentsOf: url, encoding: .utf8)
            if lintSource(content: content, fullPath: fullPath) == false {
                filePathsSet.insert(fullPath)
            }
        }
    }
}

for path in filePathsSet {
    print(path)
}
