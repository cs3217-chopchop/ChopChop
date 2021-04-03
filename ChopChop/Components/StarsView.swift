// https://stackoverflow.com/questions/64379079/how-to-present-accurate-star-rating-using-swiftui/64389917
import SwiftUI

struct StarsView: View {
    var rating: Double
    var maxRating: Int
    var onTap: (Int) -> Void

    static func defaultFunc(_ input: Int) {}

    init(rating: Double, maxRating: Int, onTap: @escaping (Int) -> Void = defaultFunc) {
        self.rating = rating
        self.maxRating = maxRating
        self.onTap = onTap
    }

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
                let starWidth = g.size.width / CGFloat(maxRating)
                let width = CGFloat(rating) / CGFloat(maxRating) * g.size.width
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        ForEach(0..<maxRating) { idx in
                            let width = CGFloat(Double(idx) + 1 < rating
                                ? 1
                                : (Double(idx) < rating
                                    ? rating - Double(idx)
                                    : 0))
                            Rectangle()
                                .frame(width: width * starWidth)
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    onTap(idx)
                                }
                        }
                    }
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
    }
}
