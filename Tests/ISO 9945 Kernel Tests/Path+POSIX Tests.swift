import ISO_9945_Kernel
import Path
import Testing

enum `Path+POSIX Tests` {}

extension `Path+POSIX Tests` {
    @Suite
    struct `Path + POSIX grammar` {

        @Test
        func `absolute, relative and root`() {
            let absolute: Path = "/usr/local"
            let relative: Path = "usr/local"
            let root: Path = "/"
            #expect(absolute.isAbsolute)
            #expect(relative.isRelative)
            #expect(root.isRoot)
            #expect(!absolute.isRoot)
        }

        @Test
        func `an interpolated literal spells a path and a component`() {
            let name = "local"
            let path: Path = "/usr/\(name)/bin"
            let component: Path.Component = "\(name).txt"
            #expect(path == "/usr/local/bin")
            #expect(component == "local.txt")
        }

        @Test
        func `parent climbs to the root, then stops`() {
            let path: Path = "/usr/local/bin"
            #expect(path.parent == "/usr/local")
            #expect(path.parent?.parent == "/usr")
            #expect(path.parent?.parent?.parent == "/")
            #expect(path.parent?.parent?.parent?.parent == nil)
            let single: Path = "file"
            #expect(single.parent == nil)
        }

        @Test
        func `components skip empty segments`() {
            let path: Path = "//usr///local/bin/"
            #expect(path.components.map(\.string) == ["usr", "local", "bin"])
            #expect(path.components.count == 3)
            #expect(path.components.last == "bin")
            #expect(path.components.reversed().map(\.string) == ["bin", "local", "usr"])
            #expect(path.lastComponent == "bin")
            let root: Path = "/"
            #expect(root.components.isEmpty)
            #expect(root.lastComponent == nil)
        }

        @Test
        func `appending joins with exactly one separator`() throws {
            let path: Path = "/usr"
            let slash: Path = "/usr/"
            #expect(path / "local" == "/usr/local")
            #expect(slash / "local" == "/usr/local")
            #expect(try path.appending("bin") == "/usr/bin")
            let relative: Path = "a/b"
            let absolute: Path = "/etc"
            #expect(path / relative == "/usr/a/b")
            #expect(path / absolute == "/etc")
        }

        @Test
        func `hasPrefix compares components and absoluteness`() {
            let path: Path = "/Users/coen/Documents"
            let prefix: Path = "/Users/coen"
            let partial: Path = "/Users/co"
            let relative: Path = "Users"
            #expect(path.hasPrefix(prefix))
            #expect(!path.hasPrefix(partial))
            #expect(!path.hasPrefix(relative))
        }

        @Test
        func `relative(to:) strips the base, or gives dot`() {
            let path: Path = "/Users/coen/Documents/file.txt"
            let base: Path = "/Users/coen"
            let other: Path = "/Users/other"
            #expect(path.relative(to: base) == "Documents/file.txt")
            #expect(path.relative(to: path) == ".")
            #expect(path.relative(to: other) == nil)
            let trailing: Path = "/a/b/c/"
            let a: Path = "/a"
            #expect(trailing.relative(to: a) == "b/c")
        }

        @Test
        func `the grammar reaches the unique and small stores`() throws {
            let unique = try Path.Unique("/usr/local")
            let parent = unique.parent
            #expect(parent?.string == "/usr")
            let small = try Path.Small<64>("/usr/local")
            #expect(small.parent?.string == "/usr")
            #expect((small / "bin").string == "/usr/local/bin")
        }

        @Test
        func `filenames reject separators and control characters`() {
            let texts: [(Swift.String, ISO_9945.Filename.Error)] = [
                ("", .empty),
                ("a/b", .containsPathSeparator),
                ("a\nb", .containsControlCharacters),
            ]
            for (text, error) in texts {
                #expect(throws: error) { _ = try ISO_9945.Filename(text) }
            }
            let name: ISO_9945.Filename = "file.txt"
            #expect(name.count == 8)
            #expect(Path.Component.self == ISO_9945.Filename.self)
        }
    }
}
