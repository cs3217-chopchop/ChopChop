// https://stackoverflow.com/questions/64379079/how-to-present-accurate-star-rating-using-swiftui/64389917
import SwiftUI

struct StarsView: View {
    var rating: Double
    var maxRating: Int
    var onTap: (Int) -> Void

    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<maxRating) { idx in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        onTap(idx)
                    }
            }
        }

        stars.overlay(
            GeometryReader { g in
                let width = CGFloat(rating) / CGFloat(maxRating) * g.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
    }
}
