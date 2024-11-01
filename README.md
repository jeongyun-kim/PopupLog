# 팝업로그 - 나만의 팝업스토어 기록장
<a href="https://apps.apple.com/kr/app/팝업로그/id6720723835">
	<img src="https://github.com/user-attachments/assets/dd8e6470-7966-49e3-ad87-0de5726221f8" width="120"/>
</a>

### ✏️ 개발 의도

팝업스토어를 다녀와 기록하는 용도로 많은 사람들이 블로그와 인스타그램 등을 이용하고 있습니다. 
<br>
하지만 어떤 분야의 팝업을 다녀왔고 이번 달, 혹은 저번달에 얼마나 자주 팝업스토어를 다녀왔는지 기록들을 한눈에 확인하기 어렵다는 단점이 있다고 생각했습니다. 
<br>
그리하여 저는 공유 목적이 아닌 오로지 개인의 기록에 중점을 두고 다녀온 팝업스토어에 대해 후기를 작성하고 이를 캘린더와 태그를 통해 보다 쉽게 조회하고 관리할 수 있는 앱을 개발하고자 하였습니다.

---

### ⭐️ 스크린샷

<table>
<tr>
  <td>메인</td>
  <td>기록 검색</td>
  <td>태그 관리</td>
  <td>상세보기</td>
  <td>통계</td>
</tr>
<tr line-height:0>
  <td><img src="https://github.com/user-attachments/assets/5f9ba948-fb02-4712-93b6-45f27ea196bc" width="120" height="250"></td>
  <td><img src="https://github.com/user-attachments/assets/6b27d1bb-bee2-4c3a-8ae9-af8754afcf75" width="120" height="250"></td>
  <td><img src="https://github.com/user-attachments/assets/2c2c961b-0fa9-40bb-9202-140cacbd9e67" width="120" height="250"></td>
  <td><img src="https://github.com/user-attachments/assets/4b217b5e-71a7-44f1-bf0f-d7be77e11340" width="120" height="250"></td>
  <td><img src="https://github.com/user-attachments/assets/56f0f986-0849-4c6c-91e6-a6177d46c51c" width="120" height="250"></td>
</tr>
</table>

---

### ✅ 개발환경

- iOS16.4+
- 1인 개발 | 2024.09.16~09.30

---

### 👩🏼‍💻 주요 기술

- UI : SwiftUI, UIKit, SnapKit, FSCalendar, MCEmojiPicker, SwiftyCrop
- Database : Realm
- Network : Alamofire
- Reactive : Combine
- Design Pattern: Singleton, Input-Output, MVVM, Repository
- etc: Naver API, Swift Concurrency

---

### 📚 주요 기능

- 팝업스토어 후기 기록
- 기록 상세보기
- 캘린더를 통한 기록 조회
- 제목을 통한 기록 검색
- 태그 관리
- 차트를 통한 최근 6개월간의 기록 개수 조회
- 건의하기

---

### 🧐 개발 포인트

- 사용성 향상을 위한 필수값에 대한 검증 및 명확한 표기
- 사용자 경험 개선을 위해 선택 날짜에 기록이 없거나 장소 검색결과가 없을 때, 시각적 피드백 제공
- 사용자 경험 향상을 위해 건의하기(이메일 전송) 구현
- 향상된 사용자 경험을 위한 실시간 데이터 반영
- 이미지 추가 시, 비동기적으로 PhotosPickerItem을 Data로 변환하기 위한 Swift Concurrency 활용
- 반응형 프로그래밍 및 비동기 처리를 위한 Combine 활용
- Instruments - Leaks를 활용한 메모리 누수 방지
- 재사용성과 유지보수성을 위한 Repository Pattern을 활용한 Realm 데이터 관리
- Realm 비효율성 감소를 위한 Filemanager를 활용한 이미지 저장
- 유지보수성을 위해 네트워크 코드 Singleton Pattern으로 구성
- 불필요한 View Initialize를 방지하기 위한 LazyNavigationView 활용
- iOS17 이상, 미만에 따라 각 버전에 따른 처리를 위한 ViewModifier 활용
- 재사용성과 유지보수성을 고려한 리소스 정의
- UI와 비즈니스 로직의 분리를 통한 유지보수성 향상을 위해 부분적 MVVM Pattern 적용
- 데이터의 흐름을 명확히 파악하고 추후의 유지보수성을 고려하여 ViewModel 내 Input-Output Pattern 적용
- 전역적인 상태 공유로 상태의 일관성 유지를 위해 EnvironmentObject 활용
- UIKit으로 구성된 뷰를 SwiftUI에서 활용하기 위한 UIViewControllerRepresentable 활용

---

### 🚨 트러블슈팅

**✓ 향상된 사용자 경험을 위한 데이터 실시간 반영 중 FSCalendar의 Cell이 실시간 업데이트 되지않는 문제**

**- 문제점**
<br>
SwiftUI의 경우 뷰에서 무언가 변화가 생겼을 때, 뷰를 새로 렌더링 하는 방식을 가지고 있습니다. 하지만 사용자의 기록 현황을 확인할 수 있는 CalendarView의 경우 UIViewController를 감싸고 있는 형태로, 기록이 생성되거나 삭제되더라도 `updateUIVIewController()`에 별도의 코드를 작성해 주지 않아 변경사항이 반영되지 않는 문제가 발생하였습니다.

**- 해결**
<br>
이러한 문제를 해결하기 위해 `updateUIVIewController()`의 호출 시점마다 Calendar를 갱신해 주도록 처리하였습니다. 하지만 이는 예상보다도 많은 호출이 일어나 불필요한 애니메이션이 보여짐과 동시에 동기화가 불필요한 시점에도 갱신이 일어나며 쓸데없는 자원이 낭비되는 또 다른 문제가 발생하였습니다. 
<br>
그리하여 데이터가 변경되거나 삭제되었을 때에만 Reload 하도록 UIViewControllerRepresentable 내에 @Binding 값을 정의해 주어 캘린더를 업데이트해줘야 하는 시점을 Bool 값으로 구분해 주고자 하였습니다. 그리고 현재 값이 true 라면 Reload 해주고, 바로 다음에 불필요한 갱신이 일어나지않도록 값을 변경해 주는 과정을 거쳤습니다. 이를 통해 필요한 시점에만 변경사항을 반영해 줄 수 있었습니다. 

```swift
struct FSCalendarViewControllerWrapper: UIViewControllerRepresentable {
    @ObservedObject var vm: CalendarViewModel
    @Binding var detent: PresentationDetent
    @Binding var reloadCalendar: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        FSCalendarViewController(vm: vm)
    }
    
    // - BottomSheet 높이 변할 때마다 달력의 형태도 변경
    // - 상세뷰에서 편집 후 이미지 변경 시, 바로 썸네일 반영되도록 calendar.reloadData()
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let vc = uiViewController as? FSCalendarViewController else { return }
        // Calendar 갱신 여부 보내기 
        vc.reloadCalendar(reloadCalendar) 
	      ... 
    }
    
    class FSCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
        init(vm: CalendarViewModel) {
        ...
		    // Calendar Reload 갱신해야한다면 Reload -> Trigger false 처리  
		    func reloadCalendar(_ reload: Bool) {
		            DispatchQueue.main.async {
		                if reload {
		                    self.calendar.reloadData()
		                    self.vm.action(.reloadCalendarTrigger(reload: false))
		                }
		            }
		      }
}
```
<br>

**✓ FullScreenCover로 감싸진 View로의 데이터 전달** 

**- 문제점**
<br>
특정 기록을 선택하였을 때, FullScreenCover로 설정된 뷰가 present되며 해당 기록의 상세정보를 확인할 수 있어야하는 상황에서 어떤 기록을 선택하든 보여지고 있는 기록들 중 첫번째 기록에 대한 상세정보만이 표출되는 문제가 발생하였습니다.
<br>

**- 해결**
<br>
원인을 찾기 위해 우선 데이터 전달이 제대로 일어나는지 확인해보았습니다. 그리고 `onTapGesutre()`에서 전달 데이터를 출력해본 결과, 선택한 기록의 데이터가 출력되었고 FullScreenCover 내 DetailView는 해당 데이터가 아닌 첫번째 기록의 데이터를 전달받고 있음을 알 수 있었습니다. 즉, 탭을 했을 때 제대로 된 데이터가 선택되고 있지만 FullCoverScreen 내 뷰가 가지는 데이터는 변화하지않고 첫번째 데이터로 고정되어 생기는 문제라고 판단하게 되었습니다.
<br>
그리하여 selectedLog라는 State 변수를 두어 기록을 선택할 때마다 DetailView로 전달해줄 기록으로 변경하고 이를 DetailView로 전달하도록 수정하였습니다. 

```swift
struct BottomSheetView: View {
    @ObservedObject var vm: CalendarViewModel
    @State private var isPresentingFullCover = false
    @State private var selectedLog: Log = Log(title: "", content: "", place: nil, visitDate: Date())
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 30) {
                    ForEach(vm.output.logList, id: \.id) { item in
                        rowView(proxy.size.width, item: item)
                            .onTapGesture {
                                selectedLog = item
                                isPresentingFullCover.toggle()
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $isPresentingFullCover, content: {
            LazyNavigationView(DetailView(log: $selectedLog))
        })
        .padding(.top, 32)
        .background(Resources.Colors.lightOrange)
    }
}
```
<br>

**✓ Filemanager 내 이미지 저장을 위한 UIImage 활용**

**- 문제점**
<br>
UIKit에서는 UIImage → Data 를 통해 Filemanager에 이미지를 저장할 수 있었지만 SwiftUI에서는 Image를 FileManager로 저장하는 방법을 찾지 못하였습니다. 
그리하여 Image → UIImage 방식으로 이미지를 변환한 후, 저장 시 해당 UIImage를 활용하려고 하였으나 본래 이미지의 크기가 아닌 임의로 설정해준 크기로만 이미지를 변환할 수 있다는 또다른 문제가 있었습니다.

```swift
extension Image {
    func asUIImage() -> UIImage? {
        // SwiftUI View를 UIKit의 UIView로 변환할 뷰
        let controller = UIHostingController(rootView: self)

        // 뷰의 크기 설정 
        let size = controller.sizeThatFits(in: .init(width: 300, height: 300)) // 원하는 크기로 조정
        controller.view.frame = CGRect(origin: .zero, size: size)

        // 뷰의 레이어가 그려지게 
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 화면 업데이트 후 그려주기
        controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return uiImage
    }
}
```
<br>

**- 해결**
<br>
그리하여 PhotosPicker로 선택한 이미지가 변경될 때마다 PhotosPickerItem을 Data로 1차 변환하고 이를 UIImage로 2차 변환해주는 과정을 거쳐 각 이미지의 크기에 맞는 UIImage를 가져올 수 있었습니다.

그리고 뷰에서는 해당 UIImage를 사용하여 보여준 후, 사용자가 기록을 저장할 때에 그 UIImage를 활용해 이전과 같은 방식으로 Filemanager 내 이미지를 저장해줄 수 있었습니다.

```swift
// ImageOnChangeWrapper.swift
// - pickerItem: 받아온 이미지 
// - completionHandler: 변환 후 이미지 실어보내기
private func getUIImage(_ pickerItem: PhotosPickerItem?, completionHandler: @escaping (UIImage) -> Void) {
	guard let pickerItem else { return }
	Task {
	// 1차 변환: PhotosPickerItem => Data
		if let imageData = try? await pickerItem.loadTransferable(type: Data.self) {
		  // 2차 변환: Data => UIImage
	    if let image = UIImage(data: imageData) {
		    // Main으로 UIImage 보내기 
         DispatchQueue.main.async {
            completionHandler(image)
		     }
	     }
   }
	   else {
       print("Failed Get UIImage")
     }
	}
}
```

---

### 👏 회고

**- 사용자 편의성 개선**
<br>
사용자의 편의성을 더욱 생각하려고 노력하였던 앱이라고 생각합니다. 그리하여 출시 전후로 받은 동료분들의 피드백을 바탕으로 1차 업데이트를 진행하기도 하였습니다.  개발자이기는 하지만 언제나 사용자의 관점에서 바라보도록 더욱 노력해야할 것 같습니다. 이후에는 태그를 통한 기록 모아보기, 다크모드 대응 등 다양한 기능을 추가함으로써 앱의 활용성을 높이고 싶습니다.
<br>

**- TCA를 활용한 리팩토링의 필요성**
<br>
SwiftUI + MVVM을 적용해보며 UIKit와 달리 (SwiftUI의 DataBinding의 흐름을 고려하였을 때) 이러한 방식이 적합한 것인지에 대한 의문이 들었던 것 같습니다. 이후에는 단방향 데이터 흐름구조의 TCA에 대해 학습하여 리팩토링을 진행해보고 싶습니다.

<br>
