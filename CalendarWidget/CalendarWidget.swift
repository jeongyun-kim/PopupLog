//
//  CalendarWidget.swift
//  CalendarWidget
//
//  Created by 김정윤 on 11/10/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    day: Date().formattedDay,
                    E: Date().formattedE,
                    hasLog: false,
                    logImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let todayLog = getTodayLog()
        let day = todayLog?.visitDate.formattedDay ?? Date().formattedDay
        let E = todayLog?.visitDate.formattedE ?? Date().formattedE
        let hasLog = todayLog != nil
        
        let image = loadLogImage(from: todayLog)
        
        let entry = SimpleEntry(
            date: Date(),
            day: day,
            E: E,
            hasLog: hasLog,
            logImage: image
        )
        completion(entry)
    }

    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("🔵 getTimeline 호출")
        
        let todayLog = getTodayLog()
        let day = todayLog?.visitDate.formattedDay ?? Date().formattedDay
        let E = todayLog?.visitDate.formattedE ?? Date().formattedE
        let hasLog = todayLog != nil
        let logImage = loadLogImage(from: todayLog)
        
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        
        // 1분 간격으로 5분치 Timeline 생성
        for minuteOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                day: day,
                E: E,
                hasLog: hasLog,
                logImage: logImage
            )
            entries.append(entry)
        }
        
        // 다음날 00:00에 갱신되도록 설정
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        
        completion(timeline)
    }

    // 오늘 날짜의 로그만 가져오기
    private func getTodayLog() -> Log? {
        let logs = LogRepository.shared.getAllLogs()
        let today = Calendar.current.startOfDay(for: Date())
        
        return logs.first { log in
            let logDate = Calendar.current.startOfDay(for: log.visitDate)
            return logDate == today
        }
    }

    // 이미지 로드 헬퍼 함수
    private func loadLogImage(from log: Log?) -> UIImage? {
        guard let log = log else { return nil }
        return DocumentManager.shared.loadImageForWidget(id: "\(log.id)")
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date // 날짜
    let day: String // 날
    let E: String // 요일
    let hasLog: Bool // 로그 있는지
    let logImage: UIImage? // 로그 이미지
}

struct CalendarWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 이미지
                if entry.hasLog {
                    // 오늘 기록이 있는 경우
                    if let image = entry.logImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        Color.white
                            .opacity(0.2)
                    } else {
                        Image(uiImage: colorScheme == .light ? Resources.Images.ticket : Resources.Images.darkTicket)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        Color.white
                            .opacity(0.3)
                    }
                } else {
                    // 오늘 기록이 없는 경우
                    EmptyLogWidgetImageView()
                }

                // 텍스트 오버레이
                VStack(alignment: .leading) {
                    if entry.hasLog {
                        HasLogTextView(day: entry.day, E: entry.E)
                        .padding()
                        Spacer()
                    } else {
                        EmptyLogWidgetTextView(day: entry.day, E: entry.E)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalendarWidgetContentView(entry: entry)
            } else {
                CalendarWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("팝업로그")
        .description("오늘의 팝업 기록을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

@available(iOS 17.0, *)
struct CalendarWidgetContentView: View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            if entry.hasLog {
                HasLogTextView(day: entry.day, E: entry.E)
                Spacer()
            } else {
                EmptyLogWidgetTextView(day: entry.day, E: entry.E)
            }
        }
        .containerBackground(for: .widget) {
            // 배경 이미지를 containerBackground로
            if entry.hasLog {
                if let image = entry.logImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                        Color.white
                            .opacity(0.2)
                    }
                } else {
                    Image(uiImage: colorScheme == .light ? Resources.Images.ticket : Resources.Images.darkTicket)
                        .resizable()
                        .scaledToFill()
                    Color.white
                        .opacity(0.3)
                }
            } else {
                EmptyLogWidgetImageView()
            }
        }
    }
}

struct EmptyLogWidgetImageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Image(uiImage: colorScheme == .light ? Resources.Images.ticket : Resources.Images.darkTicket)
                .resizable()
                .scaledToFill()
            
            if colorScheme == .light {
                Color.white
                    .opacity(0.7)
            } else {
                Color.black
                    .opacity(0.5)
            }
        }
    }
}

struct EmptyLogWidgetTextView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let day: String
    let E: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(day + " " + E)
                        .font(.caption)
                        .foregroundColor(colorScheme == .light ? .black.opacity(0.8) : .white)
                    Text("기록을 남겨볼까요?")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
        }
    }
}

struct HasLogTextView: View {
    let day: String
    let E: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(E)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(day)
                    .font(.headline)
                    .foregroundStyle(.black)
            }
            Spacer()
        }
    }
}
