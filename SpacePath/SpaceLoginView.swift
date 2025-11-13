import SwiftUI
import Combine

// MARK: - User Data Manager
class UserDataManager: ObservableObject {
    @Published var userName: String
    @Published var characterIndex: Int
    @Published var hasCompletedOnboarding: Bool
    
    private let userNameKey = "userName"
    private let characterKey = "characterIndex"
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        self.userName = UserDefaults.standard.string(forKey: userNameKey) ?? ""
        self.characterIndex = UserDefaults.standard.integer(forKey: characterKey)
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func saveUserData(name: String, character: Int) {
        self.userName = name
        self.characterIndex = character
        self.hasCompletedOnboarding = true
        
        UserDefaults.standard.set(name, forKey: userNameKey)
        UserDefaults.standard.set(character, forKey: characterKey)
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: characterKey)
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        self.userName = ""
        self.characterIndex = 0
        self.hasCompletedOnboarding = false
    }
    
    var characterImageName: String {
        characterIndex == 0 ? "Boys" : "Girls"
    }
    
    var characterColor: Color {
        characterIndex == 0 ? .blue : .pink
    }
}

// MARK: - Main App Entry View
struct SpacePathMainView: View {
    @StateObject private var userDataManager = UserDataManager()
    
    var body: some View {
        NavigationStack {
            Group {
                if userDataManager.hasCompletedOnboarding {
                    ContentViewer(
                        userName: userDataManager.userName,
                        characterImageName: userDataManager.characterImageName,
                        characterColor: userDataManager.characterColor
                    )
                    .environmentObject(userDataManager)
                } else {
                    SpaceLoginView()
                        .environmentObject(userDataManager)
                }
            }
        }
    }
}

// MARK: - Space Login View
struct SpaceLoginView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var name: String = ""
    @State private var selectedCharacter: Int? = nil
    @State private var showStartMessage: Bool = false

    var body: some View {
        ZStack {
            // 🌌 Background
            Image("main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 🪐 Title
                Text("الفضاء أقرب مما تتخيل!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                    .multilineTextAlignment(.center)

                // 👩🏻‍🚀 Character Selection
                HStack(spacing: 40) {
                    CharacterCircleView(
                        imageName: "Boys",
                        title: "رائد الفضاء",
                        isSelected: selectedCharacter == 0,
                        selectedColor: .blue
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedCharacter = 0
                        }
                    }

                    CharacterCircleView(
                        imageName: "Girls",
                        title: "رائدة الفضاء",
                        isSelected: selectedCharacter == 1,
                        selectedColor: .pink
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedCharacter = 1
                        }
                    }
                }
                .padding(.horizontal, 50)

                Spacer()

                // 🧑‍🚀 Name Input & Circular Start Button
                if let character = selectedCharacter {
                    VStack(spacing: 20) {
                        // Glass TextField
                        ZStack {
                            RoundedRectangle(cornerRadius: 35)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .white.opacity(0.12), radius: 3, x: -2, y: -2)
                                .shadow(color: .black.opacity(0.45), radius: 8, x: 3, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 35)
                                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                                )
                                .frame(height: 55)

                            TextField(
                                character == 0 ? "اسمك يا رائد الفضاء 👨🏻‍🚀" : "اسمك يا رائدة الفضاء 👩🏻‍🚀",
                                text: $name
                            )
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .frame(height: 55)
                        }
                        .padding(.horizontal, 40)

                        // 🚀 Circular Start Button
                        Button(action: {
                            // Save user data
                            userDataManager.saveUserData(name: name, character: character)
                            
                            // Show confirmation message
                            withAnimation {
                                showStartMessage = true
                            }
                            
                            // Data is saved, SpacePathMainView will automatically switch views
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                (character == 0 ? Color.blue : Color.pink).opacity(0.5),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                                    .frame(width: 80, height: 80)

                                Text("🚀")
                                    .font(.system(size: 32))
                                    .shadow(color: .white.opacity(0.6), radius: 6)
                            }
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.6 : 1.0)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }

            // 🌟 Confirmation message
            if showStartMessage {
                VStack {
                    Spacer()
                    Text("✨ رحلتك إلى الفضاء بدأت يا \(name.isEmpty ? "مستكشف" : name)! ✨")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.4), radius: 10)
                        )
                        .padding(.bottom, 100)
                        .transition(.opacity)
                    Spacer()
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Character Circle
struct CharacterCircleView: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let selectedColor: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isSelected ? selectedColor : .white.opacity(0.3),
                                lineWidth: isSelected ? 4 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? selectedColor.opacity(0.5) : .black.opacity(0.25),
                        radius: 15, x: 0, y: 6
                    )
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                    )
                    .clipped()
            }
            .frame(width: 115, height: 115)

            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    SpacePathMainView()
}
