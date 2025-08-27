import Foundation

class FunFactsManager: ObservableObject {
    @Published var currentFunFact: String = ""
    private var lastFactIndex: Int = -1
    private let userDefaultsKey = "lastFunFactIndex"
    private let sessionKey = "currentSessionId"
    private var currentSessionId: String = ""
    
    private let funFacts: [FunFact] = [
        FunFact(
            id: "total_splits",
            template: "You've split {count} times! That's {count} shared experiences and memories.",
            requiresData: true
        ),
        FunFact(
            id: "money_saved",
            template: "By splitting bills, you've saved ${amount:.0f} compared to paying full amounts!",
            requiresData: true
        ),
        FunFact(
            id: "unique_people",
            template: "You've split with {count} different people. Your social network is growing!",
            requiresData: true
        ),
        FunFact(
            id: "favorite_partner",
            template: "Your most frequent split partner is {name}. You two split together {frequency} times!",
            requiresData: true
        ),
        FunFact(
            id: "average_split",
            template: "Your average split amount is ${amount:.0f}. That's a smart budget strategy!",
            requiresData: true
        ),
        FunFact(
            id: "biggest_split",
            template: "Your biggest split was ${amount:.0f}. That must have been quite the celebration!",
            requiresData: true
        ),
        FunFact(
            id: "split_streak",
            template: "You've been splitting consistently for {days} days. You're building great habits!",
            requiresData: true
        ),
        FunFact(
            id: "weekend_warrior",
            template: "You do {percentage}% of your splitting on weekends. Living for the weekend vibes!",
            requiresData: true
        ),
        FunFact(
            id: "morning_person",
            template: "You're an early bird - {percentage}% of your splits happen in the morning!",
            requiresData: true
        ),
        FunFact(
            id: "night_owl",
            template: "You're a night owl - {percentage}% of your splits happen in the evening!",
            requiresData: true
        ),
        FunFact(
            id: "generous_friend",
            template: "You often pay more than your fair share. You're a generous friend!",
            requiresData: true
        ),
        FunFact(
            id: "receipt_master",
            template: "You take photos of {percentage}% of your receipts. You're the organized one!",
            requiresData: true
        ),
        FunFact(
            id: "split_frequency",
            template: "You split about every {days} days on average. You're a regular social butterfly!",
            requiresData: true
        ),
        FunFact(
            id: "monthly_spending",
            template: "You spend about ${amount:.0f} per month on shared activities. That's a healthy social budget!",
            requiresData: true
        ),
        FunFact(
            id: "group_size_preference",
            template: "You prefer splitting in groups of {size} people on average. Perfect for {group_type}!",
            requiresData: true
        ),
        FunFact(
            id: "split_efficiency",
            template: "You save an average of ${amount:.0f} per split by sharing costs. Smart money management!",
            requiresData: true
        ),
        FunFact(
            id: "social_pattern",
            template: "You're most social on {day_of_week}s - that's when you do most of your splitting!",
            requiresData: true
        ),
        FunFact(
            id: "budget_insight",
            template: "Your split expenses are {percentage}% of your total spending. You're great at sharing costs!",
            requiresData: true
        ),
        FunFact(
            id: "relationship_builder",
            template: "You've built {count} strong relationships through bill splitting. That's friendship in action!",
            requiresData: true
        ),
        FunFact(
            id: "time_investment",
            template: "You've spent {hours} hours with friends through your split activities. Time well spent!",
            requiresData: true
        )
    ]
    
    init() {
        // Load the last fact index from UserDefaults
        lastFactIndex = UserDefaults.standard.integer(forKey: userDefaultsKey)
        
        // Generate a new session ID
        currentSessionId = UUID().uuidString
        UserDefaults.standard.set(currentSessionId, forKey: sessionKey)
        
        // Clear the current fun fact to force regeneration
        currentFunFact = ""
    }
    
    func generateFunFact(from splits: [Split]) {
        // Check if we already have a fun fact for this session
        if !currentFunFact.isEmpty {
            return
        }
        
        let availableFacts = funFacts.filter { fact in
            if fact.requiresData {
                return hasRequiredData(for: fact, in: splits)
            }
            return true
        }
        
        guard !availableFacts.isEmpty else {
            currentFunFact = "Welcome to Splitsy! Start splitting bills to unlock personalized fun facts!"
            return
        }
        
        // Cycle through facts, avoiding the last one shown
        var nextIndex = (lastFactIndex + 1) % availableFacts.count
        if availableFacts.count > 1 && nextIndex == lastFactIndex {
            nextIndex = (nextIndex + 1) % availableFacts.count
        }
        
        let selectedFact = availableFacts[nextIndex]
        lastFactIndex = nextIndex
        
        // Save the last fact index to UserDefaults
        UserDefaults.standard.set(lastFactIndex, forKey: userDefaultsKey)
        
        currentFunFact = formatFunFact(selectedFact, with: splits)
    }
    
    private func hasRequiredData(for fact: FunFact, in splits: [Split]) -> Bool {
        switch fact.id {
        case "total_splits":
            return !splits.isEmpty
        case "money_saved":
            return !splits.isEmpty
        case "unique_people":
            return !splits.isEmpty
        case "favorite_partner":
            return getMostFrequentPartner(from: splits) != nil
        case "average_split":
            return !splits.isEmpty
        case "biggest_split":
            return !splits.isEmpty
        case "split_streak":
            return getSplitStreak(from: splits) > 0
        case "weekend_warrior":
            return hasWeekendPattern(splits: splits)
        case "morning_person":
            return hasMorningPattern(splits: splits)
        case "night_owl":
            return hasEveningPattern(splits: splits)
        case "generous_friend":
            return isGenerousFriend(splits: splits)
        case "receipt_master":
            return hasReceiptPhotos(splits: splits)
        case "split_frequency":
            return splits.count >= 2
        case "monthly_spending":
            return !splits.isEmpty
        case "group_size_preference":
            return !splits.isEmpty
        case "split_efficiency":
            return !splits.isEmpty
        case "social_pattern":
            return !splits.isEmpty
        case "budget_insight":
            return !splits.isEmpty
        case "relationship_builder":
            return getUniquePeopleCount(from: splits) > 1
        case "time_investment":
            return !splits.isEmpty
        default:
            return true
        }
    }
    
    private func formatFunFact(_ fact: FunFact, with splits: [Split]) -> String {
        switch fact.id {
        case "total_splits":
            let count = splits.count
            let timeText = count == 1 ? "time" : "times"
            return fact.template
                .replacingOccurrences(of: "{count} times", with: "\(count) \(timeText)")
                .replacingOccurrences(of: "{count}", with: "\(count)")
        case "money_saved":
            let saved = calculateMoneySaved(from: splits)
            return fact.template.replacingOccurrences(of: "{amount:.0f}", with: String(format: "%.0f", saved))
        case "unique_people":
            let uniqueCount = getUniquePeopleCount(from: splits)
            let peopleText = uniqueCount == 1 ? "person" : "people"
            return fact.template
                .replacingOccurrences(of: "{count} people", with: "\(uniqueCount) \(peopleText)")
                .replacingOccurrences(of: "{count}", with: "\(uniqueCount)")
        case "favorite_partner":
            if let partner = getMostFrequentPartner(from: splits) {
                let frequency = getPartnerFrequency(partner: partner, from: splits)
                let timeText = frequency == 1 ? "time" : "times"
                return fact.template
                    .replacingOccurrences(of: "{name}", with: partner)
                    .replacingOccurrences(of: "{frequency} times", with: "\(frequency) \(timeText)")
            }
            return "You have great split partners!"
        case "average_split":
            let average = calculateAverageSplit(from: splits)
            return fact.template.replacingOccurrences(of: "{amount:.0f}", with: String(format: "%.0f", average))
        case "biggest_split":
            let biggest = getBiggestSplit(from: splits)
            return fact.template.replacingOccurrences(of: "{amount:.0f}", with: String(format: "%.0f", biggest))
        case "split_streak":
            let streak = getSplitStreak(from: splits)
            let dayText = streak == 1 ? "day" : "days"
            return fact.template.replacingOccurrences(of: "{days} days", with: "\(streak) \(dayText)")
        case "weekend_warrior":
            let percentage = getWeekendPercentage(from: splits)
            return fact.template.replacingOccurrences(of: "{percentage}", with: "\(percentage)")
        case "morning_person":
            let percentage = getMorningPercentage(from: splits)
            return fact.template.replacingOccurrences(of: "{percentage}", with: "\(percentage)")
        case "night_owl":
            let percentage = getEveningPercentage(from: splits)
            return fact.template.replacingOccurrences(of: "{percentage}", with: "\(percentage)")
        case "generous_friend":
            return fact.template
        case "receipt_master":
            let percentage = getReceiptPhotoPercentage(from: splits)
            return fact.template.replacingOccurrences(of: "{percentage}", with: "\(percentage)")
        case "split_frequency":
            let days = getAverageDaysBetweenSplits(from: splits)
            let dayText = days == 1 ? "day" : "days"
            return fact.template.replacingOccurrences(of: "{days} days", with: "\(days) \(dayText)")
        case "monthly_spending":
            let monthly = getAverageMonthlySpending(from: splits)
            return fact.template.replacingOccurrences(of: "{amount:.0f}", with: String(format: "%.0f", monthly))
        case "group_size_preference":
            let (size, type) = getGroupSizePreference(from: splits)
            return fact.template
                .replacingOccurrences(of: "{size}", with: "\(size)")
                .replacingOccurrences(of: "{group_type}", with: type)
        case "split_efficiency":
            let saved = getAverageSavingsPerSplit(from: splits)
            return fact.template.replacingOccurrences(of: "{amount:.0f}", with: String(format: "%.0f", saved))
        case "social_pattern":
            let day = getMostSocialDay(from: splits)
            return fact.template.replacingOccurrences(of: "{day_of_week}", with: day)
        case "budget_insight":
            let percentage = getSplitExpensePercentage(from: splits)
            return fact.template.replacingOccurrences(of: "{percentage}", with: "\(percentage)")
        case "relationship_builder":
            let count = getUniquePeopleCount(from: splits)
            let relationshipText = count == 1 ? "relationship" : "relationships"
            return fact.template
                .replacingOccurrences(of: "{count} relationships", with: "\(count) \(relationshipText)")
                .replacingOccurrences(of: "{count}", with: "\(count)")
        case "time_investment":
            let hours = estimateTimeSpent(from: splits)
            let hourText = hours == 1 ? "hour" : "hours"
            return fact.template.replacingOccurrences(of: "{hours} hours", with: "\(hours) \(hourText)")
        default:
            return fact.template
        }
    }
    
    // Helper methods for data analysis
    private func calculateMoneySaved(from splits: [Split]) -> Double {
        return splits.reduce(0) { total, split in
            let yourShare = split.userShares["Brian"] ?? 0
            let fullAmount = split.totalAmount
            return total + (fullAmount - yourShare)
        }
    }
    
    private func getUniquePeopleCount(from splits: [Split]) -> Int {
        let allPeople = splits.flatMap { Array($0.userShares.keys) }
        return Set(allPeople).count
    }
    
    private func getMostFrequentPartner(from splits: [Split]) -> String? {
        let allPeople = splits.flatMap { Array($0.userShares.keys) }
        let frequency = Dictionary(grouping: allPeople, by: { $0 })
            .mapValues { $0.count }
        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateAverageSplit(from splits: [Split]) -> Double {
        guard !splits.isEmpty else { return 0 }
        let total = splits.reduce(0) { $0 + $1.totalAmount }
        return total / Double(splits.count)
    }
    
    private func getBiggestSplit(from splits: [Split]) -> Double {
        return splits.map { $0.totalAmount }.max() ?? 0
    }
    
    private func getSplitStreak(from splits: [Split]) -> Int {
        guard !splits.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSplits = splits.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Date()
        
        for split in sortedSplits {
            if calendar.isDate(split.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func hasWeekendPattern(splits: [Split]) -> Bool {
        let calendar = Calendar.current
        let weekendSplits = splits.filter { split in
            let weekday = calendar.component(.weekday, from: split.date)
            return weekday == 1 || weekday == 7 // Sunday or Saturday
        }
        return Double(weekendSplits.count) / Double(splits.count) > 0.6
    }
    
    private func hasMorningPattern(splits: [Split]) -> Bool {
        let calendar = Calendar.current
        let morningSplits = splits.filter { split in
            let hour = calendar.component(.hour, from: split.date)
            return hour >= 6 && hour < 12
        }
        return Double(morningSplits.count) / Double(splits.count) > 0.5
    }
    
    private func hasEveningPattern(splits: [Split]) -> Bool {
        let calendar = Calendar.current
        let eveningSplits = splits.filter { split in
            let hour = calendar.component(.hour, from: split.date)
            return hour >= 18 && hour < 24
        }
        return Double(eveningSplits.count) / Double(splits.count) > 0.5
    }
    
    private func isGenerousFriend(splits: [Split]) -> Bool {
        let generousSplits = splits.filter { split in
            let yourShare = split.userShares["Brian"] ?? 0
            let fairShare = split.totalAmount / Double(split.userShares.count)
            return yourShare > fairShare * 1.1 // 10% more than fair share
        }
        return Double(generousSplits.count) / Double(splits.count) > 0.3
    }
    
    private func hasReceiptPhotos(splits: [Split]) -> Bool {
        let splitsWithPhotos = splits.filter { $0.receiptImageData != nil }
        return Double(splitsWithPhotos.count) / Double(splits.count) > 0.7
    }
    
    // New helper methods for data-driven fun facts
    private func getPartnerFrequency(partner: String, from splits: [Split]) -> Int {
        return splits.filter { $0.userShares.keys.contains(partner) }.count
    }
    
    private func getWeekendPercentage(from splits: [Split]) -> Int {
        let calendar = Calendar.current
        let weekendSplits = splits.filter { split in
            let weekday = calendar.component(.weekday, from: split.date)
            return weekday == 1 || weekday == 7 // Sunday or Saturday
        }
        return Int((Double(weekendSplits.count) / Double(splits.count)) * 100)
    }
    
    private func getMorningPercentage(from splits: [Split]) -> Int {
        let calendar = Calendar.current
        let morningSplits = splits.filter { split in
            let hour = calendar.component(.hour, from: split.date)
            return hour >= 6 && hour < 12
        }
        return Int((Double(morningSplits.count) / Double(splits.count)) * 100)
    }
    
    private func getEveningPercentage(from splits: [Split]) -> Int {
        let calendar = Calendar.current
        let eveningSplits = splits.filter { split in
            let hour = calendar.component(.hour, from: split.date)
            return hour >= 18 && hour < 24
        }
        return Int((Double(eveningSplits.count) / Double(splits.count)) * 100)
    }
    
    private func getReceiptPhotoPercentage(from splits: [Split]) -> Int {
        let splitsWithPhotos = splits.filter { $0.receiptImageData != nil }
        return Int((Double(splitsWithPhotos.count) / Double(splits.count)) * 100)
    }
    
    private func getAverageDaysBetweenSplits(from splits: [Split]) -> Int {
        guard splits.count >= 2 else { return 0 }
        
        let sortedSplits = splits.sorted { $0.date < $1.date }
        let firstDate = sortedSplits.first!.date
        let lastDate = sortedSplits.last!.date
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        
        return max(1, days / (splits.count - 1))
    }
    
    private func getAverageMonthlySpending(from splits: [Split]) -> Double {
        guard !splits.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        let currentMonthSplits = splits.filter { split in
            calendar.isDate(split.date, equalTo: now, toGranularity: .month)
        }
        
        if !currentMonthSplits.isEmpty {
            return currentMonthSplits.reduce(0) { $0 + $1.totalAmount }
        } else {
            // Calculate average monthly spending from all splits
            let totalSpending = splits.reduce(0) { $0 + $1.totalAmount }
            let months = max(1, calendar.dateComponents([.month], from: splits.first!.date, to: now).month ?? 1)
            return totalSpending / Double(months)
        }
    }
    
    private func getGroupSizePreference(from splits: [Split]) -> (Int, String) {
        let averageGroupSize = Int(splits.reduce(0.0) { $0 + Double($1.userShares.count) } / Double(splits.count))
        
        let groupType: String
        switch averageGroupSize {
        case 2:
            groupType = "intimate dinners"
        case 3...4:
            groupType = "small gatherings"
        case 5...6:
            groupType = "group outings"
        default:
            groupType = "big celebrations"
        }
        
        return (averageGroupSize, groupType)
    }
    
    private func getAverageSavingsPerSplit(from splits: [Split]) -> Double {
        guard !splits.isEmpty else { return 0 }
        
        let totalSavings = splits.reduce(0.0) { total, split in
            let yourShare = split.userShares["Brian"] ?? 0
            let fullAmount = split.totalAmount
            return total + (fullAmount - yourShare)
        }
        
        return totalSavings / Double(splits.count)
    }
    
    private func getMostSocialDay(from splits: [Split]) -> String {
        let calendar = Calendar.current
        var dayCounts = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0] // Sunday = 1, Saturday = 7
        
        for split in splits {
            let weekday = calendar.component(.weekday, from: split.date)
            dayCounts[weekday, default: 0] += 1
        }
        
        let mostSocialDay = dayCounts.max(by: { $0.value < $1.value })?.key ?? 1
        
        let dayNames = [1: "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday"]
        return dayNames[mostSocialDay] ?? "Sunday"
    }
    
    private func getSplitExpensePercentage(from splits: [Split]) -> Int {
        // Simplified calculation - in a real app you'd have total spending data
        // For now, we'll estimate based on split frequency and amounts
        let totalSplitAmount = splits.reduce(0) { $0 + $1.totalAmount }
        let estimatedTotalSpending = totalSplitAmount * 3 // Rough estimate
        return min(100, Int((Double(totalSplitAmount) / Double(estimatedTotalSpending)) * 100))
    }
    
    private func estimateTimeSpent(from splits: [Split]) -> Int {
        // Estimate 2 hours per split activity
        return splits.count * 2
    }
}

struct FunFact {
    let id: String
    let template: String
    let requiresData: Bool
}
