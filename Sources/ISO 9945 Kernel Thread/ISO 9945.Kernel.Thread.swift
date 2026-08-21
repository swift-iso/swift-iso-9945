#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    public static func create(
        _ body: @escaping @Sendable () -> Void
    ) throws(ISO_9945.Kernel.Thread.Error) -> ISO_9945.Kernel.Thread.Handle {
        let context = UnsafeMutablePointer<(@Sendable () -> Void)>.allocate(capacity: 1)
        unsafe context.initialize(to: body)

        #if canImport(Darwin)
            var thread: pthread_t?

            let result = unsafe pthread_create(
                &thread,
                nil,
                { ctx in
                    let bodyPtr = unsafe ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = unsafe bodyPtr.move()
                    unsafe bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0, let thread = unsafe thread else {
                unsafe context.deinitialize(count: 1)
                unsafe context.deallocate()
                throw .create(.posix(result))
            }

            return unsafe ISO_9945.Kernel.Thread.Handle(rawValue: thread)

        #else

            var thread: pthread_t = 0

            let result = pthread_create(
                &thread,
                nil,
                { ctx in
                    guard let ctx else { return nil }
                    let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = bodyPtr.move()
                    bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0 else {
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(.posix(result))
            }

            return ISO_9945.Kernel.Thread.Handle(rawValue: thread)
        #endif
    }
}

extension ISO_9945.Kernel.Thread {

    public static func yield() {
        let result = sched_yield()
        #if DEBUG
            precondition(result == 0, "sched_yield() failed with errno \(errno)")
        #endif
    }
}
