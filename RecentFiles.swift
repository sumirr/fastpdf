import Foundation
import PDFKit

struct RecentFileEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let bookmarkData: Data
    let fileName: String

    var url: URL? {
        var isStale = false
        do {
            let resolvedURL = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], bookmarkDataIsStale: &isStale)
            return resolvedURL
        } catch {
            print("[RecentFiles] Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}

class RecentFiles {
    private static let key = "recentFilesWithBookmarks"
    private static let maxFiles = 10

    static func load() -> [URL] {
        guard let rawData = UserDefaults.standard.data(forKey: key) else { return [] }

        do {
            let entries = try JSONDecoder().decode([RecentFileEntry].self, from: rawData)
            return entries.compactMap { entry in
                guard let url = entry.url else { return nil }
                if url.startAccessingSecurityScopedResource() {
                    return url
                } else {
                    return nil
                }
            }
        } catch {
            print("[RecentFiles] Failed to decode: \(error)")
            return []
        }
    }

    static func add(_ url: URL) {
        do {
            let bookmark = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            var entries = getAllEntries()

            // Remove duplicates
            entries.removeAll(where: { $0.url?.path == url.path })

            let newEntry = RecentFileEntry(id: UUID(), bookmarkData: bookmark, fileName: url.lastPathComponent)
            entries.insert(newEntry, at: 0)

            // Limit total entries
            if entries.count > maxFiles {
                entries = Array(entries.prefix(maxFiles))
            }

            let encoded = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("[RecentFiles] Failed to save bookmark: \(error)")
        }
    }

    private static func getAllEntries() -> [RecentFileEntry] {
        guard let rawData = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([RecentFileEntry].self, from: rawData)) ?? []
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
