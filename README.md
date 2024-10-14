# 🎬 Film-in [앱스토어 링크](https://apps.apple.com/kr/app/film-in/id6736368535)
[![클릭 시 앱 다운로드 페이지로 이동](/images/download.png)](https://apps.apple.com/kr/app/film-in/id6736368535)
<br>
<div align=center>
    <img src="https://img.shields.io/badge/Swift-v5.10-F05138?style=plastic&logo=swift&logoColor=F05138">
    <img src="https://img.shields.io/badge/Xcode-v15.4-147EFB?style=plastic&logo=swift&logoColor=147EFB">
    <img src="https://img.shields.io/badge/iOS-16.4+-F05138?style=plastic&logo=apple&logoColor=#000000">
</div>
<br>
<p align="center">
    <img src="https://github.com/user-attachments/assets/b5ad5591-f554-43ba-b0dc-134c9ce41d80"> 
</p>

<p align="center"> 
    <img src="./images/main.gif" align="center" width="19%">
    <img src="./images/alarm.gif" align="center" width="19%"> 
    <img src="./images/person.gif" align="center" width="19%"> 
    <img src="./images/movie_list.gif" align="center" width="19%"> 
    <img src="./images/saved_list.gif" align="center" width="19%">   
</p>
<br>

# 앱 한 줄 소개
`🎬 본 영화 및 볼 예정인 영화를 간단하게 저장하는 앱, 근데 이제 알림을 곁들인.`

<br>

# 주요기능
- 사용자의 선호 장르에 대한 맞춤 영화 추천
- 최근 인기 작품, 현재 상영작, 개봉 예정작 확인
- 배우 / 제작진 상세 정보 확인
- 관람 예정 영화에 대한 알림 설정 및 푸시 알림 제공
- 저장된 본 영화 및 볼 영화를 날짜별로 필터링하여 확인
- 다국어 지원
    - 이 앱은 한국어, 영어, 일본어를 지원하며, 모든 주요 텍스트 및 영화 정보가 각 언어로 번역되어 있음.
    - 사용자의 설정된 국가에 맞게 언어가 번역되어 출력됨.

<br>

# 프로젝트 환경
- 인원
  - iOS 1명
- 기간
  - 2024.09.12 - 2024.10.01 (약 19일)
- 버전
  -  iOS 16.4 +

<br>

# 프로젝트 기술스택
- 활용기술
  - SwiftUI, Combine, Swift Concurrency
  - MVVM, Input-Output, Clean Architecture
- 라이브러리

|라이브러리|사용목적|
|-|-|
|Realm|Local DB 구축|
|Moya|추상화된 네트워크 통신 활용|
|PopupView|간편한 팝업 UI 구성|
|Kingfisher|이미지 로드 및 캐싱 처리|
|YouTubePlayerKit|간편한 YouTube Player UI 구성|
|Firebase Crashlytics|앱 안정성 개선|
<br>

# 앱 아키텍쳐
<p align="center"> 
    <img src="./images/architecture.png" align="center" width="90%"> 
</p>

> MVVM(Input/Output) + Clean Architecture
- Input/Output 패턴을 활용하여 단방향 데이터바인딩
- ViewModel, Service, Repository 로 나눠지는 역할에 따른 로직 모듈화
- Router 패턴을 활용하여 반복되는 네트워크 작업을 추상화
- DIP(의존성 역전 원칙)을 준수
  - 추상화된 Protocol을 채택하여 객체의 생성과 사용을 분리
  - 이를 통하여 하위모듈에서 구현체가 아닌 추상화된 타입에 의존 

<br>

# 트러블 슈팅

### 메모리 사용량을 줄이기 위한 노력

<details>
<summary>Kingfisher 사용 중 일어난 일</summary>
<div>



</div>
</details>

<br>

<details>
<summary>Lazy하게 View를 Load해보자</summary>
<div>



</div>
</details>

<br>

### Memory Leak

<details>
<summary>init이 된 후 deinit이 되지 않는 이슈</summary>
<div>



</div>
</details>
