import SwiftUI
import SwiftData

/**
 * History view with collapsible calendar and workout indicators.
 */
struct HistoryCalendarView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var syncStatus = CloudKitSyncStatus.shared
    @State private var isCalendarExpanded = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Collapsible Calendar Header
                calendarHeader
                
                // Expandable Calendar
                if isCalendarExpanded {
                    calendarView
                }
                
                Divider()
                
                // Workout List for Selected Date
                WorkoutListForDayView(selectedDate: viewModel.selectedDate)
                
                Spacer()
                
                // Sync Status Footer
                SyncStatusFooterView()
                    .padding(.horizontal, Theme.spacingM)
                    .padding(.bottom, Theme.spacingS)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        viewModel.selectDate(Date())
                        if isCalendarExpanded {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isCalendarExpanded = false
                            }
                        }
                    }
                    .font(.subheadline)
                }
            }
            .refreshable {
                viewModel.refreshWorkouts()
                syncStatus.simulateSync()
            }
        }
        .onAppear {
            syncStatus.startMonitoring()
        }
    }
    
    // MARK: - Calendar Header
    
    private var calendarHeader: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isCalendarExpanded.toggle()
            }
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.selectedDate, format: .dateTime.month(.wide).day().year())
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.workoutCountForSelectedDate) workout\(viewModel.workoutCountForSelectedDate == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isCalendarExpanded ? "chevron.up.circle.fill" : "calendar.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Calendar View
    
    private var calendarView: some View {
        VStack(spacing: 8) {
            // Calendar with custom background for workout dates
            ZStack(alignment: .topLeading) {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { viewModel.selectedDate },
                        set: { newDate in
                            viewModel.selectDate(newDate)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isCalendarExpanded = false
                            }
                        }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Workout indicator legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Selected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.datesWithWorkouts.count) days with workouts")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

/**
 * Displays sync status information in a subtle footer.
 */
private struct SyncStatusFooterView: View {
    @State private var syncStatus = CloudKitSyncStatus.shared
    
    var body: some View {
        HStack {
            // Sync Status Icon
            Image(systemName: syncStatusIcon)
                .foregroundStyle(syncStatusColor)
                .font(Theme.captionFont)
            
            // Status Message
            Text(syncStatus.statusMessage)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            
            Spacer()
            
            // Error Details (if present)
            if syncStatus.hasError, let error = syncStatus.currentError {
                Button(action: {
                    // Could show error details in alert
                    syncStatus.refreshStatus()
                }) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Theme.errorColor)
                        .font(Theme.captionFont)
                }
                .accessibilityLabel("Sync error details")
            }
        }
        .padding(.horizontal, Theme.spacingS)
        .padding(.vertical, Theme.spacingXS)
        .background(Theme.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    
    private var syncStatusIcon: String {
        switch syncStatus.syncState {
        case .unknown:
            return "questionmark.circle"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .synced:
            return "checkmark.circle"
        case .error:
            return "exclamationmark.triangle"
        case .offline:
            return "wifi.slash"
        }
    }
    
    private var syncStatusColor: Color {
        switch syncStatus.syncState {
        case .unknown:
            return Theme.secondaryText
        case .syncing:
            return Theme.accentColor
        case .synced:
            return Theme.successColor
        case .error:
            return Theme.errorColor
        case .offline:
            return Theme.warningColor
        }
    }
}

#Preview {
    HistoryCalendarView()
        .environment(HistoryViewModel(modelContext: PreviewHelper.previewContext))
}