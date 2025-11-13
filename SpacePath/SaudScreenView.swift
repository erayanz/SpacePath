import SwiftUI

struct AnimatedDarkBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Image("main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Image("main2")
                .resizable()
                .scaledToFill()
                .opacity(0.35)
                .offset(y: animate ? 50 : -100)
                .animation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }
                .ignoresSafeArea()
        }
    }
}

struct AnimatedBlueStarsBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Image("main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.19)
                .ignoresSafeArea()

            Image("main2")
                .resizable()
                .scaledToFill()
                .opacity(0.25)
                .offset(y: animate ? 50 : -100)
                .animation(Animation.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }
                .ignoresSafeArea()
        }
    }
}

// MARK: - Planet Row (Home)
struct VerticalPlanetRow: View {
    var planetName: String
    @State private var rotation = 0.0
    @State private var bob: CGFloat = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        let size: CGFloat = planetName == "الشمس" ? 450 : 150

        Image(planetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .offset(y: bob)
            .scaleEffect(scale)
            .shadow(color: .white.opacity(0.25), radius: 12)
            .onAppear {
                withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    bob = -12
                }
                withAnimation(Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    scale = 1.03
                }
            }
            .padding(.vertical, 1)
    }
}

// MARK: - Home View
struct HomeView: View {
    let planets = ["الشمس", "عطارد", "الزهرة", "الأرض", "المريخ", "المشتري", "زحل", "أورانوس", "نبتون"]

    var body: some View {
        ZStack {
            AnimatedDarkBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("المجموعة الشمسية")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 20)

                Spacer(minLength: 29)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        ForEach(planets, id: \.self) { planet in
                            NavigationLink(destination: SimplePlanetView(planetName: planet)) {
                                VerticalPlanetRow(planetName: planet)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                }

                Spacer(minLength: 1)
            }
        }
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Simple Planet Detail Page
struct SimplePlanetView: View {
    let allPlanets = ["الشمس", "عطارد", "الزهرة", "الأرض", "المريخ", "المشتري", "زحل", "أورانوس", "نبتون"]

    @State var planetName: String
    @State private var rotation = 0.0
    @State private var scale: CGFloat = 1.0

    var planetInfo: String {
        switch planetName {
        case "الشمس":
            return "الشمس هي النجم المركزي لنظامنا الشمسي، وتوفر الضوء والحرارة الضروريين للحياة. تشكل أكثر من 99٪ من كتلة النظام الشمسي."
        case "عطارد":
            return "عطارد هو أصغر كواكب المجموعة الشمسية وأقربها إلى الشمس، ويدور بسرعة كبيرة لدرجة أن السنة فيه تعادل 88 يومًا فقط من أيام الأرض! يتميز باختلاف حرارته الجنوني بين الليل والنهار، ويدرسه العلماء لفهم بدايات تكوّن الكواكب."
        case "الزهرة":
            return "الزهرة هو ثاني أقرب كوكب إلى الشمس، ويُعرف بأنه الأكثر حرارة بسبب غلافه الجوي الكثيف الذي يحتبس الحرارة مثل بيت زجاجي عملاق!"
        case "الأرض":
            return "الأرض هو كوكبنا الجميل، الوحيد المعروف بوجود الحياة والمياه السائلة. يمتلك غلافًا جويًا يحمي الحياة ويحافظ على مناخ معتدل."
        case "المريخ":
            return "المريخ هو الكوكب الأحمر ويُعتقد أنه كان يملك أنهارًا قديمة، وقد يكون صالحًا للسكن مستقبلًا!"
        case "المشتري":
            return "المشتري هو أكبر كوكب، عملاق غازي بعاصفة ضخمة أكبر من الأرض، ولديه أكثر من 70 قمرًا."
        case "زحل":
            return "زحل هو الكوكب ذو الحلقات الجميلة المصنوعة من الجليد والغبار، ويعتبر من أجمل مشاهد السماء."
        case "أورانوس":
            return "أورانوس يميل على جانبه أثناء دورانه، وفصوله طويلة جدًا، ويتميز بلونه الأزرق بسبب غاز الميثان."
        case "نبتون":
            return "نبتون أبعد كوكب عن الشمس، لونه أزرق عميق ورياحه تعد الأقوى في النظام الشمسي."
        default:
            return ""
        }
    }

    var body: some View {
        ZStack {
            AnimatedBlueStarsBackground()

            VStack(spacing: 1) {
                Spacer(minLength: 12)

                Image(planetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: planetName == "الشمس" ? 250 : 280,
                        height: planetName == "الشمس" ? 250 : 280
                    )
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .shadow(color: .white.opacity(0.35), radius: 18)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            scale = 1.08
                        }
                    }

                Text(planetName)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)

                Text(planetInfo)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()

                // Liquid Glass Chevron Buttons
                HStack(spacing: 80) {
                    // Right Button
                    Button(action: previousPlanet) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .shadow(color: .white.opacity(0.2), radius: 8, x: -2, y: -2)
                                .shadow(color: .black.opacity(0.4), radius: 10, x: 3, y: 3)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)

                    // Left Button
                    Button(action: nextPlanet) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .shadow(color: .white.opacity(0.2), radius: 8, x: -2, y: -2)
                                .shadow(color: .black.opacity(0.4), radius: 10, x: 3, y: 3)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 40)

                // AR Exploration Button
                NavigationLink(destination: ARmap()) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.5), .purple.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 4)
                            .shadow(color: .white.opacity(0.2), radius: 8, x: -2, y: -2)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.5), radius: 4)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationTitle(planetName)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }

    var planetIndex: Int {
        allPlanets.firstIndex(of: planetName) ?? 0
    }

    func nextPlanet() {
        let next = (planetIndex + 1) % allPlanets.count
        planetName = allPlanets[next]
    }

    func previousPlanet() {
        let prev = (planetIndex - 1 + allPlanets.count) % allPlanets.count
        planetName = allPlanets[prev]
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
