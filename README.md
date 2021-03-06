# PodoMarket 포도마켓

>당근마켓 팬앱
>
> YouTube : https://youtu.be/0c7PVBdwEuk (포도마켓 Simulator Video)


### 1. 개발 기간 & 참여 인원 

* 2개월
* 첫 프로젝트이자 개인 프로젝트

### 2. 사용 기술 스택

* Swift 
* Firebase ( Remote Config / Authentication / FireStore / Storage )
* 카카오 우편번호 API

### 3. 프론트엔드

![front_end](https://user-images.githubusercontent.com/52398346/131097792-7cef0ba2-ab4f-47fd-aef3-2fb280afd4cc.png)

![screenshot1](https://user-images.githubusercontent.com/52398346/131113875-24709af2-7ca3-4c0b-b7d5-2716760a2e5e.png)

![screenshot2](https://user-images.githubusercontent.com/52398346/131113884-bd2f34ac-eb5f-46b1-aaef-844a4b876b90.png)

### 4. 백엔드

![back_end](https://user-images.githubusercontent.com/52398346/131097781-eba3a0a1-a965-49db-aa7b-fbb797c75739.png)

### 5. 핵심기능
<br/>

 - 동네 검색

 >카카오 우편번호 API를 사용하여 주소나 장소를 검색 후 나타난 주소를 선택하면 '동네이름'만 가져오도록 설정하였습니다.
 >
 >또한 닷홈 호스팅 서비스를 사용하여 url 주소를 설정하여 WebView에 로드되게 하였습니다.
 <br/>

 - 상품 업로드 

 >글 작성 처리 시 Firebase의 Storage에 상품 이미지를 업로드 한 후 이미지를 다시 url로 다운로드 받고
 >
 >이미지 url과 상품 정보 데이터를 Firestore Database에 업로드 하는 기능입니다.

<br/>

### 6. 프로젝트 문제 해결 방법
<br/>

 - 채팅 기능 -> 댓글 기능
>
> 가장 큰 이슈는 채팅 기능을 구현하는 것이었습니다. 2주정도 투자를 했었는데, 싱글톤에 대해 이해를 정확히 하지 못했고,
>
> 구글링과 유튜브 영상으로 찾았던 코드를 적용 시켜도 제대로 작동하지 않아서 애를 먹은 기억이 있습니다. 
> 
> 그래서 채팅 기능 대신 댓글 기능으로 바꾸었습니다. 
> 
>댓글 태그 기능 까지 구현했으나 태그된 유저에게 알림을 주는 것은 구현하지 못했습니다.
> 
>개발자 계정이 있어야 Firebase In-App Messaging 사용이 가능하기 때문입니다. 
>
>그래서 TableView와 segmented Control을 사용하여 NotificationView를 만들고 
>
>댓글이 달리거나 사용자가 태그된 상품 제목을 나타내는 기능을 만들었습니다.
>
>싱글톤 이해를 위해 채팅 기능은 단일 프로젝트로 공부 할 계획입니다.
<br/>

 - 동네 범위 설정 -> 동네 단일 설정
>
>당근 마켓처럼 동네를 지정하면 거리에 따른 동네 범위를 설정하고자 했습니다. 
>
>그러나 어디서부터 시작해야 할 지 몰라서 검색을 해보았으나 도움을 받을만한 글을 찾지 못했습니다.
> 
>그래서 범위에 따른 동네 범위 지정 대신 단일 동네 이름을 받아오는 기능으로 변경하여 진행하였습니다.
>
> 이를 위해 카카오 우편번호 API를 사용하여 주소를 받아올 때 '동네이름'만 분리되어 받아오게 하였습니다.

<br/>

### 7. 첫 프로젝트를 마치며

>비전공자로 국비지원 AOS/iOS 하이브리드 개발 과정을 수료하는 동안 기획 했던 프로젝트입니다.
>
>개인이고 또 처음 개발을 진행하다 보니, 처음 기획했던 기능들이 얄팍한 지식으로는 구현할 수 없게 되는 차질이 생기자 
>
>계속 변경하는 과정을 거치게 되어 생각했던 기간을 지키지 못했습니다. 
>
>그리고 더 그럴듯해 보이는 프로젝트를 만들고 싶은 욕심은 컸는데 실력이 안 따라 주는 게 가장 답답한 점이었습니다. 
>
>그래서 프로젝트를 개발은 멈추고 그 안에서 배워야 할 지식들을 알아보다 보니 많은 시간이 소요됐습니다. 
>
>사실 무엇을 적용해도 안되는 부분에서는 답답해서 공부를 손 놓은 적도 있습니다. 그리고 개인적인 일로 잠시 공부를 중단한 적도 있었지만, 
>
>시간이 지나 다시금 이 프로젝트를 진행한 후 느끼는 점은 저는 개발이 즐겁다는 것입니다. 
>
>또한 작은 이슈더라도 스스로 해결했을 때의 성취감이 좋았습니다.
>
>혼자 헤매며 배우는 과정에 많은 시간을 들였지만 이 시간들이 없었다면 개발자의 길을 가고 싶다는 확신을 못 가졌을 것이라 생각합니다. 
>
>이 프로젝트를 통해 가장 크게 얻은 점입니다.

