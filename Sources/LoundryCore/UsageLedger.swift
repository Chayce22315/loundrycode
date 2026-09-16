import Foundation

public enum LoundryPlan: String, Codable, Sendable, Hashable {
    case free
    case pro
}

public struct UsageSnapshot: Codable, Sendable, Hashable {
    public let plan: LoundryPlan
    public let usedUnorthodoxSlots: Int
    public let slotLimit: Int
    public let refreshInterval: TimeInterval
    public let nextRefresh: Date?

    public var remainingUnorthodoxSlots: Int {
        max(0, slotLimit - usedUnorthodoxSlots)
    }

    public init(
        plan: LoundryPlan,
        usedUnorthodoxSlots: Int,
        slotLimit: Int,
        refreshInterval: TimeInterval,
        nextRefresh: Date?
    ) {
        self.plan = plan
        self.usedUnorthodoxSlots = usedUnorthodoxSlots
        self.slotLimit = slotLimit
        self.refreshInterval = refreshInterval
        self.nextRefresh = nextRefresh
    }
}

public actor UsageLedger {
    public static let freeSlotLimit = 10
    public static let proSlotLimit = 20
    public static let refreshInterval: TimeInterval = 9 * 60 * 60

    private var plan: LoundryPlan
    private var used = 0
    private var refreshAt: Date?

    public init(plan: LoundryPlan = .free) {
        self.plan = plan
    }

    public func snapshot(now: Date = .now) -> UsageSnapshot {
        refreshIfNeeded(now: now)
        return UsageSnapshot(
            plan: plan,
            usedUnorthodoxSlots: used,
            slotLimit: limit,
            refreshInterval: Self.refreshInterval,
            nextRefresh: refreshAt
        )
    }

    @discardableResult
    public func consumeUnorthodoxSlot(now: Date = .now) -> Bool {
        refreshIfNeeded(now: now)
        guard used < limit else { return false }
        used += 1
        if refreshAt == nil {
            refreshAt = now.addingTimeInterval(Self.refreshInterval)
        }
        return true
    }

    public func setPlan(_ newPlan: LoundryPlan) {
        plan = newPlan
    }

    private var limit: Int {
        plan == .pro ? Self.proSlotLimit : Self.freeSlotLimit
    }

    private func refreshIfNeeded(now: Date) {
        guard let refreshAt, now >= refreshAt else { return }
        used = 0
        self.refreshAt = nil
    }
}
