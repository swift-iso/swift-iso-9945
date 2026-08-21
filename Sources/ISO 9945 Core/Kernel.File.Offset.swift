public import Binary_Primitives
public import Dimension_Primitives

extension ISO_9945.Kernel.File {

    public typealias Offset = Coordinate.X<Space>.Value<Int64>

    public typealias Delta = Displacement.X<Space>.Value<Int64>
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
