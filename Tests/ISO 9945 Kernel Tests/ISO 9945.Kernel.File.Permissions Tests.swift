// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Kernel_Primitives_Test_Support


extension Kernel.File.Permissions {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `Permissions from rawValue`() {
        let perms = Kernel.File.Permissions(rawValue: 0o644)
        #expect(perms.rawValue == 0o644)
    }

    @Test
    func `Permissions from integer literal`() {
        let perms: Kernel.File.Permissions = 0o755
        #expect(perms.rawValue == 0o755)
    }
}

// MARK: - Owner Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `ownerRead constant`() {
        #expect(Kernel.File.Permissions.ownerRead.rawValue == 0o400)
    }

    @Test
    func `ownerWrite constant`() {
        #expect(Kernel.File.Permissions.ownerWrite.rawValue == 0o200)
    }

    @Test
    func `ownerExecute constant`() {
        #expect(Kernel.File.Permissions.ownerExecute.rawValue == 0o100)
    }

    @Test
    func `ownerReadWrite constant`() {
        #expect(Kernel.File.Permissions.ownerReadWrite.rawValue == 0o600)
    }

    @Test
    func `ownerAll constant`() {
        #expect(Kernel.File.Permissions.ownerAll.rawValue == 0o700)
    }
}

// MARK: - Group Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `groupRead constant`() {
        #expect(Kernel.File.Permissions.groupRead.rawValue == 0o040)
    }

    @Test
    func `groupWrite constant`() {
        #expect(Kernel.File.Permissions.groupWrite.rawValue == 0o020)
    }

    @Test
    func `groupExecute constant`() {
        #expect(Kernel.File.Permissions.groupExecute.rawValue == 0o010)
    }

    @Test
    func `groupReadWrite constant`() {
        #expect(Kernel.File.Permissions.groupReadWrite.rawValue == 0o060)
    }

    @Test
    func `groupAll constant`() {
        #expect(Kernel.File.Permissions.groupAll.rawValue == 0o070)
    }
}

// MARK: - Other Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `otherRead constant`() {
        #expect(Kernel.File.Permissions.otherRead.rawValue == 0o004)
    }

    @Test
    func `otherWrite constant`() {
        #expect(Kernel.File.Permissions.otherWrite.rawValue == 0o002)
    }

    @Test
    func `otherExecute constant`() {
        #expect(Kernel.File.Permissions.otherExecute.rawValue == 0o001)
    }

    @Test
    func `otherReadWrite constant`() {
        #expect(Kernel.File.Permissions.otherReadWrite.rawValue == 0o006)
    }

    @Test
    func `otherAll constant`() {
        #expect(Kernel.File.Permissions.otherAll.rawValue == 0o007)
    }
}

// MARK: - Presets

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `none constant`() {
        #expect(Kernel.File.Permissions.none.rawValue == 0o000)
    }

    @Test
    func `standard constant (rw-r--r--)`() {
        #expect(Kernel.File.Permissions.standard.rawValue == 0o644)
    }

    @Test
    func `executable constant (rwxr-xr-x)`() {
        #expect(Kernel.File.Permissions.executable.rawValue == 0o755)
    }

    @Test
    func `privateFile constant (rw-------)`() {
        #expect(Kernel.File.Permissions.privateFile.rawValue == 0o600)
    }

    @Test
    func `privateExecutable constant (rwx------)`() {
        #expect(Kernel.File.Permissions.privateExecutable.rawValue == 0o700)
    }

    @Test
    func `privateDirectory constant (rwx------)`() {
        #expect(Kernel.File.Permissions.privateDirectory.rawValue == 0o700)
    }

    @Test
    func `standardDirectory constant (rwxr-xr-x)`() {
        #expect(Kernel.File.Permissions.standardDirectory.rawValue == 0o755)
    }
}

// MARK: - Operators

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `OR operator combines permissions`() {
        let combined = Kernel.File.Permissions.ownerRead | .ownerWrite
        #expect(combined.rawValue == 0o600)
    }

    @Test
    func `OR assignment operator`() {
        var perms = Kernel.File.Permissions.ownerRead
        perms |= .ownerWrite
        #expect(perms.rawValue == 0o600)
    }

    @Test
    func `AND operator intersects permissions`() {
        let result = Kernel.File.Permissions.standard & .ownerReadWrite
        #expect(result.rawValue == 0o600)
    }

    @Test
    func `NOT operator inverts permissions`() {
        let inverted = ~Kernel.File.Permissions.none
        #expect(inverted.rawValue == 0xFFFF)
    }
}

// MARK: - Description

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `description for standard (rw-r--r--)`() {
        #expect(Kernel.File.Permissions.standard.description == "rw-r--r--")
    }

    @Test
    func `description for executable (rwxr-xr-x)`() {
        #expect(Kernel.File.Permissions.executable.description == "rwxr-xr-x")
    }

    @Test
    func `description for none (---------)`() {
        #expect(Kernel.File.Permissions.none.description == "---------")
    }

    @Test
    func `description for all (rwxrwxrwx)`() {
        let all: Kernel.File.Permissions = 0o777
        #expect(all.description == "rwxrwxrwx")
    }
}

// MARK: - Conformances

extension Kernel.File.Permissions.Test.Unit {
    @Test
    func `Permissions is Sendable`() {
        let perms: any Sendable = Kernel.File.Permissions.standard
        #expect(perms is Kernel.File.Permissions)
    }

    @Test
    func `Permissions is Equatable`() {
        let a = Kernel.File.Permissions.standard
        let b = Kernel.File.Permissions(rawValue: 0o644)
        let c = Kernel.File.Permissions.executable
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Permissions is Hashable`() {
        var set = Set<Kernel.File.Permissions>()
        set.insert(.standard)
        set.insert(.executable)
        set.insert(.standard)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Permissions.Test.EdgeCase {
    @Test
    func `combining all individual permissions equals 0o777`() {
        let all =
            Kernel.File.Permissions.ownerRead
            | .ownerWrite
            | .ownerExecute
            | .groupRead
            | .groupWrite
            | .groupExecute
            | .otherRead
            | .otherWrite
            | .otherExecute
        #expect(all.rawValue == 0o777)
    }

    @Test
    func `preset combinations are correct`() {
        let expectedOwnerReadWrite = Kernel.File.Permissions.ownerRead | .ownerWrite
        #expect(Kernel.File.Permissions.ownerReadWrite == expectedOwnerReadWrite)

        let expectedGroupReadWrite = Kernel.File.Permissions.groupRead | .groupWrite
        #expect(Kernel.File.Permissions.groupReadWrite == expectedGroupReadWrite)

        let expectedOtherReadWrite = Kernel.File.Permissions.otherRead | .otherWrite
        #expect(Kernel.File.Permissions.otherReadWrite == expectedOtherReadWrite)
    }
}
