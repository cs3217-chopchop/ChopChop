import SwiftUI

struct DifficultyView: View {
    let difficulty: Difficulty?

    var body: some View {
        if let difficulty = difficulty {
            ForEach(0..<difficulty.rawValue, id: \.self) { _ in
                Image(systemName: "star.fill")
            }

            ForEach(difficulty.rawValue..<5, id: \.self) { _ in
                Image(systemName: "star")
            }
        } else {
            ForEach(0..<5) { _ in
                Image(systemName: "star")
            }
        }
    }
}

struct DifficultyView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultyView(difficulty: nil)
    }
}
