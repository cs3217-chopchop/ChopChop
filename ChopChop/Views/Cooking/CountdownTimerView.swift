import SwiftUI

/**
 Represents a view of a timer.
 */
struct CountdownTimerView: View {
    @ObservedObject var viewModel: CountdownTimerViewModel
    @State var animationState = true

    var body: some View {
        HStack(spacing: 0) {
            switch viewModel.status {
            case .stopped:
                stoppedView
            case .running:
                runningView
            case .paused:
                pausedView
            case .ended:
                endedView
            }
        }
        .padding([.leading, .trailing], 8)
        .frame(width: 185)
        .foregroundColor(.white)
        .background(background)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var stoppedView: some View {
        Text(viewModel.timeRemaining)
            .font(Font.body.monospacedDigit())
            .padding()
            .onTapGesture(perform: viewModel.timer.start)
        Button(action: viewModel.timer.start) {
            Image(systemName: "play.fill")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
        Button(action: viewModel.timer.reset) {
            Image(systemName: "arrow.clockwise")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }

    @ViewBuilder
    private var runningView: some View {
        Text(viewModel.timeRemaining)
            .font(Font.body.monospacedDigit())
            .padding()
            .onTapGesture(perform: viewModel.timer.pause)
        Spacer()
        Button(action: viewModel.timer.pause) {
            Image(systemName: "pause.fill")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }

    @ViewBuilder
    private var pausedView: some View {
        Text(viewModel.timeRemaining)
            .font(Font.body.monospacedDigit())
            .padding()
            .opacity(animationState ? 1 : 0.4)
            .animation(Animation.linear(duration: .leastNonzeroMagnitude).delay(0.5).repeatForever())
            .onAppear {
                animationState.toggle()
            }
            .onTapGesture(perform: viewModel.timer.resume)
        Button(action: viewModel.timer.resume) {
            Image(systemName: "play.fill")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
        Button(action: viewModel.timer.reset) {
            Image(systemName: "arrow.clockwise")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }

    @ViewBuilder
    private var endedView: some View {
        Text(viewModel.timeRemaining)
            .font(Font.body.monospacedDigit())
            .padding()
            .opacity(animationState ? 1 : 0.4)
            .animation(Animation.linear(duration: .leastNonzeroMagnitude).delay(0.5).repeatForever())
            .onAppear {
                animationState.toggle()
            }
            .onTapGesture(perform: viewModel.timer.reset)
        Spacer()
        Button(action: viewModel.timer.reset) {
            Image(systemName: "stop.fill")
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }

    @ViewBuilder
    private var background: some View {
        switch viewModel.status {
        case .running, .paused:
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.accentColor)
                    .overlay(
                        Rectangle()
                            .fill(Color(UIColor.systemBackground).opacity(0.2))
                    )
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 185 * CGFloat(viewModel.timer.timeRemaining / viewModel.timer.duration))
                    .animation(.easeInOut)
            }
        case .stopped:
            Color.accentColor
        case .ended:
            Color.red
        }
    }
}

struct CountdownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownTimerView(viewModel: CountdownTimerViewModel(timer: CountdownTimer(duration: 10)))
    }
}
