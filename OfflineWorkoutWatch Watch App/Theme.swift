import SwiftUI

/**
 * Centralized theme configuration for consistent styling across iOS and watchOS.
 */
struct Theme {
    
    // MARK: - Colors
    
    /// Primary accent color for buttons, highlights, and interactive elements
    static let accentColor = Color("AccentColor")
    
    /// Primary background color
    static let primaryBackground = Color.black
    
    /// Secondary background color for cards and sections
    static let secondaryBackground = Color.gray
    
    /// Tertiary background color for subtle elements
    static let tertiaryBackground = Color.gray.opacity(0.3)
    
    /// Primary text color
    static let primaryText = Color.white
    
    /// Secondary text color for subtitles and descriptions
    static let secondaryText = Color.gray
    
    /// Success color for positive actions and states
    static let successColor = Color.green
    
    /// Warning color for caution states
    static let warningColor = Color.orange
    
    /// Error color for error states and destructive actions
    static let errorColor = Color.red
    
    // MARK: - Spacing
    
    /// Extra small spacing (4pt)
    static let spacingXS: CGFloat = 4
    
    /// Small spacing (8pt)
    static let spacingS: CGFloat = 8
    
    /// Medium spacing (16pt)
    static let spacingM: CGFloat = 16
    
    /// Large spacing (24pt)
    static let spacingL: CGFloat = 24
    
    /// Extra large spacing (32pt)
    static let spacingXL: CGFloat = 32
    
    // MARK: - Corner Radius
    
    /// Small corner radius for buttons and small cards
    static let cornerRadiusS: CGFloat = 8
    
    /// Medium corner radius for cards and modals
    static let cornerRadiusM: CGFloat = 12
    
    /// Large corner radius for prominent elements
    static let cornerRadiusL: CGFloat = 16
    
    // MARK: - Tap Targets
    
    /// Minimum tap target size for accessibility (44pt)
    static let minTapTarget: CGFloat = 44
    
    /// Preferred tap target size for watch (40pt for compact interaction)
    static let watchTapTarget: CGFloat = 20
    
    // MARK: - Typography
    
    /// Large title for main headings
    static let largeTitleFont = Font.largeTitle.weight(.bold)
    
    /// Title font for section headers
    static let titleFont = Font.title2.weight(.semibold)
    
    /// Headline font for card titles
    static let headlineFont = Font.headline.weight(.medium)
    
    /// Body font for main content
    static let bodyFont = Font.body
    
    /// Caption font for secondary information
    static let captionFont = Font.caption
    
    /// Button font for primary actions
    static let buttonFont = Font.headline.weight(.medium)
    
    // MARK: - Watch-Specific Adjustments
    
    #if os(watchOS)
    /// Watch-optimized spacing (reduced for smaller screen)
    static let watchSpacingS: CGFloat = 6
    static let watchSpacingM: CGFloat = 12
    static let watchSpacingL: CGFloat = 18
    
    /// Watch-optimized typography (slightly larger for readability)
    static let watchBodyFont = Font.body.weight(.medium)
    static let watchCaptionFont = Font.caption.weight(.medium)
    #endif
}

// MARK: - View Modifiers

extension View {
    
    /**
     * Applies consistent card styling with rounded corners and background.
     */
    func cardStyle() -> some View {
        self
            .background(Theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusM))
    }
    
    /**
     * Applies primary button styling with proper tap targets.
     */
    func primaryButtonStyle() -> some View {
        self
            .font(Theme.buttonFont)
            .foregroundStyle(.white)
            .frame(minHeight: Theme.minTapTarget)
            .background(Theme.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    
    /**
     * Applies secondary button styling.
     */
    func secondaryButtonStyle() -> some View {
        self
            .font(Theme.buttonFont)
            .foregroundStyle(Theme.accentColor)
            .frame(minHeight: Theme.minTapTarget)
            .background(Theme.tertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    
    /**
     * Applies destructive button styling for delete actions.
     */
    func destructiveButtonStyle() -> some View {
        self
            .font(Theme.buttonFont)
            .foregroundStyle(.white)
            .frame(minHeight: Theme.minTapTarget)
            .background(Theme.errorColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    
    #if os(watchOS)
    /**
     * Applies watch-optimized button styling with larger tap targets.
     */
    func watchButtonStyle() -> some View {
        self
            .font(Theme.buttonFont)
            .foregroundStyle(.white)
            .frame(minHeight: Theme.watchTapTarget)
            .background(Theme.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    
    /**
     * Applies watch-optimized secondary button styling.
     */
    func watchSecondaryButtonStyle() -> some View {
        self
            .font(Theme.buttonFont)
            .foregroundStyle(Theme.accentColor)
            .frame(minHeight: Theme.watchTapTarget)
            .background(Theme.tertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
    #endif
    
    /**
     * Applies consistent section header styling.
     */
    func sectionHeaderStyle() -> some View {
        self
            .font(Theme.titleFont)
            .foregroundStyle(Theme.primaryText)
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
    }
    
    /**
     * Applies consistent list row styling with proper spacing.
     */
    func listRowStyle() -> some View {
        self
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(Theme.primaryBackground)
    }
    
    /**
     * Applies form field styling with consistent appearance.
     */
    func formFieldStyle() -> some View {
        self
            .padding(Theme.spacingM)
            .background(Theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
}

// MARK: - Sync Status Styling

extension View {
    /**
     * Applies sync status indicator styling.
     */
    func syncStatusStyle() -> some View {
        self
            .font(Theme.captionFont)
            .foregroundStyle(Theme.secondaryText)
            .padding(.horizontal, Theme.spacingS)
            .padding(.vertical, Theme.spacingXS)
            .background(Theme.tertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
}

// MARK: - Accessibility Helpers

extension View {
    /**
     * Ensures proper tap target size for accessibility.
     */
    func accessibleTapTarget() -> some View {
        self
            .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
    }
    
    /**
     * Applies dynamic type scaling for better accessibility.
     */
    func accessibleFont(_ font: Font) -> some View {
        self
            .font(font)
            .dynamicTypeSize(.accessibility1...(.accessibility5))
    }
    
    /**
     * Adds accessibility traits and labels for better VoiceOver support.
     */
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
    
    /**
     * Ensures minimum contrast for text elements.
     */
    func highContrastText() -> some View {
        self
            .foregroundStyle(Theme.primaryText)
            .background(Theme.primaryBackground)
    }
}
