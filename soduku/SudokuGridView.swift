import SwiftUI

struct SudokuGridView: View {
    @ObservedObject var board: SudokuBoard
    @Binding var selectedCell: (row: Int, col: Int)?

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 9)

    var body: some View {
        ZStack {
            Color(.lightGray)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<9) { row in
                    ForEach(0..<9) { col in
                        SudokuCellView(
                            cell: board.cells[row][col],
                            isSelected: selectedCell?.row == row && selectedCell?.col == col,
                            isConflicting: board.cells[row][col].value != 0 &&
                                !board.isValidPlacement(boardCells: board.cells, row: row, col: col, number: board.cells[row][col].value),
                            onTap: {
                                if !board.isCellFixed(row: row, col: col) {
                                    selectedCell = (row, col)
                                } else {
                                    selectedCell = nil
                                }
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(getBorder(row: row, col: col))
                    }
                }
            }
            .padding(1)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func getBorder(row: Int, col: Int) -> some View {
        let thickWidth: CGFloat = 3
        let thinWidth: CGFloat = 0.5

        return Rectangle()
            .strokeBorder(Color.primary, lineWidth: thinWidth)
            .overlay(
                VStack(spacing: 0) {
                    Rectangle().frame(height: row % 3 == 0 ? thickWidth : thinWidth)
                    Spacer()
                    Rectangle().frame(height: row == 8 ? thickWidth : 0)
                }, alignment: .top
            )
            .overlay(
                HStack(spacing: 0) {
                    Rectangle().frame(width: col % 3 == 0 ? thickWidth : thinWidth)
                    Spacer()
                    Rectangle().frame(width: col == 8 ? thickWidth : 0)
                }, alignment: .leading
            )
    }
}
