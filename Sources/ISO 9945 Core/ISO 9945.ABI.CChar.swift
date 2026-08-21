#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    extension UnsafePointer where Pointee == CChar {

        @inlinable
        @unsafe
        package init(_ pointer: UnsafePointer<UInt8>) {
            unsafe (self = UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
        }
    }

    extension UnsafeMutablePointer where Pointee == CChar {

        @inlinable
        @unsafe
        package init(_ pointer: UnsafeMutablePointer<UInt8>) {
            unsafe (self = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CChar.self))
        }
    }

    extension UnsafePointer where Pointee == UInt8 {

        @inlinable
        @unsafe
        package init(_ pointer: UnsafePointer<CChar>) {
            unsafe (self = UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self))
        }
    }

    extension UnsafeMutablePointer where Pointee == UInt8 {

        @inlinable
        @unsafe
        package init(_ pointer: UnsafeMutablePointer<CChar>) {
            unsafe (self = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self))
        }
    }

#endif
