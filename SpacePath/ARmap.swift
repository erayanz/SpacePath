import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Configuration
struct SolarSystemConfig {
    var showLabels: Bool = true
    var showOrbits: Bool = false
    var animationSpeed: Float = 1.0
    var planetScale: Float = 1.0
    var showStars: Bool = true
}

// MARK: - Planet Data Model
struct PlanetData {
    let radius: Float
    let textureName: String
    let orbitRadius: Float
    let rotationDuration: TimeInterval
    let orbitDuration: TimeInterval
    let labelOffset: Float
    let arabicName: String
    let color: UIColor
}

// MARK: - Solar System Data
struct SolarSystemData {
    static let planets: [(key: String, value: PlanetData)] = [
        ("mercury", PlanetData(
            radius: 0.02,
            textureName: "8k_mercury",
            orbitRadius: 0.25,
            rotationDuration: 4,
            orbitDuration: 15,
            labelOffset: -0.05,
            arabicName: "عطارد",
            color: .gray
        )),
        ("venus", PlanetData(
            radius: 0.04,
            textureName: "8k_venus_surface",
            orbitRadius: 0.4,
            rotationDuration: 6,
            orbitDuration: 20,
            labelOffset: -0.07,
            arabicName: "الزهرة",
            color: .orange
        )),
        ("earth", PlanetData(
            radius: 0.05,
            textureName: "8k_earth_daymap",
            orbitRadius: 0.6,
            rotationDuration: 8,
            orbitDuration: 25,
            labelOffset: -0.08,
            arabicName: "الأرض",
            color: .blue
        )),
        ("mars", PlanetData(
            radius: 0.035,
            textureName: "8k_mars",
            orbitRadius: 0.85,
            rotationDuration: 10,
            orbitDuration: 35,
            labelOffset: -0.06,
            arabicName: "المريخ",
            color: .red
        )),
        ("jupiter", PlanetData(
            radius: 0.1,
            textureName: "8k_jupiter",
            orbitRadius: 1.15,
            rotationDuration: 14,
            orbitDuration: 50,
            labelOffset: -0.13,
            arabicName: "المشتري",
            color: .brown
        )),
        ("saturn", PlanetData(
            radius: 0.08,
            textureName: "8k_saturn",
            orbitRadius: 1.5,
            rotationDuration: 18,
            orbitDuration: 65,
            labelOffset: -0.11,
            arabicName: "زحل",
            color: .orange
        )),
        ("uranus", PlanetData(
            radius: 0.06,
            textureName: "2k_uranus",
            orbitRadius: 1.85,
            rotationDuration: 22,
            orbitDuration: 80,
            labelOffset: -0.09,
            arabicName: "أورانوس",
            color: .cyan
        )),
        ("neptune", PlanetData(
            radius: 0.055,
            textureName: "2k_neptune",
            orbitRadius: 2.15,
            rotationDuration: 26,
            orbitDuration: 95,
            labelOffset: -0.08,
            arabicName: "نبتون",
            color: .blue
        ))
    ]
}

// MARK: - Animation Type
enum AnimationType {
    case rotation
    case orbit(Float)
}

// MARK: - Errors
enum TextureError: Error {
    case loadFailed
}

// MARK: - Main AR View
struct ARmap: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var showInitialHint = true
    
    var body: some View {
        ZStack {
            if arViewModel.isARSupported {
                // AR View
                EnhancedARViewContainer(viewModel: arViewModel)
                    .ignoresSafeArea()
                
                // Initial Hint Overlay
                if showInitialHint && arViewModel.placementMode {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showInitialHint = false
                                }
                            }
                        
                        VStack(spacing: 20) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)
                            
                            Text("انقر في أي مكان في الشاشة لعرض النظام الشمسي")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding()
                    }
                    .transition(.opacity)
                    .onAppear {
                        // Auto-hide after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showInitialHint = false
                            }
                        }
                    }
                }
                
                // Loading Indicator
                if arViewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("جاري تحميل النظام الشمسي...")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
                }
                
                // Overlay UI
                VStack {
                    // Title and Controls
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("خريطة الكواكب التفاعلية")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(arViewModel.placementMode ? "اضغط على السطح لوضع النظام الشمسي" : "")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Orbit Toggle
                        Button {
                            arViewModel.toggleOrbits()
                        } label: {
                            Image(systemName: arViewModel.config.showOrbits ? "circle.dotted" : "circle")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Speed Control
                    if !arViewModel.placementMode {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "tortoise.fill")
                                    .foregroundStyle(.white)
                                Slider(value: $arViewModel.timeScale, in: 0.1...10.0)
                                    .tint(.blue)
                                Image(systemName: "hare.fill")
                                    .foregroundStyle(.white)
                            }
                            
                            Text("سرعة الحركة: \(String(format: "%.1f", arViewModel.timeScale))×")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                    
                    // Instructions
                    if arViewModel.placementMode && !showInitialHint {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.title3)
                                Text("اضغط على الكوكب لمعرفة المزيد")
                                    .font(.subheadline)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.left.and.right")
                                    .font(.title3)
                                Text("حرك جهازك لاستكشاف الفضاء")
                                    .font(.subheadline)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "pinch")
                                    .font(.title3)
                                Text("قرّب بإصبعين للتكبير")
                                    .font(.subheadline)
                            }
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                    }
                }
            } else {
                // Fallback for simulator or unsupported devices
                ARNotSupportedView()
            }
        }
        .sheet(isPresented: $arViewModel.showPlanetInfo) {
            if let info = arViewModel.selectedPlanetInfo {
                PlanetDetailView(planet: info, isPresented: $arViewModel.showPlanetInfo)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - ViewModel
class ARViewModel: ObservableObject {
    @Published var isARSupported = ARWorldTrackingConfiguration.isSupported
    @Published var selectedPlanetInfo: PlanetInfo?
    @Published var showPlanetInfo = false
    @Published var timeScale: Float = 1.0
    @Published var placementMode = true
    @Published var isLoading = false
    @Published var config = SolarSystemConfig()
    
    var solarSystemAnchor: AnchorEntity?
    
    func toggleOrbits() {
        config.showOrbits.toggle()
    }
    
    func getPlanetInfo(for planetName: String) -> PlanetInfo {
        switch planetName {
        case "sun":
            return PlanetInfo(
                name: "Sun",
                arabicName: "الشمس",
                description: "الشمس هي نجم النظام الشمسي، وهي مصدر الضوء والحرارة للكواكب",
                distance: "0 كم (المركز)",
                diameter: "1,391,000 كم",
                facts: [
                    "تحتوي على 99.86% من كتلة النظام الشمسي",
                    "درجة حرارة السطح: 5,500 درجة مئوية",
                    "عمرها: 4.6 مليار سنة"
                ],
                color: .yellow
            )
        case "mercury":
            return PlanetInfo(
                name: "Mercury",
                arabicName: "عطارد",
                description: "أصغر كوكب وأقربهم إلى الشمس",
                distance: "57.9 مليون كم من الشمس",
                diameter: "4,879 كم",
                facts: [
                    "يوم واحد على عطارد = 59 يوم أرضي",
                    "سنة واحدة = 88 يوم أرضي",
                    "ليس له أقمار"
                ],
                color: .gray
            )
        case "venus":
            return PlanetInfo(
                name: "Venus",
                arabicName: "الزهرة",
                description: "أسخن كوكب في النظام الشمسي",
                distance: "108.2 مليون كم من الشمس",
                diameter: "12,104 كم",
                facts: [
                    "درجة الحرارة: 465 درجة مئوية",
                    "يدور عكس اتجاه معظم الكواكب",
                    "ألمع كوكب في السماء"
                ],
                color: .orange
            )
        case "earth":
            return PlanetInfo(
                name: "Earth",
                arabicName: "الأرض",
                description: "كوكبنا الأزرق، الكوكب الوحيد المعروف بوجود حياة",
                distance: "149.6 مليون كم من الشمس",
                diameter: "12,742 كم",
                facts: [
                    "70% من سطحها مغطى بالماء",
                    "له قمر طبيعي واحد",
                    "يدور حول نفسه كل 24 ساعة"
                ],
                color: .blue
            )
        case "mars":
            return PlanetInfo(
                name: "Mars",
                arabicName: "المريخ",
                description: "الكوكب الأحمر، هدف الاستكشاف البشري القادم",
                distance: "227.9 مليون كم من الشمس",
                diameter: "6,779 كم",
                facts: [
                    "له قمران: فوبوس وديموس",
                    "يحتوي على أكبر بركان في النظام الشمسي",
                    "اليوم = 24.6 ساعة"
                ],
                color: .red
            )
        case "jupiter":
            return PlanetInfo(
                name: "Jupiter",
                arabicName: "المشتري",
                description: "أكبر كوكب في النظام الشمسي",
                distance: "778.5 مليون كم من الشمس",
                diameter: "139,820 كم",
                facts: [
                    "له 79 قمراً معروفاً",
                    "البقعة الحمراء العظيمة: عاصفة عملاقة",
                    "كتلته أكبر من كل الكواكب مجتمعة"
                ],
                color: .brown
            )
        case "saturn":
            return PlanetInfo(
                name: "Saturn",
                arabicName: "زحل",
                description: "كوكب الحلقات الجميلة",
                distance: "1.43 مليار كم من الشمس",
                diameter: "116,460 كم",
                facts: [
                    "له 82 قمراً معروفاً",
                    "حلقاته مكونة من جليد وصخور",
                    "كثافته أقل من الماء"
                ],
                color: .orange
            )
        case "uranus":
            return PlanetInfo(
                name: "Uranus",
                arabicName: "أورانوس",
                description: "الكوكب المائل، يدور على جانبه",
                distance: "2.87 مليار كم من الشمس",
                diameter: "50,724 كم",
                facts: [
                    "يدور على جانبه بزاوية 98 درجة",
                    "له 27 قمراً معروفاً",
                    "لونه أزرق بسبب الميثان"
                ],
                color: .cyan
            )
        case "neptune":
            return PlanetInfo(
                name: "Neptune",
                arabicName: "نبتون",
                description: "أبعد كوكب عن الشمس",
                distance: "4.50 مليار كم من الشمس",
                diameter: "49,244 كم",
                facts: [
                    "له 14 قمراً معروفاً",
                    "رياحه الأسرع في النظام الشمسي",
                    "السنة = 165 سنة أرضية"
                ],
                color: .blue
            )
        default:
            return PlanetInfo(
                name: "Unknown",
                arabicName: "غير معروف",
                description: "",
                distance: "",
                diameter: "",
                facts: [],
                color: .white
            )
        }
    }
}

// MARK: - Planet Info Model
struct PlanetInfo: Identifiable {
    let id = UUID()
    let name: String
    let arabicName: String
    let description: String
    let distance: String
    let diameter: String
    let facts: [String]
    let color: Color
}

// MARK: - Planet Detail View with 3D Model
struct PlanetDetailView: View {
    let planet: PlanetInfo
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 3D Planet Model (Interactive)
                        Planet3DView(planetName: planet.name.lowercased())
                            .frame(height: 300)
                            .padding(.top, 30)
                        
                        // Planet Name
                        VStack(spacing: 8) {
                            Text(planet.arabicName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(planet.name)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("الوصف")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            Text(planet.description)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // Distance and Diameter
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.left.and.right")
                                    .font(.title2)
                                    .foregroundStyle(planet.color)
                                Text("المسافة")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text(planet.distance)
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "circle.dashed")
                                    .font(.title2)
                                    .foregroundStyle(planet.color)
                                Text("القطر")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text(planet.diameter)
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Facts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("حقائق مثيرة")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            ForEach(planet.facts, id: \.self) { fact in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(planet.color)
                                        .padding(.top, 4)
                                    
                                    Text(fact)
                                        .font(.body)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // Interaction Hint
                        HStack(spacing: 8) {
                            Image(systemName: "hand.draw.fill")
                                .font(.caption)
                            Text("اسحب لتدوير الكوكب")
                                .font(.caption)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - 3D Planet View
struct Planet3DView: UIViewRepresentable {
    let planetName: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR)
        arView.environment.background = .color(.clear)
        
        let anchor = AnchorEntity()
        let planet = createPlanet(for: planetName)
        anchor.addChild(planet)
        
        // Add lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 5000
        directionalLight.light.color = .white
        directionalLight.position = [2, 2, 2]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)
        anchor.addChild(directionalLight)
        
        let ambientLight = PointLight()
        ambientLight.light.intensity = 3000
        ambientLight.light.color = .white
        ambientLight.position = [0, 0, 0]
        anchor.addChild(ambientLight)
        
        arView.scene.addAnchor(anchor)
        
        // Better camera positioning based on planet
        let cameraDistance: Float = (planetName == "jupiter" || planetName == "saturn") ? 0.4 : 0.35
        let cameraAnchor = AnchorEntity(world: [0, 0, cameraDistance])
        arView.scene.addAnchor(cameraAnchor)
        
        context.coordinator.startRotation(for: planet)
        
        // Add gestures
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        context.coordinator.planet = planet
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func createPlanet(for name: String) -> ModelEntity {
        let radius: Float = 0.25
        let mesh = MeshResource.generateSphere(radius: radius)
        var material = SimpleMaterial()
        
        let textureName = getTextureName(for: name)
        
        if let texture = try? TextureResource.load(named: textureName) {
            material.color = .init(tint: .white, texture: .init(texture))
            material.roughness = .init(floatLiteral: 0.5)
            material.metallic = .init(floatLiteral: 0.1)
        } else {
            let color = getFallbackColor(for: name)
            material.color = .init(tint: color)
            material.roughness = .init(floatLiteral: 0.7)
        }
        
        let planet = ModelEntity(mesh: mesh, materials: [material])
        planet.position = [0, 0, 0]
        
        if name == "saturn" {
            addSaturnRing(to: planet)
        } else if name == "sun" {
            let pointLight = PointLight()
            pointLight.light.intensity = 8000
            pointLight.light.color = .yellow
            planet.addChild(pointLight)
        }
        
        return planet
    }
    
    func addSaturnRing(to planet: ModelEntity) {
        let ringMesh = MeshResource.generatePlane(width: 0.6, depth: 0.6)
        var ringMaterial = SimpleMaterial()
        
        if let ringTexture = try? TextureResource.load(named: "8k_saturn_ring_alpha") {
            ringMaterial.color = .init(tint: .white.withAlphaComponent(0.9), texture: .init(ringTexture))
        } else {
            ringMaterial.color = .init(tint: UIColor.orange.withAlphaComponent(0.6))
        }
        
        let ring = ModelEntity(mesh: ringMesh, materials: [ringMaterial])
        ring.position = [0, 0, 0]
        ring.orientation = simd_quatf(angle: .pi / 2.5, axis: [1, 0, 0.2])
        
        planet.addChild(ring)
    }
    
    func getTextureName(for planetName: String) -> String {
        switch planetName {
        case "sun": return "8k_sun"
        case "mercury": return "8k_mercury"
        case "venus": return "8k_venus_surface"
        case "earth": return "8k_earth_daymap"
        case "mars": return "8k_mars"
        case "jupiter": return "8k_jupiter"
        case "saturn": return "8k_saturn"
        case "uranus": return "2k_uranus"
        case "neptune": return "2k_neptune"
        default: return ""
        }
    }
    
    func getFallbackColor(for planetName: String) -> UIColor {
        switch planetName {
        case "sun": return .yellow
        case "mercury": return .gray
        case "venus": return .orange
        case "earth": return .blue
        case "mars": return .red
        case "jupiter": return .brown
        case "saturn": return .orange
        case "uranus": return .cyan
        case "neptune": return .blue
        default: return .white
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        var planet: ModelEntity?
        var arView: ARView?
        var rotationTimer: Timer?
        var lastRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
        var currentScale: Float = 1.0
        var isUserInteracting = false
        
        func startRotation(for planet: ModelEntity) {
            rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
                guard let self = self, !self.isUserInteracting else { return }
                
                let rotation = simd_quatf(angle: 0.01, axis: [0, 1, 0])
                planet.transform.rotation = rotation * planet.transform.rotation
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let planet = planet else { return }
            
            let translation = gesture.translation(in: gesture.view)
            
            switch gesture.state {
            case .began:
                isUserInteracting = true
            case .changed:
                let rotationX = Float(translation.y) * 0.01
                let rotationY = Float(translation.x) * 0.01
                
                let quatX = simd_quatf(angle: rotationX, axis: [1, 0, 0])
                let quatY = simd_quatf(angle: rotationY, axis: [0, 1, 0])
                
                planet.transform.rotation = quatY * quatX * lastRotation
            case .ended, .cancelled:
                lastRotation = planet.transform.rotation
                isUserInteracting = false
            default:
                break
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let planet = planet else { return }
            
            switch gesture.state {
            case .changed:
                let scale = Float(gesture.scale)
                currentScale *= scale
                currentScale = max(0.5, min(currentScale, 2.0))
                planet.scale = [currentScale, currentScale, currentScale]
                gesture.scale = 1.0
            default:
                break
            }
        }
        
        deinit {
            rotationTimer?.invalidate()
        }
    }
}

// MARK: - Fallback view
struct ARNotSupportedView: View {
    var body: some View {
        ZStack {
            Image("First")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "arkit")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                
                Text("الواقع المعزز غير متاح")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("يتطلب الواقع المعزز جهاز iPhone 6s أو أحدث")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("الرجاء تشغيل التطبيق على جهاز حقيقي وليس المحاكي")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding()
        }
    }
}

// MARK: - Enhanced ARView Container
struct EnhancedARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        context.coordinator.arView = arView
        context.coordinator.viewModel = viewModel
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.updateTimeScale(viewModel.timeScale)
        context.coordinator.updateOrbitsVisibility(viewModel.config.showOrbits)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        weak var arView: ARView?
        var viewModel: ARViewModel
        var solarSystemAnchor: AnchorEntity?
        var planetEntities: [String: ModelEntity] = [:]
        var orbitEntities: [String: ModelEntity] = [:]
        var planetTimers: [String: Timer] = [:]
        var orbitTimers: [String: Timer] = [:]
        var currentScale: Float = 1.0
        
        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = gesture.location(in: arView)
            
            if viewModel.placementMode {
                if let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                    let position = raycastResult.worldTransform.columns.3
                    placeSolarSystem(at: SIMD3<Float>(position.x, position.y, position.z))
                    viewModel.placementMode = false
                }
            } else {
                if let entity = arView.entity(at: location) as? ModelEntity {
                    handlePlanetTap(entity)
                }
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let anchor = solarSystemAnchor else { return }
            
            if gesture.state == .changed {
                let scale = Float(gesture.scale)
                currentScale *= scale
                currentScale = max(0.5, min(currentScale, 3.0))
                anchor.scale = [currentScale, currentScale, currentScale]
                gesture.scale = 1.0
            }
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let anchor = solarSystemAnchor else { return }
            
            if gesture.state == .changed {
                let rotation = Float(gesture.rotation)
                anchor.orientation *= simd_quatf(angle: rotation, axis: [0, 1, 0])
                gesture.rotation = 0
            }
        }
        
        func placeSolarSystem(at position: SIMD3<Float>) {
            guard let arView = arView else { return }
            
            DispatchQueue.main.async {
                self.viewModel.isLoading = true
            }
            
            solarSystemAnchor?.removeFromParent()
            
            let anchor = AnchorEntity(world: [position.x, position.y, position.z])
            solarSystemAnchor = anchor
            
            createSolarSystem(in: anchor)
            
            arView.scene.addAnchor(anchor)
            
            DispatchQueue.main.async {
                self.viewModel.isLoading = false
            }
        }
        
        func createSolarSystem(in anchor: AnchorEntity) {
            if viewModel.config.showStars {
                addStarField(to: anchor)
            }
            
            // Sun
            let sun = createPlanetWithTexture(
                radius: 0.15,
                textureName: "8k_sun",
                position: [0, 0, 0],
                isGlowing: true,
                planetName: "sun"
            )
            anchor.addChild(sun)
            planetEntities["sun"] = sun
            
            let sunLight = PointLight()
            sunLight.light.intensity = 10000
            sunLight.light.color = .yellow
            sun.addChild(sunLight)
            
            // Create all planets
            for (planetKey, planetData) in SolarSystemData.planets {
                let planet = createPlanetWithTexture(
                    radius: planetData.radius,
                    textureName: planetData.textureName,
                    position: [planetData.orbitRadius, 0, 0],
                    isGlowing: false,
                    planetName: planetKey
                )
                
                anchor.addChild(planet)
                planetEntities[planetKey] = planet
                
                // Add orbital path ONLY if enabled
                if viewModel.config.showOrbits {
                    let orbit = createOrbitPath(radius: planetData.orbitRadius, color: planetData.color)
                    anchor.addChild(orbit)
                    orbitEntities[planetKey] = orbit
                }
                
                // Add animations
                addAnimation(to: planet, type: .rotation, duration: planetData.rotationDuration, planetName: planetKey)
                addAnimation(to: planet, type: .orbit(planetData.orbitRadius), duration: planetData.orbitDuration, planetName: planetKey)
                
                // Add labels ONLY if enabled
                if viewModel.config.showLabels {
                    addLabel(to: planet, text: planetData.arabicName, offset: planetData.labelOffset)
                }
                
                // Special case: Earth's moon
                if planetKey == "earth" {
                    let moon = createPlanetWithTexture(
                        radius: 0.013,
                        textureName: "8k_moon",
                        position: [0.09, 0, 0],
                        planetName: "moon"
                    )
                    planet.addChild(moon)
                    addAnimation(to: moon, type: .orbit(0.09), duration: 5, planetName: "moon")
                    
                    // Add label for moon
                    if viewModel.config.showLabels {
                        addLabel(to: moon, text: "القمر", offset: -0.025)
                    }
                }
                
                // Special case: Saturn's rings
                if planetKey == "saturn" {
                    let saturnRing = createSaturnRingWithTexture(position: [0, 0, 0])
                    planet.addChild(saturnRing)
                }
            }
        }
        
        func createOrbitPath(radius: Float, color: UIColor) -> ModelEntity {
            let segments = 64
            let tubeRadius: Float = 0.004
            
            var positions: [SIMD3<Float>] = []
            var normals: [SIMD3<Float>] = []
            var indices: [UInt32] = []
            
            let tubeSegments = 4
            for i in 0...segments {
                let angle = Float(i) * (2.0 * .pi / Float(segments))
                let circleX = cos(angle) * radius
                let circleZ = sin(angle) * radius
                
                for j in 0..<tubeSegments {
                    let tubeAngle = Float(j) * (2.0 * .pi / Float(tubeSegments))
                    let dx = cos(tubeAngle) * tubeRadius
                    let dy = sin(tubeAngle) * tubeRadius
                    
                    let x = circleX + dx * cos(angle)
                    let y = dy
                    let z = circleZ + dx * sin(angle)
                    
                    positions.append([x, y + 0.001, z])
                    normals.append(normalize([dx * cos(angle), dy, dx * sin(angle)]))
                }
            }
            
            for i in 0..<segments {
                let base = UInt32(i * tubeSegments)
                let nextBase = UInt32((i + 1) * tubeSegments)
                
                for j in 0..<tubeSegments {
                    let j1 = UInt32(j)
                    let j2 = UInt32((j + 1) % tubeSegments)
                    
                    indices.append(base + j1)
                    indices.append(nextBase + j1)
                    indices.append(base + j2)
                    
                    indices.append(base + j2)
                    indices.append(nextBase + j1)
                    indices.append(nextBase + j2)
                }
            }
            
            var descriptor = MeshDescriptor()
            descriptor.positions = MeshBuffer(positions)
            descriptor.normals = MeshBuffer(normals)
            descriptor.primitives = .triangles(indices)
            
            do {
                let mesh = try MeshResource.generate(from: [descriptor])
                var material = UnlitMaterial()
                material.color = .init(tint: color.withAlphaComponent(0.25))
                
                let orbit = ModelEntity(mesh: mesh, materials: [material])
                return orbit
            } catch {
                print("❌ Failed to create orbit: \(error)")
                return ModelEntity()
            }
        }
        
        func createPlanetWithTexture(radius: Float, textureName: String, position: SIMD3<Float>, isGlowing: Bool = false, planetName: String) -> ModelEntity {
            let mesh = MeshResource.generateSphere(radius: radius)
            var material = SimpleMaterial()
            
            do {
                if let texture = try? TextureResource.load(named: textureName) {
                    material.color = .init(tint: .white.withAlphaComponent(1.0), texture: .init(texture))
                    material.roughness = .init(floatLiteral: isGlowing ? 0.0 : 0.7)
                    material.metallic = .init(floatLiteral: isGlowing ? 0.5 : 0.1)
                    print("✅ Loaded texture: \(textureName)")
                } else {
                    throw TextureError.loadFailed
                }
            } catch {
                print("⚠️ Failed to load texture: \(textureName), using fallback")
                let fallbackColor = getFallbackColor(for: textureName)
                material.color = .init(tint: fallbackColor)
                material.roughness = .init(floatLiteral: 0.8)
            }
            
            let planet = ModelEntity(mesh: mesh, materials: [material])
            planet.position = position
            planet.generateCollisionShapes(recursive: false)
            planet.name = planetName
            planet.accessibilityLabel = getAccessibilityLabel(for: planetName)
            
            return planet
        }
        
        func createSaturnRingWithTexture(position: SIMD3<Float>) -> ModelEntity {
            let mesh = MeshResource.generatePlane(width: 0.25, depth: 0.25)
            var material = SimpleMaterial()
            
            if let ringTexture = try? TextureResource.load(named: "8k_saturn_ring_alpha") {
                material.color = .init(tint: .white.withAlphaComponent(0.9), texture: .init(ringTexture))
            } else {
                material.color = .init(tint: UIColor.orange.withAlphaComponent(0.5))
            }
            
            let ring = ModelEntity(mesh: mesh, materials: [material])
            ring.position = position
            ring.orientation = simd_quatf(angle: .pi / 2.5, axis: [1, 0, 0.2])
            
            return ring
        }
        
        func addLabel(to planet: ModelEntity, text: String, offset: Float) {
            let textMesh = MeshResource.generateText(
                text,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.03),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            
            var material = SimpleMaterial()
            material.color = .init(tint: .white)
            
            let textEntity = ModelEntity(mesh: textMesh, materials: [material])
            textEntity.position = [0, offset, 0]
            
            planet.addChild(textEntity)
        }
        
        func addStarField(to anchor: AnchorEntity) {
            let starMesh = MeshResource.generateSphere(radius: 0.002)
            let starMaterial = SimpleMaterial(color: .white, isMetallic: false)
            
            for _ in 0..<50 {
                let star = ModelEntity(mesh: starMesh, materials: [starMaterial])
                star.position = [
                    Float.random(in: -4...4),
                    Float.random(in: -2...2),
                    Float.random(in: -4...4)
                ]
                anchor.addChild(star)
            }
        }
        
        func addAnimation(to entity: ModelEntity, type: AnimationType, duration: TimeInterval, planetName: String) {
            var angle: Float = 0
            let speed = Float(2.0 * .pi / duration)
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
                guard let self = self, entity.parent != nil else {
                    timer.invalidate()
                    return
                }
                
                angle += speed * 0.016 * self.viewModel.timeScale
                
                switch type {
                case .rotation:
                    entity.transform.rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                case .orbit(let orbitRadius):
                    let x = cos(angle) * orbitRadius
                    let z = sin(angle) * orbitRadius
                    entity.position = [x, 0, z]
                }
            }
            
            switch type {
            case .rotation:
                planetTimers[planetName + "_rotation"] = timer
            case .orbit:
                orbitTimers[planetName + "_orbit"] = timer
            }
        }
        
        func getFallbackColor(for textureName: String) -> UIColor {
            switch textureName {
            case "8k_sun": return .yellow
            case "8k_mercury": return .gray
            case "8k_venus_surface": return .orange
            case "8k_earth_daymap": return .blue
            case "8k_mars": return .red
            case "8k_jupiter": return .brown
            case "8k_saturn": return .orange
            case "2k_uranus": return .cyan
            case "2k_neptune": return .blue
            default: return .white
            }
        }
        
        func getAccessibilityLabel(for planetName: String) -> String {
            let data = SolarSystemData.planets.first { $0.key == planetName }
            return data?.value.arabicName ?? planetName
        }
        
        func handlePlanetTap(_ entity: ModelEntity) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            print("📊 User viewed planet: \(entity.name)")
            
            let originalScale = entity.transform.scale
            var enlargedTransform = entity.transform
            enlargedTransform.scale = SIMD3<Float>(
                originalScale.x * 1.3,
                originalScale.y * 1.3,
                originalScale.z * 1.3
            )
            
            entity.move(to: enlargedTransform, relativeTo: entity.parent, duration: 0.15)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                var normalTransform = entity.transform
                normalTransform.scale = originalScale
                entity.move(to: normalTransform, relativeTo: entity.parent, duration: 0.15)
            }
            
            let planetName = entity.name
            if !planetName.isEmpty {
                DispatchQueue.main.async {
                    self.viewModel.selectedPlanetInfo = self.viewModel.getPlanetInfo(for: planetName)
                    self.viewModel.showPlanetInfo = true
                }
            }
        }
        
        func updateTimeScale(_ newScale: Float) {
            // Time scale is used directly in animations
        }
        
        func updateOrbitsVisibility(_ show: Bool) {
            orbitEntities.values.forEach { orbit in
                orbit.isEnabled = show
            }
        }
        
        func cleanup() {
            planetTimers.values.forEach { $0.invalidate() }
            orbitTimers.values.forEach { $0.invalidate() }
            planetTimers.removeAll()
            orbitTimers.removeAll()
            solarSystemAnchor?.removeFromParent()
        }
        
        deinit {
            cleanup()
        }
    }
}

// MARK: - Preview
#Preview {
    ARmap()
}
