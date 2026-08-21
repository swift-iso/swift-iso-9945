public import Tagged_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Group {

    public typealias ID = Tagged<ISO_9945.Kernel.Process.Group, Int32>
}

extension Tagged where Tag == ISO_9945.Kernel.Process.Group, Underlying == Int32 {

    #if !os(Windows)

        public static var current: Self { Self(_unchecked: getpgrp()) }
    #endif
}
