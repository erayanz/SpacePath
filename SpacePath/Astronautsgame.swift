import SwiftUI

// MARK: - Models
struct Question: Identifiable {
    let id = UUID()
    let correctAstronaut: String
    let correctImageName: String
    let question: String
    let explanation: String
    let fixedOrder: [AstronautOption]
}

struct AstronautOption: Identifiable {
    let id: String
    let name: String
    let imageName: String
}

// MARK: - Game States
enum GameState {
    case title
    case info1
    case info2
    case info3
    case welcome
    case showingQuestion
    case gameOver
}

// MARK: - Main View
struct Astronautsgame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .title
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    
    @State private var selectedAstronaut: String? = nil
    @State private var showFeedback = false
    @State private var showExplanation = false
    @State private var questions: [Question] = []
    @State private var currentOptions: [AstronautOption] = []

    let allAstronauts = [
        AstronautOption(id: "prince", name: "الأمير سلطان بن سلمان", imageName: "prince"),
        AstronautOption(id: "rayyanah", name: "ريانة برناوي", imageName: "rayyanah"),
        AstronautOption(id: "ali", name: "علي القرني", imageName: "ali")
    ]

    var allQuestions: [Question] {
        [
            Question(correctAstronaut: "الأمير سلطان بن سلمان", correctImageName: "prince",
                     question: "من هو أول رائد فضاء سعودي وعربي ومسلم؟",
                     explanation: "الأمير سلطان بن سلمان كان أول رائد فضاء سعودي وعربي ومسلم عام 1985 على متن مكوك ديسكفري.",
                     fixedOrder: [allAstronauts[0], allAstronauts[1], allAstronauts[2]]),
            Question(correctAstronaut: "ريانة برناوي", correctImageName: "rayyanah",
                     question: "من هي الرائدة الذي أصبحت أول امرأة سعودية تصل إلى الفضاء؟",
                     explanation: "ريانة برناوي أصبحت أول امرأة سعودية في الفضاء في مايو 2023.",
                     fixedOrder: [allAstronauts[1], allAstronauts[0], allAstronauts[2]]),
            Question(correctAstronaut: "علي القرني", correctImageName: "ali",
                     question: "من هو الرائد الذي وصل إلى محطة الفضاء الدولية عام 2023؟",
                     explanation: "علي القرني رائد فضاء سعودي شارك في مهمة لمحطة الفضاء الدولية في 2023.",
                     fixedOrder: [allAstronauts[2], allAstronauts[0], allAstronauts[1]]),
            Question(correctAstronaut: "الأمير سلطان بن سلمان", correctImageName: "prince",
                     question: "من هو الرائد الذي سافر على متن مكوك ديسكفري عام 1985؟",
                     explanation: "الأمير سلطان بن سلمان شارك في مهمة STS-51-G على مكوك ديسكفري لمدة 7 أيام.",
                     fixedOrder: [allAstronauts[0], allAstronauts[1], allAstronauts[2]]),
            Question(correctAstronaut: "ريانة برناوي", correctImageName: "rayyanah",
                     question: "من هو الرائد الذي يعمل باحثاً في الخلايا السرطانية؟",
                     explanation: "ريانة برناوي متخصصة في أبحاث الخلايا السرطانية قبل مشاركتها في رحلة الفضاء.",
                     fixedOrder: [allAstronauts[1], allAstronauts[2], allAstronauts[0]]),
            Question(correctAstronaut: "علي القرني", correctImageName: "ali",
                     question: "من هو الرائد الذي كان طياراً مقاتلاً في القوات الجوية السعودية؟",
                     explanation: "علي القرني كان طيارًا مقاتلاً في القوات الجوية قبل انضمامه إلى برنامج رواد الفضاء.",
                     fixedOrder: [allAstronauts[2], allAstronauts[1], allAstronauts[0]]),
            Question(correctAstronaut: "الأمير سلطان بن سلمان", correctImageName: "prince",
                     question: "من هو الرائد الذي شارك في مهمة STS-51-G؟",
                     explanation: "الأمير سلطان بن سلمان شارك في مهمة STS-51-G على مكوك ديسكفري.",
                     fixedOrder: [allAstronauts[0], allAstronauts[1], allAstronauts[2]]),
            Question(correctAstronaut: "ريانة برناوي", correctImageName: "rayyanah",
                     question: "من هو الرائد الذي أجرى تجارب علمية في الفضاء عام 2023؟",
                     explanation: "ريانة برناوي أجرت تجارب علمية حول الخلايا السرطانية في رحلتها للفضاء.",
                     fixedOrder: [allAstronauts[1], allAstronauts[0], allAstronauts[2]]),
            Question(correctAstronaut: "علي القرني", correctImageName: "ali",
                     question: "من هو الرائد الذي انضم لمهمة محطة الفضاء الدولية؟",
                     explanation: "علي القرني انضم لمهمة محطة الفضاء الدولية في 2023.",
                     fixedOrder: [allAstronauts[2], allAstronauts[1], allAstronauts[0]]),
            Question(correctAstronaut: "الأمير سلطان بن سلمان", correctImageName: "prince",
                     question: "من هو الرائد الذي قضى 7 أيام في الفضاء عام 1985؟",
                     explanation: "الأمير سلطان بن سلمان قضى 7 أيام في الفضاء ضمن مهمة NASA.",
                     fixedOrder: [allAstronauts[0], allAstronauts[1], allAstronauts[2]])
        ]
    }

    var currentQuestion: Question { questions[currentQuestionIndex] }

    var body: some View {
        ZStack {
            // Background with gradient overlay
            Image("background_space")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [.black.opacity(0.3), .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            switch gameState {
            case .title:
                TitleView { gameState = .info1 }
                
            case .info1:
                AstronautInfoView(imageName: "prince",
                                  description: """
الأمير سلطان بن سلمان

في عام 1985 حقق الأمير سلطان بن سلمان بن عبدالعزيز إنجازًا غير مسبوق عندما أصبح أول رائد فضاء سعودي وعربي ومسلم يصل إلى الفضاء. انضم إلى طاقم مكوك الفضاء "ديسكفري" التابع لوكالة ناسا في المهمة STS-51-G، وقضى خلالها سبعة أيام في الفضاء. شارك الأمير في تشغيل الأقمار الصناعية ومتابعة الاتصالات، كما مثّل المملكة العربية السعودية عبر إطلاق قمر صناعي عربي من المركبة.
""") { gameState = .info2 }
                
            case .info2:
                AstronautInfoView(imageName: "rayyanah",
                                  description: """
ريانة برناوي

في مايو 2023 صنعت ريانة برناوي التاريخ عندما أصبحت أول امرأة سعودية تصل إلى الفضاء وإلى محطة الفضاء الدولية (ISS). ريانة متخصصة في أبحاث الخلايا السرطانية، وخلال الرحلة أجرت تجارب علمية لدراسة سلوك الخلايا السرطانية في بيئة منعدمة الجاذبية، بهدف تطوير أبحاث تساعد في التقدم الطبي. شكلت رحلتها حدثًا مهمًا للمملكة لأنها أبرزت دور المرأة السعودية في مجالات العلوم الحديثة والفضاء.
""") { gameState = .info3 }
                
            case .info3:
                AstronautInfoView(imageName: "ali",
                                  description: """
علي القرني

علي القرني هو رائد فضاء سعودي بدأ مسيرته كـ طيار مقاتل في القوات الجوية الملكية السعودية، حيث اكتسب خبرة كبيرة في الطيران والمهام الجوية. في عام 2023 شارك في مهمة علمية إلى محطة الفضاء الدولية ضمن برنامج رواد الفضاء السعوديين. خلال الرحلة، نفذ تجارب علمية وتعليمية تهدف إلى تطوير المعرفة في مجالات متعددة، بالإضافة إلى تواصله مع الطلاب لتحفيزهم على الاهتمام بالعلوم والتقنية.
""") { gameState = .welcome }
                
            case .welcome:
                WelcomeView(onStart: startGame)
                
            case .showingQuestion:
                QuestionView(
                    question: currentQuestion,
                    options: currentOptions,
                    selectedAstronaut: $selectedAstronaut,
                    showFeedback: $showFeedback,
                    showExplanation: $showExplanation,
                    currentIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    onAnswer: handleAnswer
                )
                
            case .gameOver:
                GameOverView(score: score, total: questions.count, onRestart: restartGame)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    func startGame() {
        questions = allQuestions
        currentQuestionIndex = 0
        score = 0
        currentOptions = currentQuestion.fixedOrder
        selectedAstronaut = nil
        showFeedback = false
        showExplanation = false
        gameState = .showingQuestion
    }

    func handleAnswer(_ astronautName: String) {
        selectedAstronaut = astronautName
        showFeedback = true
        
        // Haptic Feedback
        let generator = UINotificationFeedbackGenerator()
        if astronautName == currentQuestion.correctAstronaut {
            score += 1
            generator.notificationOccurred(.success)
        } else {
            showExplanation = true
            generator.notificationOccurred(.error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { nextQuestion() }
    }

    func nextQuestion() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedAstronaut = nil
            showFeedback = false
            showExplanation = false
            
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                currentOptions = currentQuestion.fixedOrder
            } else {
                gameState = .gameOver
            }
        }
    }

    func restartGame() {
        withAnimation {
            gameState = .welcome
        }
    }
}

// MARK: - Title View
struct TitleView: View {
    let onContinue: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("الـــرواد السعــوديـــون")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("قصص بدأت من حلم ووصلت إلى الفضاء")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
            
            // Tap to continue indicator
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("اضغط للاستمرار")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .opacity(isAnimating ? 1 : 0)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { onContinue() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Astronaut Info View
struct AstronautInfoView: View {
    let imageName: String
    let description: String
    let onNext: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                // Astronaut Image
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 210, height: 210)
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
                
                // Description Card
                VStack(alignment: .leading, spacing: 16) {
                    Text(description)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white)
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                .padding(.horizontal, 20)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                
                // Continue indicator
                VStack(spacing: 8) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text("اضغط للمتابعة")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 8)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { onNext() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onStart: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("الرواد أمامك")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .scaleEffect(isAnimating ? 1 : 0.9)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("هل تستطيع الإجابة؟")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Text("ابدأ التحدي")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 280)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.5), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Question View
struct QuestionView: View {
    let question: Question
    let options: [AstronautOption]
    @Binding var selectedAstronaut: String?
    @Binding var showFeedback: Bool
    @Binding var showExplanation: Bool
    let currentIndex: Int
    let totalQuestions: Int
    let onAnswer: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text("السؤال \(currentIndex + 1) من \(totalQuestions)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(currentIndex + 1) / CGFloat(totalQuestions), height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Question Card
                    VStack(spacing: 20) {
                        Text(question.question)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    
                    // Options
                    HStack(spacing: 24) {
                        ForEach(options) { astronaut in
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.1), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 110, height: 110)
                                    
                                    Image(astronaut.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    selectedAstronaut == astronaut.name ?
                                                        (astronaut.name == question.correctAstronaut ?
                                                         LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                         : LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                        : LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                    lineWidth: selectedAstronaut == astronaut.name ? 5 : 2
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
                                }
                                .scaleEffect(selectedAstronaut == astronaut.name ? 1.08 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedAstronaut)
                            }
                            .onTapGesture {
                                if selectedAstronaut == nil {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    onAnswer(astronaut.name)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Feedback
                    if showFeedback {
                        VStack(spacing: 16) {
                            if selectedAstronaut == question.correctAstronaut {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.green)
                                    
                                    Text("أحسنت! إجابة صحيحة")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                .transition(.scale.combined(with: .opacity))
                            } else {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.red)
                                        
                                        Text("الإجابة الصحيحة:")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text(question.correctAstronaut)
                                        .font(.system(size: 19, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            if showExplanation && selectedAstronaut != question.correctAstronaut {
                                Text(question.explanation)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 24)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showFeedback)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    @State private var isAnimating = false
    
    var performanceMessage: String {
        let percentage = Double(score) / Double(total)
        if percentage >= 0.9 {
            return "أداء رائع! أنت مستعد للفضاء 🚀"
        } else if percentage >= 0.7 {
            return "أداء ممتاز! استمر في التعلم 🌟"
        } else if percentage >= 0.5 {
            return "أداء جيد! يمكنك التحسن 💪"
        } else {
            return "حاول مرة أخرى، لن تستسلم! 🎯"
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("انتهت اللعبة")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isAnimating ? 1 : 0)
                
                // Score Card
                VStack(spacing: 16) {
                    Text("نتيجتك")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        Text("\(score)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                        Text("من")
                            .font(.system(size: 24, weight: .medium))
                        Text("\(total)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    
                    Text(performanceMessage)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
                .scaleEffect(isAnimating ? 1 : 0.9)
                .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
            
            // Restart Button
            Button(action: onRestart) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("العب مرة أخرى")
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 280)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .green.opacity(0.5), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

#Preview { Astronautsgame() }
