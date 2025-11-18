//
//  CalendarWidget.swift
//  CalendarWidget
//
//  Created by 김정윤 on 11/10/25.
//

import WidgetKit
import SwiftUI
import RealmSwift

// MARK: Timeline Provider
struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), calendarDays: [], todayLog: nil, todayLogImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        let entry = CalendarEntry(
            date: Date(),
            calendarDays: getCalendarData(),
            todayLog: getTodayLog(),
            todayLogImage: getTodayLog().flatMap { DocumentManager.shared.loadImageForWidget(id: "\($0.id)") }
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let currentDate = Date()
        let calendarDays = getCalendarData()
        let todayLog = getTodayLog()
        let todayLogImage = todayLog.flatMap { DocumentManager.shared.loadImageForWidget(id: "\($0.id)") }

        var entries: [CalendarEntry] = []
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(CalendarEntry(
                date: entryDate,
                calendarDays: calendarDays,
                todayLog: todayLog,
                todayLogImage: todayLogImage
            ))
        }

        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
        completion(Timeline(entries: entries, policy: .after(nextMidnight)))
    }
    
    private func getCalendarData() -> [CalendarDay] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now),
              let monthFirstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday,
              let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count else {
            return []
        }
        
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        var calendarDays: [CalendarDay] = []
        
        // 시작 빈칸
        let emptyDays = (monthFirstWeekday - 1) % 7
        calendarDays.append(contentsOf: (0..<emptyDays).map { _ in
            CalendarDay(id: UUID().uuidString, day: 0, isCurrentMonth: false, isToday: false, recordId: nil)
        })
        
        // 실제 날짜
        for day in 1...daysInMonth {
            let dateComponents = DateComponents(year: currentComponents.year, month: currentComponents.month, day: day)
            let isToday = (dateComponents == todayComponents)
            
            var recordId: String?
            if let date = calendar.date(from: dateComponents),
               let logData = LogRepository.shared.getLogData(date) {
                recordId = "\(logData.id)"
            }
            
            calendarDays.append(CalendarDay(
                id: UUID().uuidString,
                day: day,
                isCurrentMonth: true,
                isToday: isToday,
                recordId: recordId
            ))
        }
        
        return calendarDays
    }
    
    private func getTodayLog() -> Log? {
        let today = Calendar.current.startOfDay(for: Date())
        return LogRepository.shared.getAllLogs().first { log in
            Calendar.current.startOfDay(for: log.visitDate) == today
        }
    }
}

// MARK: Models
struct CalendarDay: Identifiable {
    let id: String
    let day: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let recordId: String?
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let calendarDays: [CalendarDay]
    let todayLog: Log?
    let todayLogImage: UIImage?
    
    var day: String { (todayLog?.visitDate ?? date).formattedDay }
    var E: String { (todayLog?.visitDate ?? date).formattedE }
    var hasLog: Bool { todayLog != nil }
}

// MARK: Main Widget View
struct CalendarWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: CalendarEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallCalendarView(entry: entry)
        case .systemLarge:
            CalendarLargeView(entry: entry).padding(8)
        default:
            Text("Small/Large 사이즈만 지원됩니다")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: Small View (iOS 16 이하)
struct SmallCalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    var entry: CalendarEntry
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                backgroundImage
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // 텍스트
                VStack(alignment: .leading) {
                    if entry.hasLog {
                        HasLogTextView(day: entry.day, E: entry.E).padding()
                        Spacer()
                    } else {
                        EmptyLogWidgetTextView(day: entry.day, E: entry.E)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    private var backgroundImage: some View {
        if entry.hasLog {
            if let image = entry.todayLogImage {
                ZStack {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                    Color.white.opacity(0.2)
                }
            } else {
                ZStack {
                    Image(uiImage: isDarkMode ? Resources.Images.darkTicket : Resources.Images.ticket)
                        .resizable().aspectRatio(contentMode: .fill)
                    Color.white.opacity(0.3)
                }
            }
        } else {
            EmptyLogWidgetImageView()
        }
    }
    
    private var isDarkMode: Bool { colorScheme == .dark }
}

// MARK: Large View
struct CalendarLargeView: View {
    let entry: CalendarEntry
    @Environment(\.colorScheme) var colorScheme
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private var isDarkMode: Bool { colorScheme == .dark }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(monthYearString(from: entry.date))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : .primary)
                Spacer()
            }
            .padding(.bottom, 20)

            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(weekdayColor(weekday))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(entry.calendarDays) { day in
                    CalendarDayCellView(day: day)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
    
    private func weekdayColor(_ weekday: String) -> Color {
        if weekday == "토" { return .blue }
        if weekday == "일" { return .red }
        return isDarkMode ? .white.opacity(0.7) : .secondary
    }
}

// MARK: Calendar Day Cell
struct CalendarDayCellView: View {
    let day: CalendarDay
    var isCompact: Bool = false
    @Environment(\.colorScheme) var colorScheme
    private var isDarkMode: Bool { colorScheme == .dark }
    private var overlayColor: Color {
        day.isToday ? Resources.Colors.primaryColor.opacity(0.4) : (isDarkMode ? Color.black.opacity(0.4) : Color.white.opacity(0.4))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let recordId = day.recordId {
                    // 이미지가 있는 날
                    Group {
                        if let image = loadImage(recordId: recordId) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(uiImage: isDarkMode ? Resources.Images.darkTicket : Resources.Images.ticket)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(overlayColor)
                    }
                    .opacity(day.isCurrentMonth ? 1 : 0.3)
                    
                    Text("\(day.day)")
                        .font(.system(size: isCompact ? 10 : 12, weight: day.isToday ? .bold : .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .opacity(day.isCurrentMonth ? 1 : 0.3)
                } else if day.day != 0 {
                    ZStack {
                        // 이미지가 없는 날
                        Text("\(day.day)")
                            .font(.system(size: isCompact ? 10 : 12, weight: .medium))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .opacity(day.isCurrentMonth ? 1 : 0.3)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(overlayColor)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func loadImage(recordId: String) -> UIImage? {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupInfo.appGroupID),
              let image = UIImage(contentsOfFile: container.appendingPathComponent("popuplog/\(recordId).jpg").path) else {
            return nil
        }
        
        let targetSize: CGFloat = isCompact ? 100 : 150
        let scale = min(targetSize / image.size.width, targetSize / image.size.height, 1)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized?.jpegData(compressionQuality: 0.3).flatMap(UIImage.init) ?? resized ?? image
    }
}

// MARK: Small Widget Helper Views
struct EmptyLogWidgetImageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Image("ticketDefaultImage")
                .resizable().scaledToFill()
            (colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.6))
        }
    }
}

// MARK: EmptyLogWidgetTextView
struct EmptyLogWidgetTextView: View {
    @Environment(\.colorScheme) var colorScheme
    let day: String
    let E: String
    
    var body: some View {
        HStack {
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

// MARK: HasLogTextView
struct HasLogTextView: View {
    let day: String
    let E: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(E).font(.subheadline).foregroundColor(.black)
                Text(day).font(.headline).foregroundStyle(.black)
            }
            Spacer()
        }
    }
}

// MARK: iOS 17+ Content View
@available(iOS 17.0, *)
struct CalendarWidgetContentView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    var entry: CalendarEntry
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading) {
                    if entry.hasLog {
                        HasLogTextView(day: entry.day, E: entry.E)
                        Spacer()
                    } else {
                        EmptyLogWidgetTextView(day: entry.day, E: entry.E)
                    }
                }
                .containerBackground(for: .widget) {
                    if entry.hasLog {
                        if let image = entry.todayLogImage {
                            ZStack {
                                Image(uiImage: image).resizable().scaledToFill()
                                Color.white.opacity(0.2)
                            }
                        } else {
                            ZStack {
                                Image(uiImage: colorScheme == .light ? Resources.Images.ticket : Resources.Images.darkTicket)
                                    .resizable().scaledToFill()
                                Color.white.opacity(0.3)
                               
                            }
                        }
                    } else {
                        EmptyLogWidgetImageView()
                    }
                }
                
            case .systemLarge:
                CalendarLargeView(entry: entry)
                    .padding(8)
                    .containerBackground(for: .widget) { Color.clear }
                
            default:
                Text("Small/Large 사이즈만 지원됩니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .containerBackground(for: .widget) { Color.clear }
            }
        }
    }
}

// MARK: Widget Configuration
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            if #available(iOS 17.0, *) {
                CalendarWidgetContentView(entry: entry)
            } else {
                CalendarWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("팝업로그 달력")
        .description("오늘의 팝업 기록과 월간 캘린더를 표시합니다.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}
