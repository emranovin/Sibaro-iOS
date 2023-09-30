//
//  FileShareRequestHandler.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 7/8/1402 AP.
//

import Foundation
import Swifter

func fileShareRequestHandler(_ directoryPath: String, completed: @escaping (HttpRequest) -> (), defaults: [String] = ["index.html", "default.html"]) -> ((HttpRequest) -> HttpResponse) {
    return { [completed] request in
        guard let fileRelativePath = request.params.first else {
            completed(request)
            return .notFound
        }
        if fileRelativePath.value.isEmpty {
            for path in defaults {
                if let file = try? (directoryPath + String.pathSeparator + path).openForReading() {
                    return .raw(200, "OK", [:], { [request] writer in
                        try? writer.write(file)
                        file.close()
                        completed(request)
                    })
                }
            }
        }
        let filePath = directoryPath + String.pathSeparator + fileRelativePath.value

        if let file = try? filePath.openForReading() {
            let mimeType = fileRelativePath.value.mimeType()
            var responseHeader: [String: String] = ["Content-Type": mimeType]

            if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
                let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                responseHeader["Content-Length"] = String(fileSize)
            }

            return .raw(200, "OK", responseHeader, { [request] writer in
                try? writer.write(file)
                file.close()
                completed(request)
            })
        }
        completed(request)
        return .notFound
    }
}
