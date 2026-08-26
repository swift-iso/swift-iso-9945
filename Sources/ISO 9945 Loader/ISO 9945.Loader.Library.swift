public import ISO_9945_Core
public import Loader

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if !os(Windows)

    extension ISO_9945.Loader.Library {

        @unsafe
        public static func open(
            path: UnsafePointer<CChar>?,
            options: Options = .now
        ) throws(Loader.Error) -> Handle {

            _ = unsafe dlerror()

            guard let handle = unsafe dlopen(path, options.rawValue) else {
                throw .open(ISO_9945.Loader.Error.captureError())
            }
            return unsafe Handle(rawValue: handle)
        }

        @unsafe
        public static func close(_ handle: Handle) throws(Loader.Error) {

            _ = unsafe dlerror()

            guard unsafe dlclose(handle.rawValue) == 0 else {
                throw .close(ISO_9945.Loader.Error.captureError())
            }
        }
    }

#endif
