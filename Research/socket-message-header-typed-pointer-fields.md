# Socket.Message.Header Typed Pointer-Field Wrappers Investigation

Date: 2026-04-22
Scope: package-local (`swift-iso-9945`); cross-reference to `swift-kernel-primitives` and `swift-foundations/swift-sockets` for consumer context
Audit finding: P2.4 #8 — `Kernel.Socket.Message.Header.{Name, Vectors, Control}` expose `pointer: UnsafeMutableRawPointer?` + length fields; should wrap in typed ecosystem types per [PLAT-ARCH-005a].
Status: **OPTIONS MATRIX — decision escalates to principal**

This document surveys options for resolving the raw-pointer leak in the three sub-structs of `Kernel.Socket.Message.Header`. It does not commit a decision; each recommendation below names what remains for the principal.

## Problem Statement

`swift-iso/swift-iso-9945/Sources/ISO 9945 Kernel Socket/ISO 9945.Kernel.Socket.Message.Header.swift:18` defines `Kernel.Socket.Message.Header` — an L2 binary-compatible wrapper around POSIX `struct msghdr`. It exposes three sub-struct types as its typed field surface:

- **`Header.Name`** at `.Message.Header.Name.swift:5` — socket-address descriptor, fields `pointer: UnsafeMutableRawPointer?` + `length: UInt32`.
- **`Header.Vectors`** at `.Message.Header.Vectors.swift:8` — scatter/gather I/O vector descriptor, fields `pointer: UnsafeMutableRawPointer?` + `count: Int`.
- **`Header.Control`** at `.Message.Header.Control.swift:5` — ancillary data descriptor, fields `pointer: UnsafeMutableRawPointer?` + `length: Int`.

Per [PLAT-ARCH-005a] "No Platform C Types in Public API", raw `UnsafeMutableRawPointer?` is a C-layer leak in a public L2 API. The audit's finding #8 asks: *"wrap `pointer: UnsafeMutableRawPointer?` + length fields in typed ecosystem types."* The finding's `Recommended structural fix` elaborates: *"wrap iovec tuples in `Kernel.IO.Vector.Segment` (type already exists per file listing); wrap msghdr pointer+length fields in typed ecosystem types."*

The finding is silent on exactly WHAT typed ecosystem types to use for each slot (one candidate exists for Vectors; Name has a candidate; Control has no pre-existing ecosystem type). The silence is the design space.

## Constraints Inventory

1. **`Kernel.Socket.Message.Header` is L2-defined (not L1).** `rg "public struct Header" swift-kernel-primitives` returns nothing; the only `Header` definition in the ecosystem is at `swift-iso-9945/Sources/ISO 9945 Kernel Socket/ISO 9945.Kernel.Socket.Message.Header.swift:18`. This differs materially from Doc 1 (File.Handle was L1) — Doc 1's "method-level split" option (Option 5) derived its elegance from the L1 type being cross-layer-visible; here, any L3-facing reshape has to either export across the layer boundary or accept that Header is exclusively an L2 surface.

2. **`msghdr` is borrowed storage, not owned.** The C contract: the user allocates storage for the socket address, iovec array, and control buffer; fills in msghdr's pointers; calls sendmsg/recvmsg. msghdr does NOT own those buffers. Any Swift wrapper must preserve this: the Header is a *descriptor*, not a container. Wrapping "pointer" as an owned typed value (e.g., `Kernel.Socket.Address.Storage` — which owns a `sockaddr_storage` by value) changes the ownership semantics and would require copy-in/copy-out at the syscall boundary.

3. **`Kernel.IO.Vector.Segment` already exists** at `swift-iso/swift-iso-9945/Sources/ISO 9945 Kernel File/ISO 9945.Kernel.IO.Vector.Segment.swift:38` — the natural "typed iovec" ecosystem type. Its own shape is `base: UnsafeMutableRawPointer? + length: Int` (identical to `Header.Vectors`'s shape, just renamed fields) with `@unsafe init`. Binary-compatible with `iovec`. This tells us: the ecosystem's existing answer to "typed pointer+length" is to keep the raw pointer but put a type around it and mark `@unsafe`. The audit's implicit endorsement ("type already exists per file listing") supports wrapping Vectors in `[Kernel.IO.Vector.Segment]` — but that wrap is descriptor-style, not pointer-type-narrowing.

4. **`Kernel.Socket.Address.Storage` exists** at `swift-iso/swift-iso-9945/Sources/ISO 9945 Kernel Socket Address/ISO 9945.Kernel.Socket.Address.Storage.swift:17` as the typed cross-family sockaddr wrapper (holds `sockaddr_storage` by value; has `.family` accessor). It is the natural typed candidate for Name's `pointer` slot, but Storage is *owned* — its cValue is a member, not a pointer — which creates the Constraint 2 ownership mismatch.

5. **No typed control-message wrapper exists in the ecosystem.** `rg "struct .*Control|cmsghdr|ControlMessage"` across swift-kernel-primitives + iso-9945 returns nothing for cmsghdr. The audit's ask implicitly requires inventing one.

6. **swift-sockets' consumption is shallow.** `swift-foundations/swift-sockets/Sources/Sockets/Kernel.Socket.Send+CrossPlatform.POSIX.swift:105` and `.Receive+CrossPlatform.POSIX.swift:97` pass Header through by `inout` to the L3 unifier. swift-sockets does not touch the sub-struct fields; it's a conduit. Consumers BEYOND swift-sockets (higher-level socket libraries that use sendmsg/recvmsg for ancillary data like file descriptors over UNIX sockets, multicast source control, etc.) would be the ones feeling the sub-struct shape most — but those consumers aren't in this workspace to survey. Assumption: external consumers exist but are not currently identifiable.

7. **Finding #9 (sibling) already RESOLVED**: `Message.Header.flags: Int32` → `Kernel.Socket.Message.Options` typed OptionSet (swift-iso-9945 `e554f7a`, RESOLVED 2026-04-21 per the platform audit tracker). Precedent: Header's int fields are typeable via OptionSet without breaking msghdr binary compatibility. The pointer fields are structurally different — pointers can be typed-wrapped without layout break only if the wrapper itself remains pointer-layout-equivalent (see Option 1) or if layout equivalence is abandoned (see Options 3, 5).

8. **`@unchecked Sendable` on Header.** Header is `@unchecked Sendable` because it embeds `msghdr` (a C struct with raw pointers). Any typed-wrapping design that adds Swift reference/collection types to Header's field surface has to re-verify Sendable carefully — collections of typed wrappers must be Sendable themselves, and the "no ownership of pointed-to storage" invariant must still hold.

## Options Matrix

Five options. All three handoff-implicit options ("leave as-is", "wrap pointer in typed ecosystem type", "go full scope-based") plus two non-obvious candidates surfaced by pushing past the parent-handoff framing per principal's Doc 2 guidance.

### Option 1: Typed-container wrap in place (descriptor-style, matches Vector.Segment)

**Shape**: Keep `Header.Name`, `Header.Vectors`, `Header.Control` as sub-struct types. Replace each `pointer: UnsafeMutableRawPointer?` with a typed pointer, and mark the init + any mutation `@unsafe`:

```swift
// Name — typed pointer to sockaddr-family via Kernel.Socket.Address.Storage
public struct Name: @unchecked Sendable {
    @unsafe public var pointer: UnsafeMutablePointer<Kernel.Socket.Address.Storage>?
    public var length: UInt32
    @unsafe public init(pointer: UnsafeMutablePointer<Kernel.Socket.Address.Storage>? = nil, length: UInt32 = 0) { … }
}

// Vectors — typed pointer to Kernel.IO.Vector.Segment array
public struct Vectors: @unchecked Sendable {
    @unsafe public var pointer: UnsafeMutablePointer<Kernel.IO.Vector.Segment>?
    public var count: Int
    …
}

// Control — new typed opaque
public struct Control: @unchecked Sendable {
    @unsafe public var pointer: UnsafeMutableRawPointer?  // stays raw; no typed ecosystem partner
    public var length: Int
    …
}
```

**Pros**:
- Smallest delta from current code; binary layout preserved.
- Uses existing ecosystem types (Storage, Vector.Segment) where they fit.
- `@unsafe` markers signal the raw-memory boundary without reshaping the API.

**Cons**:
- Name's `UnsafeMutablePointer<Storage>` is a lie about ownership — msghdr's `msg_name` points to user-allocated memory that's typically a `sockaddr_in` or `sockaddr_in6`, not a `sockaddr_storage` by value. Reinterpreting that memory as `Storage*` can be layout-incompatible (Storage is `sockaddr_storage` — 128 bytes — whereas `sockaddr_in` is 16 bytes). The typed wrap is MISLEADING here.
- Control stays raw because no typed partner exists; the finding is only 2/3 addressed.
- Doesn't address the audit's deeper ask (finding says "wrap pointer+length in typed ecosystem types" — in place typed pointers are a wrap, but the pointer-length *pair* remains the public contract).

**Consumer impact**: Minor; in-ecosystem consumers that construct Header manually must cast their `sockaddr_in` pointers to `Storage*` (unsound layout-wise — see cons). External consumers likely broken.

### Option 2: Accessor-level replacement on Header (drop sub-struct types)

**Shape**: Delete `Header.Name`, `Header.Vectors`, `Header.Control` sub-struct types. Replace Header's accessors with typed-direct:

```swift
extension Kernel.Socket.Message.Header {
    // Owned typed address, copy-in/out to/from msghdr.msg_name
    public var address: Kernel.Socket.Address.Storage? {
        get { … unsafe read msg_name as sockaddr_storage; return Storage or nil … }
        set { … allocate + copy into an internal backing store; wire msg_name … }
    }

    public var vectors: [Kernel.IO.Vector.Segment] {
        get { … rehydrate from msg_iov + msg_iovlen … }
        set { … backing-store array; wire msg_iov + msg_iovlen … }
    }

    // Control stays — no typed ecosystem partner
    public var control: Control  // or similar compromise
}
```

Header would need private backing storage (`_addressBacking: Kernel.Socket.Address.Storage?`, `_vectorsBacking: [Kernel.IO.Vector.Segment]`) to own the memory that msg_name/msg_iov point at.

**Pros**:
- Eliminates the raw-pointer public surface for Name and Vectors — consumers set typed values; Header manages pointer wiring internally.
- Removes three sub-struct types from the public API (simplification).
- Maps naturally onto how Swift code would want to build a message: typed addresses, typed vector arrays.

**Cons**:
- Changes Header's fundamental semantics from *descriptor* to *owner*. The ownership shift (Constraint 2) is non-trivial: Header now allocates and copies; it's no longer pointer-equivalent to msghdr.
- Performance cost: copy-in/out on every access; allocation on mutation.
- Header is `@unchecked Sendable`; adding collection-typed backing storage forces re-verification of the Sendable contract (arrays of `Kernel.IO.Vector.Segment` are mutable; `@unchecked` is load-bearing).
- Control still escapes the typed wrap.
- Existing consumers that relied on descriptor semantics (set pointer to external buffer, call syscall) break; their borrowing-memory pattern no longer fits.

**Consumer impact**: High — descriptor-pattern consumers must restructure to owning-pattern.

### Option 3: L2 keeps raw sub-structs `@_spi(Syscall)`; L3 adds a typed construction API

**Shape** (method-level split, mirroring Doc 1's Option 5 adapted for a non-L1 type):
- L2 iso-9945: demote `Header.Name`, `Header.Vectors`, `Header.Control` and their pointer fields to `@_spi(Syscall)`. Header struct itself stays public; raw access is SPI.
- L3 swift-posix (or a new target): add typed-construction API. Two sub-options:
  - **3a — scope-based**: `POSIX.Kernel.Socket.Message.withHeader(address:..., vectors:..., control:...) { header throws(E) in … syscall(header) }`. Header never leaves the scope; typed inputs are converted to msghdr pointers internally.
  - **3b — typed accessor extension**: extensions on `Kernel.Socket.Message.Header` in swift-posix that set typed values via SPI pointer-manipulation. Consumer-facing get/set is typed; the SPI is hidden.

**Pros**:
- Strongest layer split: L2 is spec-literal msghdr, L3 is typed consumer API. Matches [PLAT-ARCH-008e] directly.
- No change to binary compatibility of L2 Header.
- SPI demotion signals "this is low-level syscall contract; use L3 for typed access."
- 3a specifically: scope ownership enforces msghdr's borrowed-storage semantics at the type level — Header can't outlive its typed inputs.

**Cons**:
- Cascade identical to P3.3 iso-9945 #10 (Socket.Address.Storage SPI demotion): the SPI gate on Header propagates through the re-export chain (`ISO_9945_Kernel_Socket` → `POSIX_Kernel_Socket` → `Kernel_Core` → `Kernel`), requiring `@_spi(Syscall) @_exported public import` upgrades at multiple hops. Prior Doc 1 work flagged this as a ~13-file cascade.
- `@inlinable` incompatibility risk (2026-04-20 L2/L3 latent-ambiguity reflection): if L3 wrappers are `@inlinable` and reference SPI symbols, compile fails. The current L3 unifier `Kernel.IO.Write.writeAll` is `@inlinable`; the socket-side unifier is likely similar. Pre-check required.
- Adds a new L3 API surface (new files in swift-posix, or a new target); bigger scope than options 1, 2, 4.

**Consumer impact**: Low for consumers using the L3 typed API. High for any current consumer that directly accessed the L2 sub-structs — they'd need `@_spi(Syscall)` import OR migrate to the L3 typed API.

### Option 4: Accept current state as the ecosystem's answer; close the finding with a codified explanation

**Shape**: No code change. Update `Header.Name/Vectors/Control` docs to explicitly state: "These are descriptor-style typed wrappers following the `Kernel.IO.Vector.Segment` pattern — the pointer-length pair IS the typing. Platform C types are not exposed because the sub-struct is the type; the pointer within is an `UnsafeMutableRawPointer?`, a Swift stdlib type, not a C `void*`." Add a cross-reference to Vector.Segment establishing this as the ecosystem's intentional choice for descriptor-style typed wrappers.

Additionally: codify the pattern in a [PLAT-ARCH-005a] clarification sub-rule: "descriptor-style typed wrappers (a struct wrapping `UnsafeMutableRawPointer?` + length for kernel ABI compatibility) satisfy [PLAT-ARCH-005a] if and only if the struct itself is ecosystem-typed and marked with `@unsafe` initializer."

**Pros**:
- Zero code disruption.
- Honest: the sub-structs ARE the typing in the descriptor-style idiom the ecosystem has adopted (Vector.Segment shares this exact shape).
- Codifies the pattern so future audits don't re-open this finding.

**Cons**:
- Defends current state; audit's finding stands as "not fixed" in spirit — the audit's `pointer: UnsafeMutableRawPointer?` callout is ratified, not addressed.
- The descriptor-style idiom is a weak interpretation of [PLAT-ARCH-005a]. [PLAT-ARCH-005a]'s stated decision test is: *"Can a consumer of this API write their code without importing the platform's C module?"* For Header.Name/Vectors/Control, a consumer can write code without importing Darwin/Glibc directly — the `UnsafeMutableRawPointer?` is stdlib. So Option 4 may be technically compliant already. Principal judgment call: is "doesn't import Darwin/Glibc" sufficient, or does [PLAT-ARCH-005a] ALSO want "doesn't expose raw pointers"?
- Control's pointer is still untyped in the sense that no ecosystem type describes what's at the other end; the documentation-only fix glosses this.

**Consumer impact**: Zero.

### Option 5: Replace sub-structs with `~Escapable` scoped views + L2 SPI

**Shape** (lifetime-safe, farther-reaching than Option 3):
- Introduce `~Escapable` typed views on each pointer slot:
  - `Header.Name.View` — `~Escapable`, lifetime-bound to a source `Kernel.Socket.Address.Storage`.
  - `Header.Vectors.View` — `~Escapable`, lifetime-bound to an `UnsafeBufferPointer<Kernel.IO.Vector.Segment>`.
  - `Header.Control.View` — `~Escapable`, lifetime-bound to an `UnsafeRawBufferPointer`.
- The raw Header struct becomes SPI; typed construction goes through `withHeader` closures that produce ~Escapable sub-views and the Header itself is ~Escapable for the duration of the syscall.
- Compile-time enforcement that msghdr pointers cannot outlive their source storage.

**Pros**:
- Strongest lifetime safety: the borrowed-storage semantics of msghdr become a compile-time invariant, not a discipline.
- Closes the raw-pointer leak completely — consumers don't see `UnsafeMutableRawPointer?` anywhere.
- Aligns with the ecosystem's broader push toward ~Escapable views for descriptor-style wrappers (Path.View, Span precedents).

**Cons**:
- Largest scope: new ~Escapable types + new L3 construction API + L2 SPI demotion + re-export-chain `@_spi` cascade.
- ~Escapable ecosystem tooling is still maturing; known gaps (`@_lifetime(&self)` + Escapable-result rule tightening on Swift 6.3 per memory records). Risk that the design hits compiler limitations.
- Performance overhead of the `withHeader` closure + view construction per syscall.
- Doc 1's Option 5 was a 1-file additive change; this is an ecosystem-shifting API redesign. Wrong mass for a P2 audit-finding remediation.

**Consumer impact**: Very high — all existing consumers migrate from raw pointer-descriptor to scoped-view construction.

## Evidence

### Grep results — prior research per [HANDOFF-013a]

```
$ rg -l "Message.Header|msghdr|Vectors|Control" swift-iso/swift-iso-9945/Research/
iso-9945-spec-coverage-gap-analysis.md     ← spec-coverage migration context; no typed-wrapper design discussion
system-decomposition.md                     ← target-boundary context, not API-shape
iso-9945-kernel-modularization.md           ← target-boundary context, not API-shape

$ rg -l "Message.Header|msghdr|Vectors|Control" swift-foundations/swift-sockets/Research/
(swift-sockets has no Research/ directory; the 2 Sockets/ hits are source files, not docs)

$ rg -l "msghdr|Message.Header|Vectors|ControlMessage" swift-institute/Research/
file-handle-writeall-l2-l3-layering.md     ← Doc 1 (self-hit, skip)
unified-geometry-types-research.md          ← checked, not materially relevant (Vectors as geometry, not socket)
Reflections/2026-04-12-iso-9945-posix-gap-analysis-and-implementation.md   ← migration history; no typed-wrapper design
Reflections/2026-04-12-io-uring-escapable-coroutine-discovery.md          ← ~Escapable context for Option 5 only
io-prior-art-per-system-reference.md        ← cross-system reference, no msghdr typed-wrapper convention
```

Prior research contains migration history (Message.Header moved FROM Linux Kernel Socket Standard TO iso-9945) and spec-coverage tracking, but no design-space discussion of typed pointer-field wrappers. This finding's design space is unexplored prior art; the options matrix is the first systematic survey.

### Current-state code citations

- Header definition: `ISO 9945.Kernel.Socket.Message.Header.swift:18` (`@unchecked Sendable` wrapping `cValue: msghdr`).
- Sub-struct definitions: `.Message.Header.Name.swift:5`, `.Message.Header.Vectors.swift:8`, `.Message.Header.Control.swift:5` — all `@unchecked Sendable`, all pointer+length fields.
- Parallel typed iovec: `ISO 9945.Kernel.IO.Vector.Segment.swift:38` — same pointer+length shape, `@unsafe init`, binary-compatible with iovec.
- Parallel typed sockaddr: `ISO 9945.Kernel.Socket.Address.Storage.swift:17` — owned `sockaddr_storage`, not pointer-style.
- swift-sockets consumption: `Kernel.Socket.Send+CrossPlatform.POSIX.swift:105`, `Kernel.Socket.Receive+CrossPlatform.POSIX.swift:97` — `inout Kernel.Socket.Message.Header`, passthrough only.
- Audit P2.4 #8: `swift-institute/Audits/platform-compliance-2026-04-21.md:96` (Pattern 2 evidence), `:304` (P2.4 finding listing).

### L1/L2/L3 type-location diagnostic (Doc 2 pattern)

Per Doc 1's forward-looking guidance, ran `rg "public struct Header|public enum Header" swift-primitives/swift-kernel-primitives/Sources` — zero hits. Confirms `Message.Header` is L2-exclusive. This is different from File.Handle (L1) and means the "L1 type + L2/L3 method-level split" pattern from Doc 1 does NOT apply here; Header's options are constrained to L2-internal changes or cross-layer API additions.

## Recommendation

**Option 1 (typed-container wrap in place) with a caveat → likely escalate to Option 3 (L3 typed construction API) if the `@unsafe` descriptor-style wrap is judged insufficient.**

Reasoning:
- The ecosystem's existing answer for "typed descriptor-style wrapper" is Kernel.IO.Vector.Segment. Applying the same pattern to Header.Name/Vectors/Control is structurally consistent. Option 1 is the narrowest code change that keeps Header binary-compatible with msghdr while moving the raw-pointer surface under typed wrappers and `@unsafe` initializers.
- Option 2 (owner-semantics on Header) is rejected because it breaks the borrowed-storage invariant (Constraint 2) — msghdr IS a pointer-to-external-storage descriptor, and making Header own a backing address/vector collection is a semantic change, not a typing change.
- Option 4 (codify current state) is a live alternative IF the principal judges [PLAT-ARCH-005a] as satisfied by "struct wrapping `UnsafeMutableRawPointer?` + length is typed ecosystem-native." Principal decision needed.
- Option 3 (L2 SPI + L3 typed construction) is the right answer if the principal judges that [PLAT-ARCH-005a]'s goal is to eliminate raw pointers entirely (not just keep them within typed wrappers). It is a cascade-scoped remediation comparable to P3.3 iso-9945 #10's SPI half — `@_spi` re-export propagation through ~13 files across 4 packages. If pursued, it should be paired with P3.3 #10's SPI work as a unified L2-socket-SPI-demotion cycle rather than as isolated per-finding cascades.
- Option 5 (~Escapable scoped views) is architecturally appealing but the scope mass (new ~Escapable types + new L3 API + SPI cascade + compiler-limitation risk) is wrong for a P2 remediation. Defer as a possible post-completion polish cycle.

**Caveat on Option 1's Name.pointer**: typed pointer `UnsafeMutablePointer<Kernel.Socket.Address.Storage>?` is layout-unsound because msg_name typically points to a `sockaddr_in` / `sockaddr_in6` (16 / 28 bytes) rather than `sockaddr_storage` (128 bytes). Consumers would cast, and the cast is valid because sockaddr_storage is designed to be interpretable-as-any-family. But the type claim reads stronger than it is. Alternative: leave Name's pointer as `UnsafeMutableRawPointer?` (still wrapped in the typed Name struct, which is what the ecosystem considers "typed"). The wrap is then semantically: *"this struct IS the type; the untyped pointer inside is irreducible because sendmsg accepts any sockaddr-family."* That matches Vector.Segment's precedent (Vector.Segment.base is `UnsafeMutableRawPointer?`, not typed to a specific buffer element).

**Refined Option 1'**: accept that Header.Name.pointer stays `UnsafeMutableRawPointer?` (the struct type IS the typing, matching Vector.Segment); change Vectors.pointer to `UnsafeMutablePointer<Kernel.IO.Vector.Segment>?` (iovec layout is a fixed shape); keep Control.pointer as `UnsafeMutableRawPointer?` until a typed cmsghdr view is designed (out of scope).

Refined Option 1' is the narrowest addressing of the finding without going beyond what the ecosystem currently supports. It resolves Vectors' typing (the one slot where a typed ecosystem pointer exists); it documents Name's and Control's untyped pointers as the current best (the struct IS the typing); it closes the finding with minimal code change.

## Open Questions (escalating to principal)

1. **Primary decision**: approve Option 1' (narrow typed-pointer wrap on Vectors only; keep Name/Control pointer shape with codified rationale) OR Option 3 (L2 SPI + L3 typed construction API, ~13-file cascade comparable to P3.3 #10)? Option 1' is the minimum-change path consistent with ecosystem precedent; Option 3 is the strict-[PLAT-ARCH-005a] path with significant scope. Options 2, 4, 5 are rejected above with reasons.

2. **[PLAT-ARCH-005a] interpretation**: does the rule's text — *"public APIs MUST NOT expose C types in parameters, return types, associated types, or generic constraints"* — consider `UnsafeMutableRawPointer?` a "C type"? It's a Swift stdlib type, not imported from Darwin/Glibc, but semantically it is the raw-pointer C primitive. The options matrix's split between Options 1/4 (treat as compliant) and Option 3/5 (treat as non-compliant) turns on this interpretation. Principal's ruling binds future audit interpretations of the rule.

3. **Cmsghdr/Control typed wrapper design** (Option 3-conditional): no ecosystem type currently exists for typed ancillary-data buffers. POSIX `cmsghdr` is a variable-length structure (header + data) chained via `CMSG_NXTHDR`. A typed wrapper would need to represent this chain — either as `[Kernel.Socket.Control.Message]` (owned, copy-in/out) or as a scoped view. Does the principal want this designed in a subsequent cycle (blocking Option 3's full completion), or can Option 3 land Name/Vectors with Control documented as "pending typed-cmsghdr design"?

4. **Coordination with P3.3 iso-9945 #10 SPI cascade** (Option 3-conditional): if Option 3 is chosen, the `@_spi(Syscall)` re-export propagation required for Message.Header's sub-structs is the same cascade required for `Kernel.Socket.Address.Storage.withUnsafe[Mutable]Bytes` (P3.3 #10's deferred SPI half). Does the principal want these bundled as a single L2-socket-SPI-demotion cycle (landed together in one implementation slot), or as sequential cycles?

5. **Constraint mismatch evidence — layout soundness of `UnsafeMutablePointer<Kernel.Socket.Address.Storage>` for `msg_name`**: the Doc notes this is "unsound" because real msg_name allocations are typically `sockaddr_in`/`sockaddr_in6` (not `sockaddr_storage`). In practice, C APIs cast `(struct sockaddr *)` to/from family-specific sockaddr pointers and this is standard POSIX idiom. Is the concern load-bearing in Swift — does `UnsafeMutablePointer<Storage>` promise size-equal-to-Storage memory access on deref? Needs a compiler/type-system investigation or a minimal-experiment. Flagged as an implementation-cycle pre-check; does the principal want this investigation blocking the decision, or is "document as an open concern, ship Option 1' with Name's pointer staying `UnsafeMutableRawPointer?`" acceptable?

6. **Drive-by observation — Refined Option 1' leaves Control untyped**: the finding's wording ("wrap [all three] in typed ecosystem types") isn't fully satisfied. Does the principal view Refined Option 1' as "full close" (Control's typing is out of scope because no ecosystem type exists) or "partial close" (Control's typing is pending a future cycle that designs `Kernel.Socket.Control.Buffer`)? Tracker-note framing depends on the answer.

## Appendix — [SUPER-015] tactical decisions made during investigation

- Ran the L1-vs-L2 type-location diagnostic per principal's Doc 2 guidance; confirmed Header is L2-exclusive. Recorded as Constraint #1 because it MATERIALLY limits the option space (no Doc 1-Option-5 analog is available).
- Checked swift-sockets/Research/ per guidance; confirmed no such directory exists. Substituted direct grep of swift-sockets/Sources/ for consumer-side context.
- Pushed past the parent handoff's implicit 2-option framing ("wrap or leave alone") per principal's guidance; surfaced Options 2 (accessor-level replacement), 3 (L3 typed-construction API), 5 (~Escapable views) as non-obvious additions.
- Introduced "Refined Option 1'" to acknowledge that Option 1's Name-slot typed pointer is layout-unsound; chose to surface this in the Recommendation section rather than bury it, because the refinement is load-bearing for whether Option 1 is viable at all.
- Did NOT investigate the cmsghdr typed-wrapper design space in this doc (flagged as Open Question #3); the design would materially expand Doc 2's scope and is parallel to the "add typed-accessors" scope expansion the principal rejected during Doc 1 supervise.
- Did NOT run a consumer grep across the full ecosystem for direct usages of `Header.Name/Vectors/Control` field access (beyond swift-sockets); flagged as an implementation-cycle pre-check. Unlike Doc 1, the Headercase likely has more varied consumers (sendmsg/recvmsg is a standard idiom for ancillary data use cases), but the options matrix is decidable without the exact call-site enumeration.
