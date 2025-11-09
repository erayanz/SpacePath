import SwiftUI

struct SpaceLoginView: View {
    @State private var name: String = ""
    @State private var selectedCharacter: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("First")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Title
                    Text("الفضاء أقرب مما تتخيل!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    
                    // Character Selection
                    HStack(spacing: 20) {
                        // Boys Character
                        CharacterCardView(
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
                        
                        // Girls Character
                        CharacterCardView(
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
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Name Input and Button (only show after character selection)
                    if let character = selectedCharacter {
                        VStack(spacing: 16) {
                            // Text Field
                            TextField(
                                character == 0 ? "اسمك يا رائد الفضاء 👨🏻‍🚀" : "اسمك يا رائدة الفضاء 👩🏻‍🚀",
                                text: $name
                            )
                            .textFieldStyle(.plain)
                            .font(.body)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 40)
                            
                            // Start Button
                            NavigationLink(destination: MainAppView(userName: name, characterType: character)) {
                                Text(character == 0 ? "انطلق في رحلتنا 🚀" : "انطلقي في رحلتنا 🚀")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: name.isEmpty ?
                                                [.gray.opacity(0.3), .gray.opacity(0.2)] :
                                                [.blue.opacity(0.8), .purple.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 16)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .disabled(name.isEmpty)
                            .padding(.horizontal, 40)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Reusable Character Card Component
struct CharacterCardView: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? selectedColor.opacity(0.4) : .clear)
                    .frame(width: 140, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                isSelected ? selectedColor : .white.opacity(0.2),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .shadow(color: isSelected ? selectedColor.opacity(0.5) : .clear, radius: 20)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// Main App View with Character and Background
struct MainAppView: View {
    let userName: String
    let characterType: Int
    
    var body: some View {
        ZStack {
            // Same Background as Login
            Image("First")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Welcome Message
                Text("مرحباً، \(userName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                // Selected Character Image
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 200)
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(characterType == 0 ? Color.blue.opacity(0.3) : Color.pink.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(
                                    characterType == 0 ? .blue : .pink,
                                    lineWidth: 3
                                )
                        )
                    
                    Image(characterType == 0 ? "Boys" : "Girls")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                }
                .shadow(color: (characterType == 0 ? Color.blue : Color.pink).opacity(0.5), radius: 30)
                
                // Character Type Text
                Text(characterType == 0 ? "أصبحت رائد فضاء مستكشف!" : "أصبحتِ رائدة فضاء مستكشفة!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                // Continue Button
                Button {
                    // Add your navigation to next screen here
                } label: {
                    Text("ابدأ المغامرة 🌟")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: characterType == 0 ?
                                    [.blue.opacity(0.8), .purple.opacity(0.6)] :
                                    [.pink.opacity(0.8), .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    SpaceLoginView()
}
