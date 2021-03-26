import SwiftUI

struct CountdownTimerView: View {
    @ObservedObject var viewModel: CountdownTimerViewModel

    var body: some View {
        HStack {
            Text("Timer")
            timeDisplay
            if !viewModel.countdownTimer.isStart {
                VStack {
                    plusTimeButton
                    minusTimeButton
                }
                startButton
            } else {
                pauseButton
                restartButton
            }
        }
        .disabled(viewModel.isDisabled)
        .frame(width: 220, height: 60, alignment: .center)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(Capsule())
    }

    var timeDisplay: some View {
        Text(viewModel.displayTime)
            .onReceive(viewModel.countdownTimer.timer) { _ in
                viewModel.countdown()
            }
            .foregroundColor(viewModel.countdownTimer.remainingTime == 0 ? .red : .white)
    }

    var plusTimeButton: some View {
        Button("+") {
            viewModel.increaseTime()
        }
        .disabled(viewModel.isDisabled)
    }

    var minusTimeButton: some View {
        Button("-") {
            viewModel.decreaseTime()
        }
        .disabled(viewModel.isDisabled)
    }

    var startButton: some View {
        Button(action: viewModel.start) {
            Image(systemName: "hourglass.bottomhalf.fill")
        }
        .disabled(viewModel.isDisabled)
    }

    var pauseButton: some View {
        Button(action: viewModel.pauseResume) {
            Image(systemName: "playpause")
        }
        .disabled(viewModel.isDisabled)
    }

    var restartButton: some View {
        Button(action: viewModel.restart) {
            Image(systemName: "arrow.counterclockwise")
        }
        .disabled(viewModel.isDisabled)
    }
}

struct CountdownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CountdownTimerView(viewModel: CountdownTimerViewModel(countdownTimer: try! CountdownTimer(time: 60)))
    }
}
