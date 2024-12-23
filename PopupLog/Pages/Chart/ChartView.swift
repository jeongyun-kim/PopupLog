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
    @State private var tagDict: [String: Int] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                logTextView()
                logChartHeaderView()
                logChartView(logCounts)
                tagHeaderView()
                tagChartView()
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Resources.Colors.moreLightOrange)
        .scrollIndicators(.hidden)
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
    // MARK: LogTextView
    private func logTextView() -> some View {
        Text(logText)
            .font(.title3)
            .bold()
    }
    
    // MARK: LogChartHeaderView
    private func logChartHeaderView() -> some View {
        Text("최근 6개월 간의 기록 내역")
            .asChartHeaderText()
            .padding(.top, 8)
    }
    
    // MARK: LogChartView
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
    
    // MARK: TagHeaderView
    private func tagHeaderView() -> some View {
        Text("태그별 기록 내역")
            .asChartHeaderText()
            .padding(.top, 24)
    }
    
    // MARK: TagChartView
    private func tagChartView() -> some View {
        if #available(iOS 17.0, *) {
            return Chart(TagRepository.shared.getAllTags(), id: \.id) { element in
                SectorMark(
                    angle: .value("Usage", tagDict[element.chartTagName] ?? 0),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(8)
                .annotation(position: .overlay, content: {
                    if tagDict[element.chartTagName] ?? 0 > 0 {
                        VStack(spacing: 6) {
                            Text(element.chartTagName)
                            Text("(\(tagDict[element.chartTagName] ?? 0))")
                        }
                        .font(Resources.Fonts.bold13)
                    }
                })
                .foregroundStyle(Color(hex: element.tagColor ?? Resources.Colors.systemGray6.toHex()!))
            }
            .chartLegend(alignment: .center, spacing: 18)
            .padding()
            .scaledToFit()
        } else {
            return ZStack { }
        }
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
        
        for tag in TagRepository.shared.getAllTags() {
            let cnt = LogRepository.shared.getFilteredLogs(tag).count
            tagDict[tag.chartTagName] = cnt
        }
    }
    
    private func getLogText() {
        let maxData = logCounts.max() ?? 0
        guard let idx = logCounts.firstIndex(of: maxData) else { return }
        logText = "기록을 가장 많이 한 달은 \(logMonths[idx])이네요 🔥\n총 \(maxData)개의 기록을 남겼어요!"
    }
}
