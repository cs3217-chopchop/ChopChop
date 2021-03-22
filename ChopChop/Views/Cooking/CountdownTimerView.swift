import SwiftUI

struct CountdownTimerView: View {
    @ObservedObject var viewModel: CountdownTimerViewModel

    var body: some View {
        HStack {
            Text("Timer")
            Text(viewModel.displayTime)
                .onReceive(viewModel.countdownTimer.timer) { _ in
                    viewModel.countdown()
                }
                .foregroundColor(viewModel.countdownTimer.remainingTime == 0 ? .red : .white)
            if !viewModel.countdownTimer.isStart {
                VStack {
                    Button("+") {
                        viewModel.increaseTime()
                    }
                    Button("-") {
                        viewModel.decreaseTime()
                    }
                }
                Button(action: {
                    viewModel.start()
                }) {
                    Image(systemName: "hourglass.bottomhalf.fill")
                }
            } else {
                Button(action: {
                    viewModel.pauseResume()
                }) {
                    Image(systemName: "playpause")
                }
                Button(action: {
                    viewModel.restart()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
        .frame(width: 220, height: 60, alignment: .center)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(Capsule())
    }
}

struct CountdownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CountdownTimerView(viewModel: CountdownTimerViewModel(countdownTimer: try! CountdownTimer(time: 60)))
    }
}
