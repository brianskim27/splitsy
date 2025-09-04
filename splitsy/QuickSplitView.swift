import SwiftUI
import LinkPresentation

// MARK: - Quick Split Main View
struct QuickSplitView: View {
    @Environment(\.dismiss) var dismiss
    @State private var peopleCount = 2
    @State private var items: [SplitItem] = []
    @State private var showAddItem = false
    @State private var newItemName = ""
    @State private var newItemPrice = ""
    @State private var taxEnabled = false
    @State private var taxAmount = ""
    @State private var taxSplitEqually = true
    @State private var taxAssignments: Set<Int> = []
    @State private var showReview = false
    @State private var itemAssignments: [UUID: Set<Int>] = [:] // ItemID -> Set of person indices
    @FocusState private var isTaxFieldFocused: Bool
    
    enum NavigationState {
        case calculator
        case review
    }
    @State private var currentView: NavigationState = .calculator
    
    private var people: [String] {
        (1...peopleCount).map { "Person \($0)" }
    }
    
    private var assignedItemsPerPerson: [Int: [SplitItem]] {
        var assignments: [Int: [SplitItem]] = [:]
        
        // Initialize all people with empty arrays
        for i in 0..<peopleCount {
            assignments[i] = []
        }
        
        // Add assigned items
        for item in items {
            let assignedPeople = itemAssignments[item.id] ?? []
            for personIndex in assignedPeople {
                assignments[personIndex]?.append(item)
            }
        }
        
        return assignments
    }
    
    private var subtotal: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    private var tax: Double {
        guard taxEnabled, let amount = Double(taxAmount) else { return 0 }
        return amount
    }
    
    private var total: Double {
        subtotal + tax
    }
    
    private var isValid: Bool {
        !items.isEmpty && peopleCount >= 2
    }
    
    var body: some View {
        NavigationView {
            Group {
                if currentView == .calculator {
                    calculatorViewContent
                } else {
                    reviewViewContent
                }
            }
        }
    }
    
    private var calculatorViewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Number of People
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number of People")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Stepper(value: $peopleCount, in: 2...20) {
                        Text("\(peopleCount) people")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Show people list with assigned items
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(people.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(people[index])
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                if let assignedItems = assignedItemsPerPerson[index], !assignedItems.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(assignedItems, id: \.id) { item in
                                            HStack {
                                                Text(item.name)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text("$\(item.price, specifier: "%.2f")")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                } else {
                                    Text("No items assigned")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.top, 8)
                }
                
                // Items Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Items")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Add Item") {
                            showAddItem = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    if items.isEmpty {
                        Text("No items added yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    } else {
                        ForEach(items) { item in
                            QuickSplitItemRow(
                                item: item,
                                people: people,
                                assignments: Binding(
                                    get: { itemAssignments[item.id] ?? [] },
                                    set: { itemAssignments[item.id] = $0 }
                                ),
                                onDelete: { deleteItem(item) }
                            )
                        }
                    }
                }
                
                // Tax Section
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Add Tax", isOn: $taxEnabled)
                        .font(.headline)
                    
                    if taxEnabled {
                        VStack(alignment: .leading, spacing: 16) {
                            // Tax amount input
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                TextField("0.00", text: $taxAmount)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .focused($isTaxFieldFocused)
                                
                                if isTaxFieldFocused {
                                    Button("Done") {
                                        isTaxFieldFocused = false
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Tax splitting option
                            HStack {
                                Button(action: {
                                    taxSplitEqually.toggle()
                                    if taxSplitEqually {
                                        taxAssignments.removeAll()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: taxSplitEqually ? "checkmark.square.fill" : "square")
                                            .foregroundColor(taxSplitEqually ? .blue : .gray)
                                        Text("Split tax equally among everyone")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            
                            // Tax assignment (if not splitting equally)
                            if !taxSplitEqually {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Assign tax to:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 8) {
                                        ForEach(people.indices, id: \.self) { index in
                                            Button(action: {
                                                if taxAssignments.contains(index) {
                                                    taxAssignments.remove(index)
                                                } else {
                                                    taxAssignments.insert(index)
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: taxAssignments.contains(index) ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(taxAssignments.contains(index) ? .blue : .gray)
                                                    
                                                    Text(people[index])
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                    
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 6)
                                                .background(
                                                    taxAssignments.contains(index) 
                                                    ? Color.blue.opacity(0.1) 
                                                    : Color(.systemGray6)
                                                )
                                                .cornerRadius(6)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Total Summary
                if !items.isEmpty {
                    VStack(spacing: 12) {
                        Divider()
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(subtotal, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            
                            if taxEnabled && tax > 0 {
                                HStack {
                                    Text("Tax:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(tax, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total:")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("$\(total, specifier: "%.2f")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Quick Split")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create Split") {
                    currentView = .review
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.6)
            }
        }
        .alert("Add Item", isPresented: $showAddItem) {
            TextField("Item name", text: $newItemName)
            TextField("Price", text: $newItemPrice)
                .keyboardType(.decimalPad)
            Button("Add") {
                addItem()
            }
            Button("Cancel", role: .cancel) {
                clearNewItem()
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
    
    private var reviewViewContent: some View {
        QuickSplitReviewView(
            people: people,
            items: items,
            itemAssignments: itemAssignments,
            tax: tax,
            taxSplitEqually: taxSplitEqually,
            taxAssignments: taxAssignments,
            total: total,
            onBack: { currentView = .calculator },
            onDone: { dismiss() }
        )
    }
    
    private func addItem() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let price = Double(newItemPrice), price > 0 else {
            clearNewItem()
            return
        }
        
        let item = SplitItem(
            id: UUID(),
            name: newItemName.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price
        )
        
        items.append(item)
        clearNewItem()
    }
    
    private func clearNewItem() {
        newItemName = ""
        newItemPrice = ""
    }
    
    private func deleteItem(_ item: SplitItem) {
        items.removeAll { $0.id == item.id }
        itemAssignments.removeValue(forKey: item.id)
    }
}

// MARK: - Supporting Models and Views
struct SplitItem: Identifiable {
    let id: UUID
    let name: String
    let price: Double
}

struct QuickSplitItemRow: View {
    let item: SplitItem
    let people: [String]
    @Binding var assignments: Set<Int>
    let onDelete: () -> Void
    @State private var showAssignments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Assign") {
                        showAssignments.toggle()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            if showAssignments {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assign to:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(people.indices, id: \.self) { index in
                            Button(action: {
                                if assignments.contains(index) {
                                    assignments.remove(index)
                                } else {
                                    assignments.insert(index)
                                }
                            }) {
                                HStack {
                                    Image(systemName: assignments.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(assignments.contains(index) ? .blue : .gray)
                                    
                                    Text(people[index])
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    assignments.contains(index) 
                                    ? Color.blue.opacity(0.1) 
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Show assigned people
            if !assignments.isEmpty {
                HStack {
                    Text("Assigned to:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(assignments.sorted().map { people[$0] }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Quick Split Review View
struct QuickSplitReviewView: View {
    let people: [String]
    let items: [SplitItem]
    let itemAssignments: [UUID: Set<Int>]
    let tax: Double
    let taxSplitEqually: Bool
    let taxAssignments: Set<Int>
    let total: Double
    let onBack: () -> Void
    let onDone: () -> Void
    @State private var isPreparingShare = false
    
    private var userShares: [String: Double] {
        var shares: [String: Double] = [:]
        
        // Initialize all people with 0
        for person in people {
            shares[person] = 0
        }
        
        // Calculate item shares
        for item in items {
            let assignedPeople = itemAssignments[item.id] ?? []
            
            if assignedPeople.isEmpty {
                // Split equally among all people
                let sharePerPerson = item.price / Double(people.count)
                for person in people {
                    shares[person]! += sharePerPerson
                }
            } else {
                // Split among assigned people
                let sharePerPerson = item.price / Double(assignedPeople.count)
                for personIndex in assignedPeople {
                    let person = people[personIndex]
                    shares[person]! += sharePerPerson
                }
            }
        }
        
        // Add tax
        if tax > 0 {
            if taxSplitEqually {
                // Split equally among all people
                let taxPerPerson = tax / Double(people.count)
                for person in people {
                    shares[person]! += taxPerPerson
                }
            } else if !taxAssignments.isEmpty {
                // Split among assigned people
                let taxPerPerson = tax / Double(taxAssignments.count)
                for personIndex in taxAssignments {
                    let person = people[personIndex]
                    shares[person]! += taxPerPerson
                }
            }
        }
        
        return shares
    }
    
    private var detailedBreakdown: [String: [ItemDetail]] {
        var breakdown: [String: [ItemDetail]] = [:]
        
        // Initialize all people with empty arrays
        for person in people {
            breakdown[person] = []
        }
        
        // Add items to breakdown
        for item in items {
            let assignedPeople = itemAssignments[item.id] ?? []
            
            if assignedPeople.isEmpty {
                // Split equally among all people
                let sharePerPerson = item.price / Double(people.count)
                for person in people {
                    breakdown[person]!.append(ItemDetail(item: item.name, cost: sharePerPerson))
                }
            } else {
                // Split among assigned people
                let sharePerPerson = item.price / Double(assignedPeople.count)
                for personIndex in assignedPeople {
                    let person = people[personIndex]
                    breakdown[person]!.append(ItemDetail(item: item.name, cost: sharePerPerson))
                }
            }
        }
        
        // Add tax to breakdown
        if tax > 0 {
            if taxSplitEqually {
                // Split equally among all people
                let taxPerPerson = tax / Double(people.count)
                for person in people {
                    breakdown[person]!.append(ItemDetail(item: "Tax", cost: taxPerPerson))
                }
            } else if !taxAssignments.isEmpty {
                // Split among assigned people
                let taxPerPerson = tax / Double(taxAssignments.count)
                for personIndex in taxAssignments {
                    let person = people[personIndex]
                    breakdown[person]!.append(ItemDetail(item: "Tax", cost: taxPerPerson))
                }
            }
        }
        
        return breakdown
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header Info
                VStack(spacing: 8) {
                    Text("Quick Split")
                        .font(.title2)
                        .bold()
                    Text(Date(), style: .date)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text("Total: $\(total, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)

                // User Breakdowns
                ForEach(people, id: \.self) { person in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(person)
                                .font(.headline)
                                .bold()
                            Spacer()
                            Text("$\(userShares[person] ?? 0, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        if let personItems = detailedBreakdown[person] {
                            ForEach(personItems, id: \.self) { itemDetail in
                                HStack {
                                    Text(itemDetail.item)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(itemDetail.cost, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding(.leading)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    onBack()
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await prepareAndPresentShareSheet()
                    }
                } label: {
                    if isPreparingShare {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isPreparingShare)
                
                Button("Done") { onDone() }
            }
        }
    }
    
    @MainActor
    private func prepareAndPresentShareSheet() async {
        isPreparingShare = true
        
        guard let splitImage = renderSplitAsImage() else {
            isPreparingShare = false
            return
        }
        
        // Get the current view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            isPreparingShare = false
            return
        }
        
        // Find the topmost view controller
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // Create custom share sheet with large image preview
        let customShareController = CustomShareViewController(image: splitImage)
        
        isPreparingShare = false
        topController.present(customShareController, animated: true)
    }
    
    @MainActor
    private func renderSplitAsImage() -> UIImage? {
        let exportView = QuickSplitExportView(
            people: people,
            userShares: userShares,
            detailedBreakdown: detailedBreakdown,
            total: total
        )
        .padding(16)
        .frame(width: 900, alignment: .center)
        .background(Color(.systemBackground))
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: exportView)
            renderer.proposedSize = .init(width: 900, height: nil)
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = true
            return renderer.uiImage
        } else {
            let controller = UIHostingController(rootView: exportView)
            let targetSize = CGSize(width: 900, height: UIView.layoutFittingCompressedSize.height)
            controller.view.bounds = CGRect(origin: .zero, size: targetSize)
            controller.view.backgroundColor = .systemBackground
            let size = controller.sizeThatFits(in: CGSize(width: targetSize.width, height: CGFloat.greatestFiniteMagnitude))
            controller.view.bounds.size = size

            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { _ in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
    }
}

// MARK: - Quick Split Export View
struct QuickSplitExportView: View {
    let people: [String]
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 6) {
                Text("Quick Split")
                    .font(.title2)
                    .bold()
                Text(Date(), style: .date)
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text("Total: $\(total, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            VStack(spacing: 16) {
                ForEach(people, id: \.self) { person in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(person)
                                .font(.headline)
                                .bold()
                            Spacer()
                            Text("$\(userShares[person] ?? 0, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        if let items = detailedBreakdown[person] {
                            VStack(spacing: 8) {
                                ForEach(items, id: \.self) { itemDetail in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(itemDetail.item)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Custom Share View Controller
class CustomShareViewController: UIViewController {
    private let image: UIImage
    private var activityViewController: UIActivityViewController?
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .pageSheet
        
        if let sheetController = self.sheetPresentationController {
            sheetController.detents = [.large()]
            sheetController.selectedDetentIdentifier = .large
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.preferredCornerRadius = 20
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // Create container stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add export label
        let exportLabel = UILabel()
        exportLabel.text = "Export"
        exportLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        exportLabel.textAlignment = .center
        exportLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create tappable image container
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.backgroundColor = .systemGray6
        imageContainer.layer.cornerRadius = 16
        imageContainer.clipsToBounds = true
        
        // Add large image preview
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        // Add tap gesture for zoom
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        imageContainer.addSubview(imageView)
        
        // Create activity view controller
        let imageSource = ImageActivityItemSource(image: image)
        activityViewController = UIActivityViewController(
            activityItems: [imageSource],
            applicationActivities: nil
        )
        
        guard let activityViewController = activityViewController else { return }
        
        activityViewController.excludedActivityTypes = []
        activityViewController.modalPresentationStyle = .none
        
        // Add activity controller as child
        addChild(activityViewController)
        activityViewController.view.translatesAutoresizingMaskIntoConstraints = false
        activityViewController.view.backgroundColor = .clear
        
        // Add completion handler to dismiss when done
        activityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.dismiss(animated: true)
        }
        
        // Add views to stack
        stackView.addArrangedSubview(exportLabel)
        stackView.addArrangedSubview(imageContainer)
        stackView.addArrangedSubview(activityViewController.view)
        
        view.addSubview(stackView)
        
        // Setup constraints with wider layout
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Make image container much larger
            imageContainer.heightAnchor.constraint(equalToConstant: 300),
            
            // Image view fills container with padding
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -12),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -12),
            
            activityViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])
        
        activityViewController.didMove(toParent: self)
    }
    
    @objc private func imageViewTapped() {
        let zoomView = ZoomableImageView(image: image)
        let hostingController = UIHostingController(rootView: 
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            self.dismiss(animated: true)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    zoomView
                        .onTapGesture {
                            self.dismiss(animated: true)
                        }
                }
            }
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}



// MARK: - Image Activity Item Source
class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: Date())
        return "Quick Split - \(dateString)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "public.image"
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: Date())
        metadata.title = "Quick Split - \(dateString)"
        
        let imageProvider = NSItemProvider(object: image)
        metadata.imageProvider = imageProvider
        
        return metadata
    }
}

