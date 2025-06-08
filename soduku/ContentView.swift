import SwiftUI

struct ContentView: View {
    @StateObject private var board = SudokuBoard()
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Spacer()
            SudokuGridView(board: board, selectedCell: $selectedCell)
                .padding()
            
            Spacer()
            NumberInputPad(
                selectedCell: $selectedCell,
                board: board,
                errorMessage: $errorMessage
            )
            .padding()
        }
        .padding()
    }
}
