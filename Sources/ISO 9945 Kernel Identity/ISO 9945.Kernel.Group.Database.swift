// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {
    /// Group database operations namespace.
    public enum Database {}
}

// MARK: - Lookup

extension ISO_9945.Kernel.Group.Database {
    /// The largest buffer this type will grow to before giving up on
    /// `ERANGE` and reporting a lookup failure instead of looping forever
    /// against a database entry (or a broken NSS module) that never fits.
    private static let maximumBufferSize = 1 << 20  // 1 MiB

    /// Looks up a group by name.
    ///
    /// Uses the reentrant `getgrnam_r(3)`, which reads into a caller-owned
    /// buffer rather than the shared static storage `getgrnam(3)` returns —
    /// safe under concurrent lookups on other threads.
    ///
    /// - Parameter name: The group name to look up.
    /// - Returns: The group entry, or `nil` if no such group exists.
    /// - Throws: `Error.lookup` if the lookup itself fails (distinct from
    ///   the name simply having no entry).
    public static func find(name: String) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, gr, result in
            name.withCString { cName in
                unsafe getgrnam_r(cName, gr, buffer.baseAddress, numericCast(buffer.count), result)
            }
        }
    }

    /// Looks up a group by group ID.
    ///
    /// Uses the reentrant `getgrgid_r(3)`; see `find(name:)`.
    ///
    /// - Parameter gid: The group ID to look up.
    /// - Returns: The group entry, or `nil` if no such group exists.
    /// - Throws: `Error.lookup` if the lookup itself fails (distinct from
    ///   the ID simply having no entry).
    public static func find(gid: ISO_9945.Kernel.Group.ID) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, gr, result in
            unsafe getgrgid_r(
                gid.underlying,
                gr,
                buffer.baseAddress,
                numericCast(buffer.count),
                result
            )
        }
    }

    /// Runs a `getgrnam_r`/`getgrgid_r`-shaped lookup, growing the scratch
    /// buffer on `ERANGE` up to `maximumBufferSize`.
    ///
    /// - Parameter lookup: Invokes the underlying `_r` call with the
    ///   current buffer, the `group` storage to fill, and the out
    ///   parameter that is set non-nil iff an entry was found. Returns the
    ///   `_r` call's raw result code (`0` on success, whether or not an
    ///   entry was found; nonzero is a genuine failure).
    private static func withReentrantLookup(
        _ lookup: (
            UnsafeMutableBufferPointer<CChar>,
            UnsafeMutablePointer<group>,
            UnsafeMutablePointer<UnsafeMutablePointer<group>?>
        ) -> Int32
    ) throws(Error) -> Entry? {
        var bufferSize = initialBufferSize()
        while true {
            var gr = unsafe group()
            var resultPtr: UnsafeMutablePointer<group>?
            var buffer = [CChar](repeating: 0, count: bufferSize)

            let rc = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                withUnsafeMutablePointer(to: &gr) { grPtr in
                    withUnsafeMutablePointer(to: &resultPtr) { resultPtrPtr in
                        unsafe lookup(bufferPtr, grPtr, resultPtrPtr)
                    }
                }
            }

            if rc == 0 {
                guard let resultPtr = unsafe resultPtr else { return nil }
                return unsafe entry(from: resultPtr)
            }

            if rc == ERANGE, bufferSize < maximumBufferSize {
                bufferSize *= 2
                continue
            }

            throw .lookup(.posix(rc))
        }
    }

    private static func initialBufferSize() -> Int {
        let suggested = sysconf(Int32(_SC_GETGR_R_SIZE_MAX))
        return suggested > 0 ? Int(suggested) : 1024
    }

    private static func entry(from gr: UnsafePointer<group>) -> Entry {
        var members: [String] = []
        if let memberList = unsafe gr.pointee.gr_mem {
            var i = 0
            while let member = unsafe memberList[i] {
                unsafe members.append(String(cString: member))
                i += 1
            }
        }

        return unsafe Entry(
            name: String(cString: gr.pointee.gr_name),
            gid: ISO_9945.Kernel.Group.ID(_unchecked: gr.pointee.gr_gid),
            members: members
        )
    }
}
