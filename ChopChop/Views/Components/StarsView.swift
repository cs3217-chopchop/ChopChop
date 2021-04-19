import SwiftUI

/**
 Represents a view consisting of a number of stars representing a rating.
 
 Reference: // https://stackoverflow.com/questions/64379079/how-to-present-accurate-star-rating-using-swiftui/64389917
 */
struct StarsView: View {
    var rating: Double
    var maxRating: Int
    var onTap: ((Int) -> Void)?

    init(rating: Double, maxRating: Int, onTap: ((Int) -> Void)? = nil) {
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
                        if let onTap = onTap {
                            onTap(idx)
                        }
                    }
            }
        }

        stars.overlay(
            GeometryReader { g in
                let starWidth = g.size.width / CGFloat(maxRating)
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
                                    if let onTap = onTap {
                                        onTap(idx)
                                    }
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
