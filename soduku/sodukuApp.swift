import SwiftUI
import Foundation

// MARK: - SudokuCell
// Represents a single cell on the Sudoku board
struct SudokuCell: Equatable {
    var value: Int // 0 for empty, 1-9 for numbers
    let isFixed: Bool // True if it's part of the initial puzzle, false if user entered
}

// MARK: - SudokuBoard
// Represents the entire 9x9 Sudoku board
class SudokuBoard: ObservableObject {
    @Published var cells: [[SudokuCell]]

    init() {
        self.cells = Array(repeating: Array(repeating: SudokuCell(value: 0, isFixed: false), count: 9), count: 9)
    }

    convenience init(puzzle: [[Int]]) {
        self.init()
        for row in 0..<9 {
            for col in 0..<9 {
                let value = puzzle[row][col]
                self.cells[row][col] = SudokuCell(value: value, isFixed: value != 0)
            }
        }
    }

    // MARK: - Basic Operations

    func getValue(row: Int, col: Int) -> Int {
        guard row >= 0 && row < 9 && col >= 0 && col < 9 else { return 0 }
        return cells[row][col].value
    }

    func setValue(row: Int, col: Int, value: Int) -> Bool {
        guard row >= 0 && row < 9 && col >= 0 && col < 9 else { return false }
        if !cells[row][col].isFixed {
            cells[row][col].value = value
            return true
        }
        return false
    }

    func isCellFixed(row: Int, col: Int) -> Bool {
        guard row >= 0 && row < 9 && col >= 0 && col < 9 else { return false }
        return cells[row][col].isFixed
    }

    // MARK: - Sudoku Validation Logic

    // Checks if a given number is valid at a specific position on the *current* board state
    func isValidPlacement(row: Int, col: Int, number: Int) -> Bool {
        if number == 0 { return true }

        // Check row
        for c in 0..<9 where c != col {
            if cells[row][c].value == number {
                return false
            }
        }

        // Check column
        for r in 0..<9 where r != row {
            if cells[r][col].value == number {
                return false
            }
        }

        // Check 3x3 subgrid
        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for r in startRow..<(startRow + 3) {
            for c in startCol..<(startCol + 3) {
                if r != row || c != col {
                    if cells[r][c].value == number {
                        return false
                    }
                }
            }
        }
        return true
    }

    // Helper function for isValidPlacement that takes a specific board state (e.g., a temporary copy)
    func isValidPlacement(boardCells: [[SudokuCell]], row: Int, col: Int, number: Int) -> Bool {
        if number == 0 { return true }

        for c in 0..<9 where c != col {
            if boardCells[row][c].value == number {
                return false
            }
        }

        for r in 0..<9 where r != row {
            if boardCells[r][col].value == number {
                return false
            }
        }

        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for r in startRow..<(startRow + 3) {
            for c in startCol..<(startCol + 3) {
                if r != row || c != col {
                    if boardCells[r][c].value == number {
                        return false
                    }
                }
            }
        }
        return true
    }

    // Checks if the entire board is currently valid (no immediate rule violations)
    func isBoardValid() -> Bool {
        let currentCellsCopy = cells

        for r in 0..<9 {
            for c in 0..<9 {
                let currentValue = currentCellsCopy[r][c].value
                if currentValue != 0 {
                    var tempCells = currentCellsCopy
                    tempCells[r][c].value = 0
                    
                    if !isValidPlacement(boardCells: tempCells, row: r, col: c, number: currentValue) {
                        return false
                    }
                }
            }
        }
        return true
    }

    // Checks if the puzzle is completely solved
    func isSolved() -> Bool {
        for r in 0..<9 {
            for c in 0..<9 {
                if cells[r][c].value == 0 {
                    return false
                }
                let currentValue = cells[r][c].value
                var tempCells = cells
                tempCells[r][c].value = 0
                
                if !isValidPlacement(boardCells: tempCells, row: r, col: c, number: currentValue) {
                    return false
                }
            }
        }
        return true
    }

    // MARK: - Puzzle Generation (Simplified - for demonstration)

    static func generateSamplePuzzle() -> [[Int]] {
        return [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ]
    }
}

// MARK: - SudokuApp
@main
struct SudokuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



// MARK: - GridLinesOverlay
struct GridLinesOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let gridSize = min(geometry.size.width, geometry.size.height)
            let cellSize = gridSize / 9.0
            let lineWidth: CGFloat = 2
            let halfLine = lineWidth / 2

            Path { path in
                // Thick vertical lines at 3 and 6
                for i in [3, 6] {
                    let x = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: x, y: -10))
                    path.addLine(to: CGPoint(x: x, y: gridSize))
                }

                // Thick horizontal lines at 3 and 6
                for i in [3, 6] {
                    let y = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: gridSize, y: y))
                }

                // Outer border (moved slightly inward to avoid clipping)
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: gridSize, y: 0)) // top
                path.addLine(to: CGPoint(x: gridSize, y: gridSize)) // right
                path.addLine(to: CGPoint(x: 0, y: gridSize)) // bottom
                path.addLine(to: CGPoint(x: 0, y: 0)) // left
            }
            .stroke(Color.primary, lineWidth: lineWidth)
        }
        .allowsHitTesting(false)
    }
}



// MARK: - SudokuCellView
struct SudokuCellView: View {
    let cell: SudokuCell
    let isSelected: Bool
    let isConflicting: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)

            Text(cell.value == 0 ? "" : "\(cell.value)")
                .font(.title2)
                .fontWeight(cell.isFixed ? .bold : .regular)
                .foregroundColor(cell.isFixed ? .black : (isConflicting ? .red : .blue))
        }
        .onTapGesture(perform: onTap)
    }

    private var backgroundColor: Color {
        if isConflicting {
            return Color.red.opacity(0.3)
        } else if isSelected {
            return Color.yellow.opacity(0.3)
        } else if cell.isFixed {
            return Color.gray.opacity(0.1)
        } else {
            return Color.white
        }
    }
}


// MARK: - NumberInputPad
struct BubblyButtonStyle: ButtonStyle {
    var small: Bool = false
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(small ? .title3.bold() : .title2.bold())
            .frame(width: small ? 50 : 80, height: small ? 50 : 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 0.85, green: 0.4, blue: 0.0))
                    .shadow(color: .orange.opacity(0.4), radius: configuration.isPressed ? 2 : 6, x: 0, y: configuration.isPressed ? 1 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .foregroundColor(foregroundColor)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}


// MARK: - NumberInputPad
struct NumberInputPad: View {
    @Binding var selectedCell: (row: Int, col: Int)?
    @ObservedObject var board: SudokuBoard
    @Binding var errorMessage: String?

    let numbers: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    var body: some View {
        VStack(spacing: 10) {
            // 3x3 Grid of Number Buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(numbers, id: \.self) { number in
                    Button(action: {
                        handleInput(number)
                    }) {
                        Text("\(number)")
                    }
                    .buttonStyle(BubblyButtonStyle(small: true))
                }
            }
            .padding(.horizontal)

            // Clear Button
            Button(action: {
                clearSelectedCell()
            }) {
                Text("Clear")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(BubblyButtonStyle())


        }
    }

    private func handleInput(_ number: Int) {
        if let (row, col) = selectedCell {
            if board.isCellFixed(row: row, col: col) {
                errorMessage = "Cannot change a fixed number."
                return
            }

            var tempCells = board.cells
            tempCells[row][col].value = number

            if board.isValidPlacement(boardCells: tempCells, row: row, col: col, number: number) {
                _ = board.setValue(row: row, col: col, value: number)
                errorMessage = nil
                if board.isSolved() {
                    errorMessage = "Congratulations! Puzzle Solved!"
                }
            } else {
                errorMessage = "Invalid move! \(number) conflicts with existing numbers."
            }
        } else {
            errorMessage = "Please select a cell first."
        }
    }

    private func clearSelectedCell() {
        if let (row, col) = selectedCell {
            if board.isCellFixed(row: row, col: col) {
                errorMessage = "Cannot clear a fixed number."
                return
            }
            if board.setValue(row: row, col: col, value: 0) {
                errorMessage = nil
            }
        } else {
            errorMessage = "Please select a cell first."
        }
    }
}



// MARK: - Preview Provider (for Xcode Canvas)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
