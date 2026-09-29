public import Binary
public import Spatial

extension ISO_9945.Kernel.File {

    public typealias Offset = Spatial::Coordinate.X<Space>.Value<Int64>

    public typealias Delta = Spatial::Displacement.X<Space>.Value<Int64>
}

extension ISO_9945.Kernel.File.Offset {

    public static let max = Self(Int64.max)
}

extension ISO_9945.Kernel.File.Offset {

    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }
}
