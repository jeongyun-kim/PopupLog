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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewStatus: CalendarViewStatus
    @ObservedResults(Log.self) private var logList
    @State private var logMonths: [String] = []
    @State private var logCounts: [Int] = []
    @State private var logText = ""
    @State private var tagDict: [String: Int] = [:]
    @State private var selectedBarIndex: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCardView()
                logChartCardView()
                
                // iOS 17 이상이고 태그 데이터가 있을 때만 표시
                if #available(iOS 17.0, *) {
                    if !tagDict.isEmpty && tagDict.values.reduce(0, +) > 0 {
                        tagChartCardView()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
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
    // MARK: Summary Card
    private func summaryCardView() -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Resources.Colors.moreLightOrange.opacity(0.3))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Resources.Colors.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(logText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
    }
    
    // MARK: Log Chart Card
    private func logChartCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("최근 6개월 간의 기록 내역")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            // Chart
            logChartView(logCounts)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
    }
    
    // MARK: LogChartView
    private func logChartView(_ logCounts: [Int]) -> some View {
        Chart(Array(logCounts.enumerated()), id: \.offset) { value in
            BarMark(
                x: .value("날짜", logMonths[value.offset]),
                y: .value("", value.element)
            )
            .foregroundStyle(
                value.element > 0
                ? Resources.Colors.primaryColor : Color.gray.opacity(0.15)
            )
            .cornerRadius(8)
            .annotation(position: .top) {
                if selectedBarIndex == value.offset && value.element > 0 {
                    Text("\(value.element)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .chartYScale(range: .plotDimension(startPadding: 4, endPadding: 20))
        .chartXScale(range: .plotDimension(startPadding: 12, endPadding: 12))
        .frame(height: 220)
        .onTapGesture { location in
            // 탭한 위치의 인덱스 찾기 (간단한 구현)
            let index = Int(location.x / (UIScreen.main.bounds.width - 80) * CGFloat(logCounts.count))
            withAnimation(.spring(response: 0.3)) {
                selectedBarIndex = (selectedBarIndex == index) ? nil : index
            }
        }
    }
    
    // MARK: Tag Chart Card
    private func tagChartCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("태그별 기록 내역")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            // Chart
            if #available(iOS 17.0, *) {
                tagChartView()
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
    }
    
    // MARK: TagChartView
    @available(iOS 17.0, *)
    private func tagChartView() -> some View {
        let filteredTags = Array(TagRepository.shared.getAllTags().filter { tagDict[$0.chartTagName] ?? 0 > 0 })
        
        return VStack(spacing: 32) {
            // Donut Chart
            if !filteredTags.isEmpty {
                Chart(filteredTags, id: \.id) { element in
                    SectorMark(
                        angle: .value("Usage", tagDict[element.chartTagName] ?? 0),
                        innerRadius: .ratio(0.65),
                        angularInset: 2
                    )
                    .cornerRadius(6)
                    .foregroundStyle(Color(hex: element.tagColor ?? "#F5F5F5"))
                }
                .chartLegend(.hidden)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        if let frame = chartProxy.plotFrame {
                            VStack(spacing: 4) {
                                Text("\(tagDict.values.reduce(0, +))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text("총 기록")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .position(x: geometry[frame].midX, y: geometry[frame].midY)
                        }
                    }
                }
                .frame(height: 240)
                
                // Legend - 데이터가 있는 태그만 표시
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredTags, id: \.id) { tag in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: tag.tagColor ?? "#F5F5F5"))
                            
                            if colorScheme == .dark {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.black.opacity(0.3))
                            }
                            
                            HStack(spacing: 2) {
                                Text(tag.chartTagName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Resources.Colors.black)
                                
                                Text("(\(tagDict[tag.chartTagName] ?? 0))")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Resources.Colors.black)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 0)
                        }
                    }
                }
            }
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
        logText = "기록을 가장 많이 한 달은 \(logMonths[idx])이네요🔥\n총 \(maxData)개의 기록을 남겼어요!"
    }
}
