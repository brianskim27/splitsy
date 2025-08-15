import SwiftUI

struct HomeView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @EnvironmentObject var funFactsManager: FunFactsManager
    @State private var showNewSplit = false
    @State private var showQuickSplit = false
    
    private var uniquePeopleThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        let currentMonthSplits = splitHistoryManager.pastSplits.filter { split in
            calendar.isDate(split.date, equalTo: now, toGranularity: .month)
        }
        let allPeople = currentMonthSplits.flatMap { Array($0.userShares.keys) }
        return Set(allPeople).count
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Hi, Brian!")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            showQuickSplit = true
                        }) {
                            HStack(spacing: 6) {
                                Text("Quick Split")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.top)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        Text(funFactsManager.currentFunFact.isEmpty ? "You've split with \(uniquePeopleThisMonth) people so far this month." : funFactsManager.currentFunFact)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 4)
                    
                    // Statistics Dashboard
                    StatisticsDashboard()
                        .padding(.bottom, 8)
                    
                    // Recent Splits Section
                    RecentSplitsSection()
                        .padding(.bottom, 100)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showNewSplit) {
                    NewSplitFlowView()
                }
            }
        }
        .sheet(isPresented: $showQuickSplit) {
            QuickSplitView()
        }
        .onAppear {
            funFactsManager.generateFunFact(from: splitHistoryManager.pastSplits)
        }
    }
}

// Recent Splits Section with Card Style
struct RecentSplitsSection: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Splits")
                .font(.title2)
                .bold()
            
            if splitHistoryManager.pastSplits.isEmpty {
                VStack {
                    Text("No recent splits yet.")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 32)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                let splits = Array(splitHistoryManager.pastSplits.prefix(3))
                VStack(spacing: 12) {
                    ForEach(Array(splits.enumerated()), id: \.element.id) { (index, split) in
                        RecentSplitRow(split: split)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// Statistics Dashboard
struct StatisticsDashboard: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var selectedDate = Date()
    @State private var showMonthPicker = false
    @State private var animateButton = false
    @State private var pressedMonth: Date?
    
    private var selectedMonthSplits: [Split] {
        let calendar = Calendar.current
        return splitHistoryManager.pastSplits.filter { split in
            calendar.isDate(split.date, equalTo: selectedDate, toGranularity: .month)
        }
    }
    
    private var availableMonths: [Date] {
        let calendar = Calendar.current
        let now = Date()
        
        // Get all unique months from past splits
        let splitMonths = Set(splitHistoryManager.pastSplits.map { split in
            calendar.dateInterval(of: .month, for: split.date)?.start ?? split.date
        })
        
        // Add current month if it has data
        let currentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        if splitMonths.contains(currentMonth) {
            // Return current month first, then other months
            return [currentMonth] + splitMonths.filter { !calendar.isDate($0, equalTo: currentMonth, toGranularity: .month) }.sorted(by: >)
        } else {
            // Return all months
            return splitMonths.sorted(by: >)
        }
    }
    
    private var totalMonthlySpending: Double {
        selectedMonthSplits.reduce(0) { $0 + $1.totalAmount }
    }
    
    private var averageSplitAmount: Double {
        guard !selectedMonthSplits.isEmpty else { return 0 }
        return totalMonthlySpending / Double(selectedMonthSplits.count)
    }
    
    private var uniquePeopleThisMonth: Int {
        let allPeople = selectedMonthSplits.flatMap { Array($0.userShares.keys) }
        return Set(allPeople).count
    }
    
    private var mostFrequentPartner: String? {
        let allPeople = selectedMonthSplits.flatMap { Array($0.userShares.keys) }
        let frequency = Dictionary(grouping: allPeople, by: { $0 })
            .mapValues { $0.count }
        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    private var moneySaved: Double {
        // Calculate how much saved by splitting vs paying full amounts
        selectedMonthSplits.reduce(0) { total, split in
            let yourShare = split.userShares["Brian"] ?? 0
            let fullAmount = split.totalAmount
            return total + (fullAmount - yourShare)
        }
    }
    
    private var monthYearString: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if selected date is current month
        if calendar.isDate(selectedDate, equalTo: now, toGranularity: .month) {
            return "This Month"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: {
                        showMonthPicker.toggle()
                        
                        // Trigger animation when dropdown is toggled
                        animateButton = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateButton = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(monthYearString)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(showMonthPicker ? 180 : 0))
                                .animation(.easeInOut(duration: 0.2), value: showMonthPicker)
                        }
                                         }
                     .buttonStyle(PlainButtonStyle())
                     .scaleEffect(animateButton ? 0.95 : 1.0)
                     .animation(.easeInOut(duration: 0.1), value: animateButton)
                     
                     Spacer()
                }
                
                // Main Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                                    StatCard(
                    title: "Total Spent",
                    value: String(format: "$%.2f", totalMonthlySpending),
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    statType: .totalSpent,
                    selectedDate: selectedDate
                )
                
                StatCard(
                    title: "Money Saved",
                    value: String(format: "$%.2f", moneySaved),
                    icon: "arrow.down.circle.fill",
                    color: .blue,
                    statType: .moneySaved,
                    selectedDate: selectedDate
                )
                
                StatCard(
                    title: "Splits",
                    value: "\(selectedMonthSplits.count)",
                    icon: "chart.pie.fill",
                    color: .orange,
                    statType: .splits,
                    selectedDate: selectedDate
                )
                
                StatCard(
                    title: "People",
                    value: "\(uniquePeopleThisMonth)",
                    icon: "person.2.fill",
                    color: .purple,
                    statType: .people,
                    selectedDate: selectedDate
                )
                }
                
                // Additional Insights
                VStack(alignment: .leading, spacing: 12) {
                    if !selectedMonthSplits.isEmpty {
                        InsightRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Average Split",
                            value: String(format: "$%.2f", averageSplitAmount)
                        )
                        
                        if let partner = mostFrequentPartner {
                            InsightRow(
                                icon: "person.fill",
                                title: "Most Frequent Partner",
                                value: partner
                            )
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            
            // Month Picker Dropdown
            if showMonthPicker {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(availableMonths.enumerated()), id: \.offset) { index, month in
                        MonthOptionButton(
                            month: month,
                            isSelected: Calendar.current.isDate(month, equalTo: selectedDate, toGranularity: .month),
                            isPressed: pressedMonth == month,
                            onTap: {
                                selectedDate = month
                                showMonthPicker = false
                            }
                        )
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { isPressing in
                            pressedMonth = isPressing ? month : nil
                        }, perform: {})
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .offset(x: 15, y: 45) // Position directly below the month text
                .frame(width: 135) // Allow natural width based on content
                .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .topLeading)))
                .zIndex(1) // Ensure it appears above the statistics
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showMonthPicker)
        .onTapGesture {
            if showMonthPicker {
                showMonthPicker = false
            }
        }
    }
}

// Individual Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let statType: DetailedStatsView.StatType
    let selectedDate: Date
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    
    var body: some View {
        NavigationLink(destination: DetailedStatsView(splitHistoryManager: splitHistoryManager, statType: statType, selectedMonth: selectedDate)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Insight Row
struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
    }
}

// Month Option Button
struct MonthOptionButton: View {
    let month: Date
    let isSelected: Bool
    let isPressed: Bool
    let onTap: () -> Void
    
    private var monthString: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if this month is current month
        if calendar.isDate(month, equalTo: now, toGranularity: .month) {
            return "This Month"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: month)
        }
    }
    
    var body: some View {
                                Button(action: onTap) {
                            HStack {
                                Text(monthString)
                                    .font(.subheadline)
                                    .fontWeight(isSelected ? .semibold : .regular)
                                    .foregroundColor(isSelected ? .white : .primary)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle())
                        }
                        .background(
                            Group {
                                if isSelected {
                                    Color.blue
                                } else if isPressed {
                                    Color(.systemGray5)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .buttonStyle(PlainButtonStyle())
    }
}

// Corner Radius Modifier
struct CornerRadiusModifier: ViewModifier {
    let isFirst: Bool
    let isLast: Bool
    
    func body(content: Content) -> some View {
        if isFirst && isLast {
            // Single item
            content.cornerRadius(8)
        } else if isFirst {
            // First item
            content.cornerRadius(8, corners: [.topLeft, .topRight])
        } else if isLast {
            // Last item
            content.cornerRadius(8, corners: [.bottomLeft, .bottomRight])
        } else {
            // Middle item
            content
        }
    }
}

// Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Store Model with Distance Calculation
struct Store: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    var isFavorited: Bool
}
