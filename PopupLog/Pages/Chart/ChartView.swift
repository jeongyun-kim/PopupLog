//
//  ChartView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import Charts
import RealmSwift

struct ChartView: View {
    @EnvironmentObject var viewStatus: CalendarViewStatus
    @ObservedResults(Log.self) private var logList
    @State private var logMonths: [String] = []
    @State private var logCounts: [Int] = []
    @State private var logText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                logTextView()
                logChartHeaderView()
                logChartView(logCounts)
            }
            .padding()
        }
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("통계")
        .toolbarRole(.editor)
        .onAppear {
            addDatas()
            getLogText()
            viewStatus.isPresentingBottomSheet.toggle()
        }
        .onDisappear {
            viewStatus.isPresentingBottomSheet.toggle()
        }
    }
}

// MARK: ViewUI
extension ChartView {
    private func logTextView() -> some View {
        Text(logText)
            .font(.title3)
            .bold()
    }
    
    private func logChartHeaderView() -> some View {
        Text("최근 6개월 간의 기록 내역")
            .foregroundStyle(Resources.Colors.lightGray)
            .font(.caption)
            .bold()
            .padding(.top, 8)
    }
    
    private func logChartView(_ logCounts: [Int]) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
            Chart(Array(logCounts.enumerated()), id: \.offset) { value in
                BarMark(x: .value("날짜", logMonths[value.offset]), y: .value("", value.element), width: .automatic, height: .automatic, stacking: .standard)
            }
            .chartXAxis {
                AxisMarks(stroke: StrokeStyle(lineWidth: 0))
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(Resources.Fonts.font14)
                        .foregroundStyle(Resources.Colors.lightGray)
                }
            }
            .chartYScale(range: .plotDimension(startPadding: 4, endPadding: 16))
            .chartXScale(range: .plotDimension(startPadding: 0, endPadding: 4))
        }
        .frame(height: 250)
    }
}

// MARK: Data Methods
extension ChartView {
    private func addDatas() {
        for i in (0..<6).reversed() {
            let date = Calendar.current.date(byAdding: .month, value: -i, to: Date())
            guard let month = date?.yearAndMonth.components(separatedBy: "-")[1] else { return }
            logMonths.append("\(month)월")
            logCounts.append(logList.filter { $0.visitDate.yearAndMonth == date?.yearAndMonth }.count)
        }
    }
    
    private func getLogText() {
        let maxData = logCounts.max() ?? 0
        guard let idx = logCounts.firstIndex(of: maxData) else { return }
        logText = "기록을 가장 많이 한 달은 \(logMonths[idx])이네요 🔥\n총 \(maxData)개의 기록을 남겼어요!"
    }
}
