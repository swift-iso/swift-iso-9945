// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import ISO_9945_Kernel

@Suite
struct `Socket Address Info Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Socket Address Info Tests`.Unit {
    @Test
    func `error message is non empty and codes round trip`() {
        let error = ISO_9945.Kernel.Socket.Address.Info.Error.noName
        #expect(!error.message.isEmpty)
        #expect(ISO_9945.Kernel.Socket.Address.Info.Error(code: error.code) == .noName)
    }
}

extension `Socket Address Info Tests`.`Edge Case` {
    @Test
    func `non numeric garbage under numericHost throws noName`() {
        do throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
            _ = try ISO_9945.Kernel.Socket.Address.Info.List.get(
                host: "definitely-not-numeric.invalid",
                hints: .init(options: .numericHost, family: .inet)
            )
            Issue.record("Expected a host-resolution failure")
        } catch {
            #expect(error == .noName)
        }
    }

    @Test
    func `storage typed downcast returns nil for the wrong family`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        let list = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "127.0.0.1",
            hints: .init(options: .numericHost, family: .inet, kind: .stream)
        )
        guard let entry = list.entries.first else {
            Issue.record("Expected at least one entry")
            return
        }
        let missing = entry.address.ipv6 == nil
        #expect(missing)
    }
}

extension `Socket Address Info Tests`.Integration {
    @Test
    func `numeric IPv4 host resolves to one owned inet entry`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        let list = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "127.0.0.1",
            hints: .init(
                options: .numericHost,
                family: .inet,
                kind: .stream
            )
        )
        let entries = list.entries

        guard let entry = entries.first else {
            Issue.record("Expected at least one entry")
            return
        }
        #expect(entry.family == .inet)
        #expect(entry.kind == .stream)
        guard let typed = entry.address.ipv4 else {
            Issue.record("Expected an IPv4 downcast")
            return
        }
        #expect(typed.address == UInt32(0x7F00_0001).bigEndian)
    }

    @Test
    func `numeric IPv6 loopback resolves to one owned inet6 entry`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        let list = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "::1",
            hints: .init(
                options: .numericHost,
                family: .inet6,
                kind: .stream
            )
        )
        let entries = list.entries

        guard let entry = entries.first else {
            Issue.record("Expected at least one entry")
            return
        }
        #expect(entry.family == .inet6)
        guard let typed = entry.address.ipv6 else {
            Issue.record("Expected an IPv6 downcast")
            return
        }
        let segments = typed.segments
        #expect(segments.0 == 0)
        #expect(segments.1 == 0)
        #expect(segments.2 == 0)
        #expect(segments.3 == 0)
        #expect(segments.4 == 0)
        #expect(segments.5 == 0)
        #expect(segments.6 == 0)
        #expect(segments.7 == 1)
    }

    @Test
    func `family hint filters entries to the requested family`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        let list = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "127.0.0.1",
            hints: .init(options: .numericHost, family: .inet, kind: .stream)
        )
        for entry in list.entries {
            #expect(entry.family == .inet)
        }
    }

    @Test
    func `entries preserve chain order across repeated resolution`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        let first = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "127.0.0.1",
            hints: .init(options: .numericHost, family: .inet, kind: .stream)
        ).entries
        let second = try ISO_9945.Kernel.Socket.Address.Info.List.get(
            host: "127.0.0.1",
            hints: .init(options: .numericHost, family: .inet, kind: .stream)
        ).entries
        #expect(first == second)
    }

    @Test
    func `repeated list creation and destruction frees every chain`() throws(ISO_9945.Kernel.Socket.Address.Info.Error) {
        for _ in 0..<128 {
            let list = try ISO_9945.Kernel.Socket.Address.Info.List.get(
                host: "127.0.0.1",
                hints: .init(options: .numericHost, family: .inet, kind: .stream)
            )
            #expect(!list.entries.isEmpty)
        }
    }
}
