import SwiftUI

struct ContentViewer: View {
    // User profile data
    let userName: String
    let characterImageName: String
    let characterColor: Color
    
    @State private var rotatePlanet = false
    @State private var isPressed = false
    @State private var animateButton = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userDataManager: UserDataManager

    var body: some View {
        ZStack {
            // 🌌 Background
            Image("main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // ✨ Overlay darkness
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            // 🪐 Background Planets
            planetLayer
            
            // 🌟 Foreground Content
            VStack(spacing: 40) {
                // 👤 Profile Section at Top Left (Now Tappable)
                HStack {
                    NavigationLink(destination: UserProfileView()
                        .environmentObject(userDataManager)
                        .environment(\.layoutDirection, .rightToLeft)
                    ) {
                        HStack(spacing: 12) {
                            // Profile Image
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(characterColor, lineWidth: 3)
                                    )
                                    .shadow(color: characterColor.opacity(0.5), radius: 8, x: 0, y: 4)
                                    .frame(width: 60, height: 60)
                                
                                Image(characterImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            
                            // Name
                            Text(userName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 35)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 35)
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 50)
                    .padding(.top, 2)
                    
                    Spacer()
                }
                
                Spacer()
                
                // MARK: - 🪐 "استكشف" Section
                VStack(alignment: .trailing, spacing: 20) {
                    // Title on right
                    Text("استكشف")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .blue.opacity(0.6), radius: 10)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 260)
                    
                    // Centered solar system button with NavigationLink
                    NavigationLink(destination: ARmap()
                        .environment(\.layoutDirection, .rightToLeft)
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.08),
                                            Color.blue.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Image("solary4")
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                        .scaleEffect(isPressed ? 0.98 : 1.0)
                                        .opacity(isPressed ? 0.9 : 1.0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.002), lineWidth: 1)
                                )
                                .shadow(color: .blue.opacity(0.4), radius: 25, x: 0, y: 8)
                                .shadow(color: .white.opacity(0.2), radius: 10, x: -4, y: -4)
                                .scaleEffect(isPressed ? 0.97 : 1)
                                .rotation3DEffect(
                                    .degrees(isPressed ? 5 : 0),
                                    axis: (x: 1, y: -1, z: 0)
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
                        }
                        .frame(width: 340, height: 180)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPressed = false
                                }
                            }
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // MARK: - 🎮 "العـب" Section
                VStack(alignment: .trailing, spacing: 20) {
                    // Title on right
                    Text("العـب")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .blue.opacity(0.4), radius: 10)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 300)
                    
                    // Centered row of buttons
                    HStack(spacing: 30) {
                        // 🔹 "مدارات" NavigationLink
                        NavigationLink(destination: Planetgame()
                            .environment(\.layoutDirection, .rightToLeft)
                        ) {
                            gameButtonWithTextBelow(icon: "S", title: "مدارات", animate: animateButton)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    animateButton.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        animateButton.toggle()
                                    }
                                }
                            }
                        )
                        
                        // 🔹 "رواد" NavigationLink
                        NavigationLink(destination: Astronautsgame()
                            .environment(\.layoutDirection, .rightToLeft)
                        ) {
                            gameButtonWithTextBelow(icon: "ff", title: "رواد")
                        }
                        .buttonStyle(.plain)
                        
                        // 🔹 "كواكب" - Linked to HomeView
                        NavigationLink(destination: HomeView()
                            .environment(\.layoutDirection, .rightToLeft)
                        ) {
                            gameButtonWithTextBelow(icon: "A 1", title: "كواكب")
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Game Button with Text Below (90x90 size)
    private func gameButtonWithTextBelow(icon: String, title: String, animate: Bool = false) -> some View {
        VStack(spacing: 10) {
            // Button with full image - 90x90 to match previous size
            Image(icon)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 6)
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animate)
            
            // Text below the button
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }

    // MARK: - Background Planets
    var planetLayer: some View {
        ZStack {
            Image("7")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .offset(x: 160, y: 130)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 50).repeatForever(autoreverses: false), value: rotatePlanet)

            Image("1")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .offset(x: -190, y: 200)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 50).repeatForever(autoreverses: false), value: rotatePlanet)

            Image("2")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .offset(x: -190, y: -300)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 50).repeatForever(autoreverses: false), value: rotatePlanet)

            Image("3")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: -50, y: -400)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 50).repeatForever(autoreverses: false), value: rotatePlanet)

            Image("6")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 370)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 50).repeatForever(autoreverses: false), value: rotatePlanet)

            Image("5")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(x: 0, y: -259)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotatePlanet)
                .onAppear { rotatePlanet = true }
        }
    }
}

// MARK: - User Profile View
struct UserProfileView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 🌌 Background
            Image("main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // ✨ Overlay darkness
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 👤 Large Character Display
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .strokeBorder(userDataManager.characterColor, lineWidth: 5)
                            )
                            .shadow(color: userDataManager.characterColor.opacity(0.6), radius: 20, x: 0, y: 10)
                            .frame(width: 180, height: 180)
                        
                        Image(userDataManager.characterImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                    }
                    
                    // User Name
                    Text(userDataManager.userName)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5)
                    
                    // Character Type
                    Text(userDataManager.characterIndex == 0 ? "رائد الفضاء 👨🏻‍🚀" : "رائدة الفضاء 👩🏻‍🚀")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 3)
                }
                
                Spacer()
                
                // 🔄 Change Character/Name Button
                NavigationLink(destination: SpaceLoginView()
                    .environmentObject(userDataManager)
                    .environment(\.layoutDirection, .rightToLeft)
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.pencil")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("تغيير الشكل/الاسم")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .strokeBorder(userDataManager.characterColor.opacity(0.6), lineWidth: 2)
                            )
                            .shadow(color: userDataManager.characterColor.opacity(0.4), radius: 15, x: 0, y: 8)
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(false)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    NavigationStack {
        ContentViewer(userName: "أحمد", characterImageName: "Boys", characterColor: .blue)
            .environmentObject(UserDataManager())
    }
}
