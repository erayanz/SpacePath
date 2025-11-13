import SwiftUI

// MARK: - Puzzle Piece Model
struct PuzzlePiece: Identifiable, Equatable {
    let id: Int
    var currentPosition: Int
    let correctPosition: Int
    let isEmpty: Bool
    
    var isInCorrectPosition: Bool {
        currentPosition == correctPosition
    }
}

// MARK: - Puzzle Game View
struct PuzzleGameView: View {
    @State private var pieces: [PuzzlePiece] = []
    @State private var moves: Int = 0
    @State private var showWinAlert = false
    @State private var selectedPlanet = "الأرض"
    @State private var timer: Timer?
    @State private var elapsedTime: Int = 0
    @State private var isPlaying = false
    
    let gridSize = 3 // Fixed 3x3 grid
    let planets = ["الشمس", "عطارد", "الزهرة", "الأرض", "المريخ", "المشتري", "زحل", "أورانوس", "نبتون"]
    
    var body: some View {
        ZStack {
            AnimatedDarkBackground()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("لغز الكواكب")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("الحركات")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(moves)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Text("الوقت")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text(timeString)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Puzzle Grid or Planet Selection
                if isPlaying {
                    puzzleGrid
                        .padding(.horizontal, 20)
                } else {
                    planetSelectionView
                }
                
                Spacer()
                
                // Controls
                VStack(spacing: 16) {
                    if isPlaying {
                        Button(action: shufflePuzzle) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("خلط جديد")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 16))
                        }
                        
                        Button(action: {
                            isPlaying = false
                            resetGame()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("اختر كوكب آخر")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        Button(action: startGame) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("ابدأ اللعبة")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green, in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("🎉 مبروك!", isPresented: $showWinAlert) {
            Button("العب مرة أخرى") {
                startGame()
            }
            Button("اختر كوكب آخر") {
                isPlaying = false
                resetGame()
            }
        } message: {
            Text("أكملت اللغز في \(moves) حركة و \(timeString)!")
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - Puzzle Grid
    var puzzleGrid: some View {
        GeometryReader { geometry in
            let totalSize = min(geometry.size.width, geometry.size.height) - 40
            let pieceSize = totalSize / CGFloat(gridSize)
            
            ZStack {
                // Background preview (faded)
                Image(selectedPlanet)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: totalSize, height: totalSize)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(0.2)
                
                // Puzzle pieces
                ForEach(pieces) { piece in
                    if !piece.isEmpty {
                        let row = piece.currentPosition / gridSize
                        let col = piece.currentPosition % gridSize
                        
                        PuzzlePieceView(
                            image: selectedPlanet,
                            piece: piece,
                            pieceSize: pieceSize,
                            gridSize: gridSize,
                            totalSize: totalSize
                        )
                        .position(
                            x: CGFloat(col) * pieceSize + pieceSize / 2,
                            y: CGFloat(row) * pieceSize + pieceSize / 2
                        )
                        .onTapGesture {
                            movePiece(piece)
                        }
                    }
                }
            }
            .frame(width: totalSize, height: totalSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    // MARK: - Planet Selection
    var planetSelectionView: some View {
        VStack(spacing: 20) {
            Text("اختر كوكباً")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(planets, id: \.self) { planet in
                        Button(action: { selectedPlanet = planet }) {
                            VStack {
                                Image(planet)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedPlanet == planet ? Color.yellow : Color.clear, lineWidth: 4)
                                    )
                                    .shadow(color: .white.opacity(0.3), radius: 8)
                                
                                Text(planet)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Game Logic
    func startGame() {
        isPlaying = true
        moves = 0
        elapsedTime = 0
        initializePuzzle()
        shufflePuzzle()
        startTimer()
    }
    
    func resetGame() {
        isPlaying = false
        moves = 0
        elapsedTime = 0
        stopTimer()
        pieces = []
    }
    
    func initializePuzzle() {
        let totalPieces = gridSize * gridSize
        pieces = (0..<totalPieces).map { index in
            PuzzlePiece(
                id: index,
                currentPosition: index,
                correctPosition: index,
                isEmpty: index == totalPieces - 1
            )
        }
    }
    
    func shufflePuzzle() {
        moves = 0
        
        // Shuffle 200 times
        for _ in 0..<200 {
            if let emptyPiece = pieces.first(where: { $0.isEmpty }) {
                let emptyPos = emptyPiece.currentPosition
                let neighbors = getValidNeighbors(of: emptyPos)
                
                if let randomNeighbor = neighbors.randomElement(),
                   let neighborPiece = pieces.first(where: { $0.currentPosition == randomNeighbor && !$0.isEmpty }) {
                    // Direct swap without animation for shuffling
                    swapPieces(piece1: emptyPiece, piece2: neighborPiece, animated: false)
                }
            }
        }
    }
    
    func movePiece(_ tappedPiece: PuzzlePiece) {
        guard !tappedPiece.isEmpty else { return }
        
        if let emptyPiece = pieces.first(where: { $0.isEmpty }) {
            let emptyPos = emptyPiece.currentPosition
            let tappedPos = tappedPiece.currentPosition
            
            // Check if tapped piece is adjacent to empty space
            if isAdjacent(pos1: emptyPos, pos2: tappedPos) {
                swapPieces(piece1: emptyPiece, piece2: tappedPiece, animated: true)
                moves += 1
                checkWin()
            }
        }
    }
    
    func swapPieces(piece1: PuzzlePiece, piece2: PuzzlePiece, animated: Bool) {
        guard let index1 = pieces.firstIndex(where: { $0.id == piece1.id }),
              let index2 = pieces.firstIndex(where: { $0.id == piece2.id }) else { return }
        
        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let temp = pieces[index1].currentPosition
                pieces[index1].currentPosition = pieces[index2].currentPosition
                pieces[index2].currentPosition = temp
            }
        } else {
            let temp = pieces[index1].currentPosition
            pieces[index1].currentPosition = pieces[index2].currentPosition
            pieces[index2].currentPosition = temp
        }
    }
    
    func isAdjacent(pos1: Int, pos2: Int) -> Bool {
        let row1 = pos1 / gridSize
        let col1 = pos1 % gridSize
        let row2 = pos2 / gridSize
        let col2 = pos2 % gridSize
        
        // Same row and adjacent columns
        if row1 == row2 && abs(col1 - col2) == 1 {
            return true
        }
        
        // Same column and adjacent rows
        if col1 == col2 && abs(row1 - row2) == 1 {
            return true
        }
        
        return false
    }
    
    func getValidNeighbors(of position: Int) -> [Int] {
        var neighbors: [Int] = []
        let row = position / gridSize
        let col = position % gridSize
        
        // Up
        if row > 0 {
            neighbors.append(position - gridSize)
        }
        // Down
        if row < gridSize - 1 {
            neighbors.append(position + gridSize)
        }
        // Left
        if col > 0 {
            neighbors.append(position - 1)
        }
        // Right
        if col < gridSize - 1 {
            neighbors.append(position + 1)
        }
        
        return neighbors
    }
    
    func checkWin() {
        let isWin = pieces.allSatisfy { $0.isInCorrectPosition }
        if isWin {
            stopTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWinAlert = true
            }
        }
    }
    
    // MARK: - Timer
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    var timeString: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Puzzle Piece View
struct PuzzlePieceView: View {
    let image: String
    let piece: PuzzlePiece
    let pieceSize: CGFloat
    let gridSize: Int
    let totalSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let correctRow = piece.correctPosition / gridSize
            let correctCol = piece.correctPosition % gridSize
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: totalSize, height: totalSize)
                .offset(
                    x: -CGFloat(correctCol) * pieceSize,
                    y: -CGFloat(correctRow) * pieceSize
                )
        }
        .frame(width: pieceSize - 4, height: pieceSize - 4)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 4)
    }
}

// MARK: - Preview
#Preview {
    PuzzleGameView()
}
