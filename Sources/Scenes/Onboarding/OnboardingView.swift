import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer(minLength: 20)

                // HERO IMAGE
                Image("onboarding_hero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 16)

                // TEXT BLOCK
                VStack(alignment: .leading, spacing: 16) {
                    Text("Never Miss Bin Day")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)

                    Text("FOR SALFORD RESIDENTS")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 10) {
                        FeatureRow(icon: "♻️", text: "Instantly see which bins go out this week")
                        FeatureRow(icon: "📍", text: "Uses your address to get the correct schedule")
                        FeatureRow(icon: "⏰", text: "Set gentle reminders so you don’t miss bin day")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer()

                // BUTTON
                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - FeatureRow used in the onboarding bullets
private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 24, alignment: .center)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}
