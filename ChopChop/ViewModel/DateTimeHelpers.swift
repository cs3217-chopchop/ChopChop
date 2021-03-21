// convert seconds to hh:mm:ss
func get_HHMMSS_Display(seconds: Int) -> String {
    let time = seconds
    let hour = "\(time / 3_600 / 10 > 0 ? "" : "0")\(time / 3_600)"
    let minute = "\((time % 3_600) / 60 / 10 > 0 ? "" : "0")\((time % 3_600) / 60)"
    let second = "\(((time % 3_600) % 60) / 10 > 0 ? "" : "0")\(((time % 3_600) % 60))"
    return hour + ":" + minute + ":" + second
}
