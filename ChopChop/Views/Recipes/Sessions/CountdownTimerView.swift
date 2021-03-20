import SwiftUI

struct CountdownTimerView: View {
    @ObservedObject var viewModel: CountdownTimerViewModel

    var body: some View {
        // TODO
        if viewModel.isShow == false {
            HStack {
                Text("\(viewModel.displayTime)")
                    .onReceive(viewModel.countdownTimer.timer) { _ in
                        viewModel.countdown()
                    }
                    .foregroundColor(viewModel.countdownTimer.remainingTime == 0 ? .red : .white)
                if !viewModel.countdownTimer.isRunning {
                    VStack {
                        Button("+") {
                            viewModel.increaseTime()
                        }
                        Button("-") {
                            viewModel.decreaseTime()
                        }
                    }
                    Button("Start") {
                        viewModel.start()
                    }
                } else {
                    Button("Pause/Resume") {
                        viewModel.pauseResume()
                    }
                    Button("Restart") {
                        viewModel.restart()
                    }
                }
            }
            .background(Color.black)
            .clipShape(Capsule())
        }
    }
}

struct CountdownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CountdownTimerView(viewModel: CountdownTimerViewModel(countdownTimer: try! CountdownTimer(time: 60)))
    }
}
