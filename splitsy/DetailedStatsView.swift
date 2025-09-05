import SwiftUI
import Charts

struct DetailedStatsView: View {
    let splitHistoryManager: SplitHistoryManager
    let statType: StatType
    let selectedMonth: Date
    @EnvironmentObject var currencyManager: CurrencyManager
    @State private var selectedPeriod: TimePeriod = .selectedMonth
    @State private var showPeriodDropdown = false
    @State private var selectedDataPoint: MonthData?
    @State private var animateButton = false
    @State private var pressedPeriod: TimePeriod?
    @State private var showDescription = false
    
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
            case .people: return "Unique People"
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
        
        var infographicOffset: (x: CGFloat, y: CGFloat) {
            switch self {
            case .totalSpent: return (x: -160, y: 105)
            case .moneySaved: return (x: -160, y: 115)
            case .splits: return (x: -158, y: 115)
            case .people: return (x: -155, y: 105)
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
            case .allTime: return 0
            }
        }
    }
    
    private var chartData: [MonthData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [MonthData] = []
        
        switch selectedPeriod {
        case .selectedMonth:
            let monthStart = calendar.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
            let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: monthStart)?.count ?? 4
            
            for week in 1...weeksInMonth {
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: monthStart)?.start ?? monthStart
                let adjustedWeekStart = calendar.date(byAdding: .weekOfYear, value: week - 1, to: weekStart) ?? weekStart
                
                // Only include weeks that have already started
                guard adjustedWeekStart <= now else { continue }
                
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: adjustedWeekStart) ?? adjustedWeekStart
                
                let weekSplits = splitHistoryManager.pastSplits.filter { split in
                    split.date >= adjustedWeekStart && split.date < weekEnd
                }
                
                let value: Double
                switch statType {
                case .totalSpent:
                    value = weekSplits.reduce(0) { total, split in
                        total + currencyManager.getConvertedAmount(split.totalAmount, from: split.originalCurrency)
                    }
                case .moneySaved:
                    value = weekSplits.reduce(0) { total, split in
                        let yourShare = split.userShares["Brian"] ?? 0
                        let fullAmount = split.totalAmount
                        
                        // Convert both amounts to current currency
                        let convertedFullAmount = currencyManager.getConvertedAmount(fullAmount, from: split.originalCurrency)
                        let convertedYourShare = currencyManager.getConvertedAmount(yourShare, from: split.originalCurrency)
                        
                        return total + (convertedFullAmount - convertedYourShare)
                    }
                case .splits:
                    value = Double(weekSplits.count)
                case .people:
                    let allPeople = weekSplits.flatMap { Array($0.userShares.keys) }
                    value = Double(Set(allPeople).count)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                let weekLabel = formatter.string(from: adjustedWeekStart)
                
                let weekEndDate = calendar.date(byAdding: .day, value: -1, to: weekEnd) ?? weekEnd
                let weekEndString = formatter.string(from: weekEndDate)
                let fullWeekRange = "\(weekLabel) - \(weekEndString)"
                
                data.append(MonthData(month: weekLabel, value: value, fullWeekRange: fullWeekRange))
            }
            
        case .allTime:
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
                    value = monthSplits.reduce(0) { total, split in
                        total + currencyManager.getConvertedAmount(split.totalAmount, from: split.originalCurrency)
                    }
                case .moneySaved:
                    value = monthSplits.reduce(0) { total, split in
                        let yourShare = split.userShares["Brian"] ?? 0
                        let fullAmount = split.totalAmount
                        
                        // Convert both amounts to current currency
                        let convertedFullAmount = currencyManager.getConvertedAmount(fullAmount, from: split.originalCurrency)
                        let convertedYourShare = currencyManager.getConvertedAmount(yourShare, from: split.originalCurrency)
                        
                        return total + (convertedFullAmount - convertedYourShare)
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
                
                data.append(MonthData(month: monthName, value: value, fullWeekRange: monthName))
                
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            }
            
        default:
            for i in 0..<selectedPeriod.months {
                if let monthDate = calendar.date(byAdding: .month, value: -i, to: now) {
                    let monthSplits = splitHistoryManager.pastSplits.filter { split in
                        calendar.isDate(split.date, equalTo: monthDate, toGranularity: .month)
                    }
                    
                    let value: Double
                    switch statType {
                    case .totalSpent:
                        value = monthSplits.reduce(0) { total, split in
                            total + currencyManager.getConvertedAmount(split.totalAmount, from: split.originalCurrency)
                        }
                    case .moneySaved:
                        value = monthSplits.reduce(0) { total, split in
                            let yourShare = split.userShares["Brian"] ?? 0
                            let fullAmount = split.totalAmount
                            
                            // Convert both amounts to current currency
                            let convertedFullAmount = currencyManager.getConvertedAmount(fullAmount, from: split.originalCurrency)
                            let convertedYourShare = currencyManager.getConvertedAmount(yourShare, from: split.originalCurrency)
                            
                            return total + (convertedFullAmount - convertedYourShare)
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
                    
                    data.append(MonthData(month: monthName, value: value, fullWeekRange: monthName))
                }
            }
            data = data.reversed()
        }
        
        return data
    }
    
    private var periodButtonTitle: String {
        if selectedPeriod == .selectedMonth {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            return formatter.string(from: selectedMonth)
        } else {
            return selectedPeriod.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 20) {
                    
                    // Period Selector
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 20) {
                            // Period Selector Button
                            HStack {
                                Button(action: {
                                    showPeriodDropdown.toggle()
                                    
                                    // Trigger animation when dropdown is toggled
                                    animateButton = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        animateButton = false
                                    }
                                }) {
                                    HStack {
                                        Text(periodButtonTitle)
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
                                 .scaleEffect(animateButton ? 0.95 : 1.0)
                                 .animation(.easeInOut(duration: 0.1), value: animateButton)
                                 
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
                                                    DragGesture(minimumDistance: 1)
                                                        .onChanged { value in
                                                            let location = value.location
                                                            if let dataPoint = findDataPoint(at: location, proxy: proxy) {
                                                                selectedDataPoint = dataPoint
                                                            }
                                                        }
                                                        .onEnded { _ in
                                                            // Clear the selected data point when drag ends
                                                            selectedDataPoint = nil
                                                        }
                                                )
                                                .onTapGesture { location in
                                                    // Handle tap to toggle data point visibility
                                                    if let tappedDataPoint = findDataPoint(at: location, proxy: proxy) {
                                                        if selectedDataPoint?.month == tappedDataPoint.month {
                                                            selectedDataPoint = nil
                                                        } else {
                                                            selectedDataPoint = tappedDataPoint
                                                        }
                                                    } else {
                                                        selectedDataPoint = nil
                                                    }
                                                }
                                            
                                            // Tooltip for selected data point
                                            if let selectedDataPoint = selectedDataPoint,
                                               let xPosition = proxy.position(forX: selectedDataPoint.month),
                                               let yPosition = proxy.position(forY: selectedDataPoint.value) {
                                                VStack(spacing: 4) {
                                                    Text(selectedDataPoint.fullWeekRange)
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
                                // Use selected data point if available, otherwise use most recent data point
                                let currentValue = selectedDataPoint?.value ?? (chartData.last?.value ?? 0)
                                let currentIndex = selectedDataPoint != nil ? 
                                    (chartData.firstIndex(where: { $0.month == selectedDataPoint?.month }) ?? chartData.count - 1) :
                                    chartData.count - 1
                                let previousValue = currentIndex > 0 ? chartData[currentIndex - 1].value : 0
                                let change = currentValue - previousValue
                                let changePercent = previousValue > 0 ? (change / previousValue) * 100 : 0
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(selectedDataPoint != nil ? "Selected" : "Current")
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
                            
                            // Average Stats
                            VStack(spacing: 12) {
                                let averageValue = chartData.isEmpty ? 0 : chartData.reduce(0) { $0 + $1.value } / Double(chartData.count)
                                let totalValue = chartData.reduce(0) { $0 + $1.value }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Average")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatValue(averageValue))
                                            .font(.title2)
                                            .bold()
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Total")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatValue(totalValue))
                                            .font(.subheadline)
                                            .bold()
                                    }
                                }
                                
                                HStack {
                                    Text("across selected period")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(chartData.count) \(selectedPeriod == .selectedMonth ? "weeks" : "months")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
                                    pressedPeriod = nil
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .background(
                                    Group {
                                        if selectedPeriod == period {
                                            statType.color
                                        } else if pressedPeriod == period {
                                            Color(.systemGray5)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                                .buttonStyle(PlainButtonStyle())
                                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { isPressing in
                                    pressedPeriod = isPressing ? period : nil
                                }, perform: {})
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .offset(x: 16, y: 40)
                            .frame(width: 156)
                            .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .topLeading)))
                            .zIndex(1)
                        }
                    }
                }
                .padding(.top)
                
                .navigationTitle("\(statType.title) Trends")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        GeometryReader { geometry in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showDescription.toggle()
                                }
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .background(
                                        Circle()
                                            .fill(showDescription ? Color.blue.opacity(0.1) : Color.clear)
                                            .frame(width: 20, height: 20)
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: showDescription)
                            }
                            .offset(x: -12, y: 0)
                            .background(
                                // Info popup - quotation box style
                                Group {
                                    if showDescription {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("About \(statType.title)")
                                                .font(.subheadline)
                                                .bold()
                                            
                                            Text(getStatDescription())
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.top, 21)
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 12)
                                        .background(
                                            SpeechBubble()
                                                .fill(Color(.systemBackground))
                                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        )
                                        .frame(width: 345)
                                        .offset(x: statType.infographicOffset.x, y: statType.infographicOffset.y)
                                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                                        .zIndex(1000)
                                    }
                                }
                            )
                        }
                        .frame(width: 20, height: 20)
                    }
                }
                .onTapGesture {
                    if showPeriodDropdown {
                        showPeriodDropdown = false
                    }
                    if showDescription {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showDescription = false
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showPeriodDropdown)
            .animation(.easeInOut(duration: 0.3), value: showDescription)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        switch statType {
        case .totalSpent, .moneySaved:
            return currencyManager.formatAmount(value)
        case .splits, .people:
            return String(format: "%.0f", value)
        }
    }
    
    private func getStatDescription() -> String {
        switch statType {
        case .totalSpent:
            return "Total Spent tracks the complete cost of all your splits over time. This represents the full amount of each bill or expense before it was divided among participants. Use this metric to understand your overall spending patterns and identify peak spending periods."
            
        case .moneySaved:
            return "Money Saved shows how much you've saved by splitting expenses instead of paying the full amount yourself. This is calculated as the difference between the total cost and your personal share across all splits. It demonstrates the financial benefit of sharing costs with others."
            
        case .splits:
            return "Splits tracks the number of individual expense-sharing transactions you've completed. Each time you split a bill, meal, or other expense with friends or colleagues, it counts as one split. This metric helps you understand your sharing frequency and social spending habits."
            
        case .people:
            return "Unique People shows the number of unique individuals you've shared expenses with during each time period. This metric reflects the diversity of your social spending network and can help you understand how your circle of shared experiences grows over time."
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
    let fullWeekRange: String
}

// Speech bubble shape with upward-pointing tail
struct SpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 12
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = 15
        
        // Position tail at top-right area (accounting for rounded corners)
        let tailCenterX = rect.maxX - (cornerRadius + tailWidth/2) + 2 // Keep tail within rounded corner bounds
        
        // Start from top-left corner (main rectangle starts below tail area)
        path.move(to: CGPoint(x: cornerRadius, y: tailHeight))
        
        // Top edge with integrated tail
        path.addLine(to: CGPoint(x: tailCenterX - tailWidth/2, y: tailHeight)) // Left side of tail base
        path.addLine(to: CGPoint(x: tailCenterX, y: 0)) // Tail tip
        path.addLine(to: CGPoint(x: tailCenterX + tailWidth/2, y: tailHeight)) // Right side of tail base
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: tailHeight)) // Continue to right edge
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: tailHeight + cornerRadius), control: CGPoint(x: rect.maxX, y: tailHeight))
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - cornerRadius), control: CGPoint(x: 0, y: rect.maxY))
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: tailHeight + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: tailHeight), control: CGPoint(x: 0, y: tailHeight))
        
        return path
    }
}
