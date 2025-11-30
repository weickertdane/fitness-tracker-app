import SwiftUI

/**
 * Form for creating exercise templates on Apple Watch with simplified interface.
 */
struct ExerciseTemplateFormView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedGoal: Goal = .rehab
    @State private var selectedBodyPart: BodyPart = .chest
    @State private var selectedMetrics: Set<MetricType> = [.reps, .weightLbs]
    @State private var currentStep: FormStep = .name
    
    enum FormStep: CaseIterable {
        case name, goal, bodyPart, metrics, review
        
        var title: String {
            switch self {
            case .name: return "Exercise Name"
            case .goal: return "Goal"
            case .bodyPart: return "Body Part"
            case .metrics: return "Track Metrics"
            case .review: return "Review"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Current step content
                stepContent
                
                Spacer(minLength: 8)
                
                // Navigation buttons
                navigationButtons
            }
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption2)
                }
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(FormStep.allCases.indices, id: \.self) { index in
                Rectangle()
                    .fill(index <= FormStep.allCases.firstIndex(of: currentStep)! ? Theme.accentColor : Theme.secondaryText.opacity(0.3))
                    .frame(height: 2)
            }
        }
        .padding(.horizontal, Theme.watchSpacingM)
        .padding(.top, 2)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(spacing: Theme.watchSpacingM) {
                switch currentStep {
                case .name:
                    nameStepView
                case .goal:
                    goalStepView
                case .bodyPart:
                    bodyPartStepView
                case .metrics:
                    metricsStepView
                case .review:
                    reviewStepView
                }
            }
            .padding(.horizontal, Theme.watchSpacingM)
            .padding(.top, 2)
            .padding(.bottom, Theme.watchSpacingS)
        }
    }
    
    // MARK: - Name Step
    
    private var nameStepView: some View {
        VStack(spacing: Theme.watchSpacingS) {
            TextField("e.g., Push-ups", text: $name)
                .textFieldStyle(.automatic)
        }
    }
    
    // MARK: - Goal Step
    
    private var goalStepView: some View {
        VStack(spacing: Theme.watchSpacingM) {
            ForEach(goalOrder, id: \.self) { goal in
                Button(action: {
                    selectedGoal = goal
                }) {
                    HStack {
                        Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedGoal == goal ? Theme.accentColor : Theme.secondaryText)
                        
                        Text(goal.rawValue.capitalized)
                            .font(Theme.watchBodyFont)
                        
                        Spacer()
                    }
                    .padding(Theme.watchSpacingS)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var goalOrder: [Goal] {
        [.rehab, .strength, .cardio]
    }
    
    // MARK: - Body Part Step
    
    private var bodyPartStepView: some View {
        ScrollView {
            VStack(spacing: Theme.watchSpacingM) {
                ForEach(bodyPartOrder, id: \.self) { bodyPart in
                    Button(action: {
                        selectedBodyPart = bodyPart
                    }) {
                        HStack {
                            Image(systemName: selectedBodyPart == bodyPart ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedBodyPart == bodyPart ? Theme.accentColor : Theme.secondaryText)
                            
                            Text(bodyPart.rawValue.capitalized)
                                .font(Theme.watchBodyFont)
                            
                            Spacer()
                        }
                        .padding(Theme.watchSpacingS)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var bodyPartOrder: [BodyPart] {
        [.chest, .back, .shoulders, .biceps, .triceps, .abs, .quads, .hamstrings, .glutes, .calves, .other]
    }
    
    // MARK: - Metrics Step
    
    private var metricsStepView: some View {
        VStack(spacing: Theme.watchSpacingL) {
            
            VStack(spacing: Theme.watchSpacingM) {
                ForEach(MetricType.allCases, id: \.self) { metric in
                    Button(action: {
                        if selectedMetrics.contains(metric) {
                            selectedMetrics.remove(metric)
                        } else {
                            selectedMetrics.insert(metric)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedMetrics.contains(metric) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedMetrics.contains(metric) ? Theme.accentColor : Theme.secondaryText)
                            
                            Text(metricDisplayName(for: metric))
                                .font(Theme.watchBodyFont)
                            
                            Spacer()
                        }
                        .padding(Theme.watchSpacingS)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Review Step
    
    private var reviewStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Exercise Name
            Text(name)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Attributes with proper indentation
            VStack(alignment: .leading, spacing: 10) {
                reviewRow(label: "Goal", value: selectedGoal.rawValue.capitalized)
                reviewRow(label: "Body Part", value: selectedBodyPart.rawValue.capitalized)
                reviewRow(label: "Tracks", value: selectedMetrics.map { metricDisplayName(for: $0) }.joined(separator: ", "))
            }
            .padding(.leading, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func reviewRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Theme.secondaryText)
            
            Text(value)
                .font(.caption)
                .foregroundStyle(Theme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: Theme.watchSpacingM) {
            // Back Button
            if currentStep != .name {
                Button(action: previousAction) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(width: 32, height: 32)
                .background(Theme.tertiaryBackground)
                .foregroundStyle(Theme.primaryText)
                .clipShape(Circle())
            } else {
                // Spacer to center the next button when no back button
                Spacer()
            }
            
            Spacer()
            
            // Next/Create Button
            Button(action: nextAction) {
                Image(systemName: currentStep == .review ? "checkmark" : "chevron.right")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .frame(width: 32, height: 32)
            .background(canProceed ? Theme.accentColor : Theme.secondaryText)
            .foregroundStyle(.white)
            .clipShape(Circle())
            .disabled(!canProceed)
        }
        .padding(.horizontal, Theme.watchSpacingM)
        .padding(.vertical, Theme.watchSpacingS)
    }
    
    // MARK: - Helper Methods
    
    private var nextButtonTitle: String {
        currentStep == .review ? "Create Exercise" : "Next"
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .name: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .goal, .bodyPart: return true
        case .metrics: return !selectedMetrics.isEmpty
        case .review: return true
        }
    }
    
    private func nextAction() {
        if currentStep == .review {
            createExercise()
        } else {
            withAnimation {
                currentStep = FormStep.allCases[FormStep.allCases.firstIndex(of: currentStep)! + 1]
            }
        }
    }
    
    private func previousAction() {
        withAnimation {
            currentStep = FormStep.allCases[FormStep.allCases.firstIndex(of: currentStep)! - 1]
        }
    }
    
    private func createExercise() {
        let _ = viewModel.createExercise(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            goal: selectedGoal,
            bodyPart: selectedBodyPart,
            allowedMetrics: Array(selectedMetrics)
        )
        
        dismiss()
    }
    
    private func goalIcon(for goal: Goal) -> String {
        switch goal {
        case .strength:
            return "bolt.fill"
        case .rehab:
            return "heart.fill"
        case .cardio:
            return "figure.run"
        }
    }
    
    private func bodyPartIcon(for bodyPart: BodyPart) -> String {
        switch bodyPart {
        case .chest: return "heart"
        case .back: return "figure.walk"
        case .shoulders: return "figure.arms.open"
        case .biceps, .triceps, .forearms: return "figure.strengthtraining.traditional"
        case .quads, .hamstrings, .calves, .glutes: return "figure.run"
        case .abs, .obliques, .erectors: return "circle.grid.cross"
        case .hips, .adductors, .abductors, .ankle, .tibialis, .peroneals, .other: return "ellipsis.circle"
        }
    }
    
    private func metricDisplayName(for metric: MetricType) -> String {
        switch metric {
        case .reps: return "Reps"
        case .weightLbs: return "Weight"
        case .durationSeconds: return "Duration"
        case .distanceMeters: return "Distance"
        case .steps: return "Steps"
        case .pain: return "Pain Level"
        }
    }
}

#Preview {
    ExerciseTemplateFormView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
