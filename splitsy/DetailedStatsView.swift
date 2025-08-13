import SwiftUI
import Charts

struct DetailedStatsView: View {
    let splitHistoryManager: SplitHistoryManager
    let statType: StatType
    @State private var selectedPeriod: TimePeriod = .selectedMonth
    @State private var showPeriodDropdown = false
    @State private var selectedDataPoint: MonthData?
    
    enum StatType {
        case totalSpent
        case moneySaved
        case splits
        case people
        
        var title: String {
            switch self {
            case .totalSpent: return "Total Spent"
            case .moneySaved: return "Money Saved"
            case .splits: return "Splits"
            case .people: return "People"
            }
        }
        
        var icon: String {
            switch self {
            case .totalSpent: return "dollarsign.circle.fill"
            case .moneySaved: return "arrow.down.circle.fill"
            case .splits: return "chart.pie.fill"
            case .people: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .totalSpent: return .green
            case .moneySaved: return .blue
            case .splits: return .orange
            case .people: return .purple
            }
        }
    }
    
    enum TimePeriod: String, CaseIterable {
        case selectedMonth = "Selected Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case oneYear = "One Year"
        case ytd = "YTD"
        case allTime = "All Time"
        
        var months: Int {
            switch self {
            case .selectedMonth: return 1
            case .threeMonths: return 3
            case .sixMonths: return 6
            case .oneYear: return 12
            case .ytd: return Calendar.current.component(.month, from: Date())
            case .allTime: return 0 // Special case for all time
            }
        }
    }
    
    private var chartData: [MonthData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [MonthData] = []
        
        switch selectedPeriod {
        case .selectedMonth:
            // For selected month, show weeks
            let selectedMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: selectedMonth)?.count ?? 4
            
            for week in 1...weeksInMonth {
                let weekStart = calendar.date(byAdding: .weekOfYear, value: week - 1, to: selectedMonth) ?? selectedMonth
                let weekEnd = calendar.date(byAdding: .weekOfYear, value: week, to: selectedMonth) ?? selectedMonth
                
                let weekSplits = splitHistoryManager.pastSplits.filter { split in
                    split.date >= weekStart && split.date < weekEnd
                }
                
                let value: Double
                switch statType {
                case .totalSpent:
                    value = weekSplits.reduce(0) { $0 + $1.totalAmount }
                case .moneySaved:
                    value = weekSplits.reduce(0) { total, split in
                        let yourShare = split.userShares["Brian"] ?? 0
                        let fullAmount = split.totalAmount
                        return total + (fullAmount - yourShare)
                    }
                case .splits:
                    value = Double(weekSplits.count)
                case .people:
                    let allPeople = weekSplits.flatMap { Array($0.userShares.keys) }
                    value = Double(Set(allPeople).count)
                }
                
                data.append(MonthData(month: "Week \(week)", value: value))
            }
            
        case .allTime:
            // For all time, get all months from first split to current month
            guard let firstSplit = splitHistoryManager.pastSplits.last else { return [] }
            let firstMonth = calendar.dateInterval(of: .month, for: firstSplit.date)?.start ?? firstSplit.date
            let currentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            
            var currentDate = firstMonth
            while currentDate <= currentMonth {
                let monthSplits = splitHistoryManager.pastSplits.filter { split in
                    calendar.isDate(split.date, equalTo: currentDate, toGranularity: .month)
                }
                
                let value: Double
                switch statType {
                case .totalSpent:
                    value = monthSplits.reduce(0) { $0 + $1.totalAmount }
                case .moneySaved:
                    value = monthSplits.reduce(0) { total, split in
                        let yourShare = split.userShares["Brian"] ?? 0
                        let fullAmount = split.totalAmount
                        return total + (fullAmount - yourShare)
                    }
                case .splits:
                    value = Double(monthSplits.count)
                case .people:
                    let allPeople = monthSplits.flatMap { Array($0.userShares.keys) }
                    value = Double(Set(allPeople).count)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                let monthName = formatter.string(from: currentDate)
                
                data.append(MonthData(month: monthName, value: value))
                
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            }
            
        default:
            // For other periods, show months
            for i in 0..<selectedPeriod.months {
                if let monthDate = calendar.date(byAdding: .month, value: -i, to: now) {
                    let monthSplits = splitHistoryManager.pastSplits.filter { split in
                        calendar.isDate(split.date, equalTo: monthDate, toGranularity: .month)
                    }
                    
                    let value: Double
                    switch statType {
                    case .totalSpent:
                        value = monthSplits.reduce(0) { $0 + $1.totalAmount }
                    case .moneySaved:
                        value = monthSplits.reduce(0) { total, split in
                            let yourShare = split.userShares["Brian"] ?? 0
                            let fullAmount = split.totalAmount
                            return total + (fullAmount - yourShare)
                        }
                    case .splits:
                        value = Double(monthSplits.count)
                    case .people:
                        let allPeople = monthSplits.flatMap { Array($0.userShares.keys) }
                        value = Double(Set(allPeople).count)
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM"
                    let monthName = formatter.string(from: monthDate)
                    
                    data.append(MonthData(month: monthName, value: value))
                }
            }
            data = data.reversed()
        }
        
        return data
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 20) {
                    
                    // Period Selector with Overlay Dropdown
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 20) {
                            // Period Selector Button
                            HStack {
                                Button(action: {
                                    showPeriodDropdown.toggle()
                                }) {
                                    HStack {
                                        Text(selectedPeriod.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .rotationEffect(.degrees(showPeriodDropdown ? 180 : 0))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Chart
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: statType.icon)
                                        .font(.title2)
                                        .foregroundColor(statType.color)
                                    Text(statType.title)
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                }
                                
                                if chartData.isEmpty {
                                    VStack {
                                        Text("No data available")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.vertical, 40)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                } else {
                                    Chart(chartData) { data in
                                        LineMark(
                                            x: .value("Month", data.month),
                                            y: .value("Value", data.value)
                                        )
                                        .foregroundStyle(statType.color)
                                        .lineStyle(StrokeStyle(lineWidth: 3))
                                        
                                        AreaMark(
                                            x: .value("Month", data.month),
                                            y: .value("Value", data.value)
                                        )
                                        .foregroundStyle(statType.color.opacity(0.1))
                                        
                                        PointMark(
                                            x: .value("Month", data.month),
                                            y: .value("Value", data.value)
                                        )
                                        .foregroundStyle(statType.color)
                                    }
                                    .frame(height: 200)
                                    .chartYAxis {
                                        AxisMarks(position: .leading)
                                    }
                                    .chartXAxis {
                                        AxisMarks { value in
                                            if let monthString = value.as(String.self) {
                                                AxisValueLabel {
                                                    Text(monthString)
                                                        .foregroundColor(selectedPeriod == .selectedMonth ? .primary : .secondary)
                                                }
                                            } else {
                                                AxisValueLabel()
                                            }
                                        }
                                    }
                                    .chartOverlay { proxy in
                                        ZStack {
                                            Rectangle()
                                                .fill(.clear)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            let location = value.location
                                                            if let dataPoint = findDataPoint(at: location, proxy: proxy) {
                                                                selectedDataPoint = dataPoint
                                                            }
                                                        }
                                                        .onEnded { _ in
                                                            // Keep the selected data point visible
                                                        }
                                                )
                                            
                                            // Tooltip for selected data point
                                            if let selectedDataPoint = selectedDataPoint,
                                               let xPosition = proxy.position(forX: selectedDataPoint.month),
                                               let yPosition = proxy.position(forY: selectedDataPoint.value) {
                                                VStack(spacing: 4) {
                                                    Text(selectedDataPoint.month)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Text(formatValue(selectedDataPoint.value))
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(statType.color)
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(.systemBackground))
                                                .cornerRadius(6)
                                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                                .position(x: xPosition, y: yPosition - 30)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                            
                            // Summary Stats
                            VStack(spacing: 12) {
                                let currentValue = chartData.last?.value ?? 0
                                let previousValue = chartData.count > 1 ? chartData[chartData.count - 2].value : 0
                                let change = currentValue - previousValue
                                let changePercent = previousValue > 0 ? (change / previousValue) * 100 : 0
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Current")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatValue(currentValue))
                                            .font(.title2)
                                            .bold()
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Change")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        HStack(spacing: 4) {
                                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                                .font(.caption)
                                            Text(formatValue(abs(change)))
                                                .font(.subheadline)
                                                .bold()
                                        }
                                        .foregroundColor(change >= 0 ? .green : .red)
                                    }
                                }
                                
                                if previousValue > 0 {
                                    HStack {
                                        Text("vs previous period")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(changePercent >= 0 ? "+" : "")\(changePercent, specifier: "%.1f")%")
                                            .font(.caption)
                                            .foregroundColor(changePercent >= 0 ? .green : .red)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        
                        // Period Dropdown - Positioned to hover over content
                        if showPeriodDropdown {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    Button(action: {
                                        selectedPeriod = period
                                        showPeriodDropdown = false
                                    }) {
                                        HStack {
                                            Text(period.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(selectedPeriod == period ? .white : .primary)
                                            Spacer()
                                            if selectedPeriod == period {
                                                Image(systemName: "checkmark")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedPeriod == period ? statType.color : Color.clear)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .offset(x: 16, y: 40) // Position directly below the period selector button
                            .frame(width: 156) // Allow natural width based on content
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .zIndex(1) // Ensure it appears above other elements
                        }
                    }
                }
                .padding(.top)
                .navigationTitle("\(statType.title) Trends")
                .navigationBarTitleDisplayMode(.large)
                .onTapGesture {
                    if showPeriodDropdown {
                        showPeriodDropdown = false
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showPeriodDropdown)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        switch statType {
        case .totalSpent, .moneySaved:
            return String(format: "$%.2f", value)
        case .splits, .people:
            return String(format: "%.0f", value)
        }
    }
    
    private func findDataPoint(at location: CGPoint, proxy: ChartProxy) -> MonthData? {
        // Find the closest data point by comparing x positions
        let closestDataPoint = chartData.min { data1, data2 in
            let position1 = proxy.position(forX: data1.month) ?? 0
            let position2 = proxy.position(forX: data2.month) ?? 0
            return abs(position1 - location.x) < abs(position2 - location.x)
        }
        
        return closestDataPoint
    }
}

struct MonthData: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}
