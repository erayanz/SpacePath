import SwiftUI

struct Planet: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String
    let targetOrbit: Int
}

struct Planetgame: View {
    @Environment(\.dismiss) private var dismiss
    
    // real game data (correct order)
    @State private var planets: [Planet] = [
        Planet(name: "Mercury", imageName: "mercury", targetOrbit: 1),
        Planet(name: "Venus", imageName: "venus", targetOrbit: 2),
        Planet(name: "Earth", imageName: "earth", targetOrbit: 3),
        Planet(name: "Mars", imageName: "mars", targetOrbit: 4),
        Planet(name: "Jupiter", imageName: "jupiter", targetOrbit: 5),
        Planet(name: "Saturn", imageName: "saturn", targetOrbit: 6),
        Planet(name: "Uranus", imageName: "uranus", targetOrbit: 7),
        Planet(name: "Neptune", imageName: "neptune", targetOrbit: 8)
    ]
    
    // shuffled order for the right side
    @State private var displayOrder: [Planet] = []
    @State private var placedPlanets: [Int: Planet] = [:]
    
    // Feedback states
    @State private var feedbackColor: Color = .clear
    @State private var showFeedback = false
    @State private var wrongOrbit: Int? = nil
    @State private var showConfetti = false
    @State private var gameCompleted = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background with feedback color overlay
                Color.black.ignoresSafeArea()
                
                // Feedback flash overlay
                feedbackColor
                    .ignoresSafeArea()
                    .opacity(showFeedback ? 0.3 : 0)
                    .animation(.easeOut(duration: 0.6), value: showFeedback)
                
                // background image
                HStack {
                    Image("new orbit image 8")
                        .resizable()
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
                .zIndex(0)
                
                // orbits + placed planets
                OrbitDropTargets(
                    viewSize: geo.size,
                    placedPlanets: placedPlanets,
                    wrongOrbit: wrongOrbit
                )
                .zIndex(1)
                
                // right column with shuffled planets
                VStack(spacing: 8) {
                    ForEach(displayOrder) { planet in
                        if !placedPlanets.values.contains(planet) {
                            DraggablePlanetView(
                                planet: planet,
                                screenSize: geo.size
                            ) { droppedOrbit in
                                handleDrop(planet: planet, on: droppedOrbit)
                            }
                            .frame(width: 50, height: 50)
                        } else {
                            Color.clear.frame(width: 50, height: 50)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 350)
                .padding(.top, 140)
                .zIndex(5)
                
                // title text centered
                VStack(spacing: 4) {
                    Text("لعبة: ترتيب الكواكب")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("اسحب الكوكب إلى مداره الصحيح")
                        .foregroundColor(.white.opacity(0.8))
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .zIndex(10)
                .position(x: geo.size.width / 2, y: 60)
                
                // Confetti effect
                if showConfetti {
                    ConfettiView()
                        .zIndex(100)
                }
                
                // Completion overlay
                if gameCompleted {
                    CompletionView(onRestart: restartGame, onDismiss: { dismiss() })
                        .zIndex(200)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .onAppear {
                displayOrder = planets.shuffled()
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func handleDrop(planet: Planet, on orbit: Int?) -> Bool {
        guard let orbit = orbit else {
            flashFeedback(color: .red)
            return false
        }
        
        if orbit == planet.targetOrbit && placedPlanets[orbit] == nil {
            placedPlanets[orbit] = planet
            flashFeedback(color: .green)
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Check if game is completed
            if placedPlanets.count == planets.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        gameCompleted = true
                        showConfetti = true
                    }
                    
                    // Stop confetti after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showConfetti = false
                        }
                    }
                }
            }
            
            return true
        } else {
            wrongOrbit = orbit
            flashFeedback(color: .red)
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // Reset wrong orbit highlight after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongOrbit = nil
            }
            
            return false
        }
    }
    
    private func flashFeedback(color: Color) {
        feedbackColor = color
        showFeedback = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showFeedback = false
        }
    }
    
    private func restartGame() {
        withAnimation {
            placedPlanets.removeAll()
            displayOrder = planets.shuffled()
            gameCompleted = false
        }
    }
}

// MARK: - Orbit Drop Targets
struct OrbitDropTargets: View {
    let viewSize: CGSize
    let placedPlanets: [Int: Planet]
    let wrongOrbit: Int?
    
    private func orbitXs(_ size: CGSize) -> [CGFloat] {
        [
            size.width * 0.25,
            size.width * 0.32,
            size.width * 0.40,
            size.width * 0.47,
            size.width * 0.56,
            size.width * 0.63,
            size.width * 0.70,
            size.width * 0.79
        ]
    }
    
    var body: some View {
        let xs = orbitXs(viewSize)
        let y = viewSize.height / 2
        
        ForEach(0..<8, id: \.self) { index in
            let orbitNumber = index + 1
            let point = CGPoint(x: xs[index], y: y)
            let isWrong = wrongOrbit == orbitNumber
            
            if let planet = placedPlanets[orbitNumber] {
                Image(planet.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .position(point)
                    .scaleEffect(1.0)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: placedPlanets.count)
            } else {
                Circle()
                    .strokeBorder(
                        isWrong ? Color.red.opacity(0.8) : Color.gray.opacity(0.6),
                        lineWidth: isWrong ? 3 : 2
                    )
                    .background(Circle().fill(
                        isWrong ? Color.red.opacity(0.2) : Color.white.opacity(0.12)
                    ))
                    .frame(width: 46, height: 46)
                    .position(point)
                    .modifier(ShakeEffect(shakes: isWrong ? 3 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isWrong)
            }
        }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var shakes: Int
    
    var animatableData: Int {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = shakes == 0 ? 0 : sin(CGFloat(shakes) * .pi * 2) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let onRestart: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Emoji with bounce animation
                Text("🎉")
                    .font(.system(size: 100))
                    .scaleEffect(1.0)
                
                VStack(spacing: 12) {
                    Text("أحسنت!")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("لقد رتبت جميع الكواكب بنجاح!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 16) {
                    // Restart button - icon only
                    Button(action: onRestart) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Close button - icon only
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.top, 8)
            }
            .padding(48)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 1.5)
                        .position(piece.position)
                        .rotationEffect(piece.rotation)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .orange, .pink, .cyan]
        
        for _ in 0..<80 {
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: -100...0)
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2.5...4.0)
            
            var piece = ConfettiPiece(
                color: colors.randomElement() ?? .yellow,
                position: CGPoint(x: startX, y: startY),
                size: CGFloat.random(in: 6...12),
                rotation: Angle(degrees: Double.random(in: 0...360)),
                opacity: 1.0
            )
            
            confettiPieces.append(piece)
            
            // Animate falling with fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration)) {
                    if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                        confettiPieces[index].position.y = size.height + 100
                        confettiPieces[index].position.x += CGFloat.random(in: -50...50)
                        confettiPieces[index].rotation = Angle(degrees: Double.random(in: 360...720))
                    }
                }
                
                // Fade out near the end
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration * 0.7) {
                    withAnimation(.easeOut(duration: duration * 0.3)) {
                        if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                            confettiPieces[index].opacity = 0
                        }
                    }
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var position: CGPoint
    let size: CGFloat
    var rotation: Angle
    var opacity: Double
}

// MARK: - Draggable Planet with slow rotation
struct DraggablePlanetView: View {
    let planet: Planet
    let screenSize: CGSize
    let onDrop: (Int?) -> Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var rotation: Double = 0
    @State private var startLocation: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(planet.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-rotation))
                .offset(dragOffset)
                .shadow(radius: isDragging ? 15 : 5)
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .zIndex(isDragging ? 100 : 10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 12)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }
                }
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            if !isDragging {
                                startLocation = value.startLocation
                                isDragging = true
                                
                                // Light haptic on drag start
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            isDragging = false
                            
                            let dropPoint = CGPoint(
                                x: value.location.x,
                                y: value.location.y
                            )
                            
                            let droppedOrbit = findClosestOrbit(at: dropPoint)
                            let success = onDrop(droppedOrbit)
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragOffset = .zero
                            }
                        }
                )
        }
    }
    
    private func findClosestOrbit(at dropLocation: CGPoint) -> Int? {
        let xs: [CGFloat] = [
            screenSize.width * 0.25,
            screenSize.width * 0.32,
            screenSize.width * 0.40,
            screenSize.width * 0.47,
            screenSize.width * 0.56,
            screenSize.width * 0.63,
            screenSize.width * 0.70,
            screenSize.width * 0.79
        ]
        let y = screenSize.height / 2
        
        var closestOrbit: Int?
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        
        for i in 0..<8 {
            let orbitPoint = CGPoint(x: xs[i], y: y)
            let d = hypot(dropLocation.x - orbitPoint.x, dropLocation.y - orbitPoint.y)
            if d < closestDistance && d < 80 {
                closestDistance = d
                closestOrbit = i + 1
            }
        }
        
        return closestOrbit
    }
}

#Preview {
    Planetgame()
}
