# chatapp

使用 Flutter Firebase 建構聊天室 APP
通過 firebase 建構即時聊天室，主要會用到 firebase 中的以下功能：
1. Authentication 身份驗證功能 - 用戶登入、登出、註冊、判斷當前用戶是否登入等等
2. Storage 文件存儲功能 - 保存與獲取圖片連結以顯示用戶頭像
3. Cloud Firestore 雲端資料庫 - 保存/獲取訊息、用戶資訊
4. Messaging 應用程式通訊 - 發送推播通知到設備上
5. Functions 函式 - 撰寫客製化函示，監聽資料庫變化以執行推播通知

## 建立 Flutter 專案

建立一個名為 chatapp 的專案：
`flutter create chatapp --org com.wangxuan`
>建立專案時加上 --org com.domain 可以預先設定 app ID 前綴
>這邊要注意 applicationId 限制不能帶有 **`_`**
>另外 flutter 專案名稱限制不能使用 **英文大寫** 與 **`-`**

## 建立 Firebase 專案

開啟 [firebase 官網](https://firebase.google.com/) 登入 google 帳號並新增一個專案
>免費版的 firebase 最多只能建立三個專案
>想繼續免費建議創新的 google 帳號

按照步驟依序設置好專案名稱、選擇是否開啟 google 分析(該專案用不到可不開)、選擇國家，
接著等待專案建立完成

### 新增 Android 應用程式

專案建立完成後會自動跳轉到專案總覽頁面，
此時於專案名稱下方可以點擊新增應用程式，
點選新增 Android 應用程式：

1. **註冊應用程式**
從 chatapp 專案中的 `/android/app/build.gradle` 裏面找到 `applicationId`，將其填入

2. **進入下載設定檔案**
按照說明，下載檔案 `google-services.json` 並將該檔案新增到 `/android/app` 中

3. **進入新增 Firebase SDK**
按照說明，開啟 `/android/build.gradle` 檔案，確認 `buildscript` 與 `allprojects` 中是否都有 `google()` 存在
並在 `buildscript` 中的 `dependencies` 裡面添加 `classpath 'com.google.gms:google-services:4.3.15'`

4. **完成建立**

### 新增 IOS 應用程式

完成建立 Android 應用程式後會返回專案總覽頁面，
一樣從專案名稱下方點擊新增 IOS 應用程式：

1. **註冊應用程式**
從 chatapp 專案中的 `/ios/Runner.xcodeproj/project.pbxproj` 裏面找到 `PRODUCT_BUNDLE_IDENTIFIER`，將其填入(應該與 Android 中的 `applicationId` 一致)

2. **進入下載設定檔案** 
按照說明，下載檔案 `GoogleService-Info.plist` 並將該檔案新增到 `/ios/Runner` 中

3. **直接點擊左上角 x** 跳出剩下步驟
由於我們要使用 `Flutter Firebase SDK`，所以『新增 Firebase SDK』與『初始化程式碼』步驟直接略過

## 設置 Firebase + Flutter

請參考：https://firebase.flutter.dev/docs/overview

開啟終端機並 cd 到稍早建立的 flutter 專案 chatapp 資料夾中：
1. 執行命令： `flutter pub add firebase_core` 安裝 firebase_core
2. 執行命令： `curl -sL https://firebase.tools | bash` 安裝 Firebase CLI
3. 執行命令： `firebase login` 登入 firebase 帳號
4. 執行命令： `dart pub global activate flutterfire_cli` 啟用 flutterfire_cli
>假設出現錯誤導致無法進行，請參考[此問答](https://stackoverflow.com/questions/70320263/the-term-flutterfire-is-not-recognized-as-the-name-of-a-cmdlet-function-scri)
>並於解決問題後再次執行命令 `dart pub global activate flutterfire_cli`
5. 執行命令：`flutterfire configure`
6. 依序選擇稍早已建立好的 firebase 專案、選擇開好的應用程式(IOS、Android)
7. 回到 VS Code 中，進入 `main.dart` 檔案，引入 firebase_core 與 `firebase_options.dart`
8. 將 main 函式改為：
    ```javascript=
    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    }
    ```

## 安裝與使用 Cloud Firestore(保存與獲取訊息、用戶資訊)

請先於專案項目 chatapp 中，執行命令： `flutter pub add cloud_firestore` 進行安裝 cloud_firestore

* NOTE:如果你是使用 IOS 或 macOS，在首次啟動模擬器時將會耗時非常久的時間(可能要幾個小時)，可參考[官方建議](https://firebase.flutter.dev/docs/firestore/overview#4-optional-improve-ios--macos-build-times)以及 [GitHub READEME.md](https://github.com/invertase/firestore-ios-sdk-frameworks#usage)進行處理：
  1. 開啟 `/ios/Podfile` 檔案於 `target 'Runner' do` 添加 `pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '8.15.0'`
  2. 開啟終端機，cd 至 ios 資料夾中，運行命令 `pod install`
  3. 如出現 `CocoaPods could not find compatible versions for pod "FirebaseFirestore":` 錯誤消息，請查看 `Firebase/Firestore (= 10.7.0) was resolved to 10.7.0,`
  4. 將 `/ios/Podfile` 檔案中的 `:tag => '8.15.0'` 更改為 `:tag => '10.7.0'`(請藉由上一步看到的數字將 tag 改為該版本號)
  5. 再次執行命令 `pod install`，並啟動模擬器即可。
* NOTE:如果在啟動 Android 模擬器時，出現錯誤`Error while merging dex archives: The number of method references in a .dex file cannot exceed 64K`，可參考[官方說明](https://firebase.flutter.dev/docs/manual-installation/android#enabling-multidex)，啟用`Multidex`：
  1. 開啟 `/android/app/build.gradle` 檔案
  2. 於 `defaultConfig` 中添加一行 `multiDexEnabled true`
  3. 於 `dependencies` 中添加一行 `implementation 'com.android.support:multidex:1.0.3'`
  4. 再次重新啟動模擬器即可。

接著進入 firebase 專案總覽處，於左側選單找到 Firestore Database 啟用資料庫
1. 選擇 test mode
2. 選擇國家(有台灣可選了耶！)
3. 點擊完成按鈕等待完成後進入資料頁面
4. 點擊『新增集合』，設置集合 ID 為 `chats`
5. 於文件 ID 處點擊『自動產生的 ID』，接著刪掉下方欄位，點擊儲存
6. 於 `chats` 的右側再次點擊『新增集合』，設置集合 ID 為 `messages`
7. 於文件 ID 處點擊『自動產生的 ID』，接著於欄位設置名稱為`text`，類型`string`，值`Hi, there!`，點擊儲存

最後即可回到 flutter 專案 chatapp 中開始使用 Firestore Database 中的數據
```dart=
// 獲取數據的方式：
StreamBuilder( // 使用 flutter 提供的 StreamBuilder 小部件自動根據數據進行 UI 更新，與 FutureBuilder 小不見得用法相似，僅需傳入 builder 與 stream 即可
  builder: (context, snapshot) => ListView.builder(
    itemBuilder: (context, index) => snapshot.connectionState == ConnectionState.waiting
        ? const LinearProgressIndicator()
        : Container(
            padding: const EdgeInsets.all(10),
            child: Text(snapshot.data?.docs[index]['text']), // 主要通過 snapshot.data 獲取 stream 的數據
          ),
    itemCount: snapshot.data?.docs.length,
    padding: const EdgeInsets.all(10),
  ),
  stream: FirebaseFirestore.instance.collection('chats/XRB18xKXPbnR87LLh3mq/messages').snapshots(), // 傳入 Firestore 中的 messages 集合快照
),

// 添加數據的方式：
floatingActionButton: FloatingActionButton( // 新增一個觸發事件用的按鈕
  child: const Icon(Icons.add),
  onPressed: () { // 點擊按鈕後執行
    FirebaseFirestore.instance // 通過 FirebaseFirestore.instance
        .collection('chats/XRB18xKXPbnR87LLh3mq/messages') // 取得 Firestore 中的 messages 集合
        .add({ // 傳入物件，以 key-value 的形式增加數據資料
          'text': 'add new line to test.'
        })
    });
  },
),
```

## 安裝與使用 Firebase Authentication(登入、註冊、登出、獲取當前使用者)

首先於專案項目 chatapp 中，執行命令： `flutter pub add firebase_auth` 進行安裝 firebase_auth

接著進入 firebase 專案總覽處，於左側選單找到 Authentication 點擊開始使用
並於 `Sign-in method` 中點選『電子郵件/密碼』，啟用並儲存即可

最後回到 flutter 專案 chatapp 中，先建立一個用於登入/註冊的表單頁面 `auth.dart` 檔案([可參考](https://hackmd.io/WHaymHAzSwS9C0Xkj5Vc_A#%E8%A1%A8%E5%96%AE%E5%B0%8F%E9%83%A8%E4%BB%B6-Form))
1. 新增 Form 小部件、設置 GlobalKey() 為 formkey
2. 新增四個 TextFormField 小部件，分別用於輸入『暱稱、電子郵件、密碼、確認密碼』
3. 設置 TextFormField 小部件中的 keyboardType、validator、onSaved 等重要內容
4. 新增登入與註冊按鈕，點擊後調用登入或註冊的函數
5. 建立 submit 函數用來登入或註冊，裡面先通過 `_formKey.currentState!.validate()` 判斷是否完成驗證
6. 執行 `_formKey.currentState!.save();` 讓 onSaved 事件被觸發
7. 將 onSaved 中保存的『暱稱、電子郵件、密碼』以及『當前為登入或註冊』當為參數傳遞並發送登入或註冊請求

*submit 函數中發送登入與註冊請求的方法可參考[官方文件](https://firebase.google.com/docs/auth/flutter/password-auth)

### FirebaseAuth 登入與註冊請求範例
```dart=
final _auth = FirebaseAuth.instance;
void sendAuthRequest(bool isSignup, String name, String email, String password) async {
  try {
    dynamic authResult;
    if (isSignup) { // 判斷當前為登入還是註冊
      authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password); // 使用信箱與密碼創建帳號
      FirebaseFirestore.instance.collection('users').doc(authResult.user.uid).set({ // 使用 FirebaseFirestore 建立 users 集合，並設置文件 id 為 user.uid
        'username': name, // 於文件中新增欄位 username 為 name
        'email': email, // 於文件中新增欄位 email 為 email
      });
    } else {
      authResult = await _auth.signInWithEmailAndPassword(email: email, password: password); // 登入帳號
    }
  } on FirebaseAuthException catch (err) { // 處理錯誤
    var errMsg = '系統出現問題，請重新啟動。';
    if (err.code == 'invalid-email') {
      errMsg = '無效的電子信箱！';
    } else if (err.code == 'user-disabled') {
      errMsg = '此帳號已被管理員禁用！';
    } else if (err.code == 'user-not-found') {
      errMsg = '帳號不存在，請先建立帳號。';
    } else if (err.code == 'wrong-password') {
      errMsg = '密碼錯誤！';
    } else if (err.code == 'email-already-in-use') {
      errMsg = '此帳號已被使用。';
    } else if (err.code == 'operation-not-allowed') {
      errMsg = '不允許操作！';
    } else if (err.code == 'weak-password') {
      errMsg = '密碼強度不足。';
    } else if (err.code == 'too-many-requests') {
      errMsg = '請求次數過多，請稍後再試。';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      elevation: 0,
      content: Text(errMsg),
    ));
  }
}
```
>error.code 列表可從[此連結](https://firebase.google.com/docs/reference/js/v8/firebase.auth.Auth#createuserwithemailandpassword)與[此連結](https://firebase.google.com/docs/reference/js/v8/firebase.auth.Auth#signinwithemailandpassword)中尋找

假設完成後無法正確進行登入或註冊，請嘗試重啟模擬器
>如於重啟模擬器時發生錯誤，請參考[此連結](https://stackoverflow.com/questions/67443265/error-regarding-undefined-method-map-for-nilnilclass-for-flutter-app-cocoap)進行修復(誠摯感謝估狗)

### FirebaseAuth 關於當前用戶的幾個常用方法

1. 判斷當前是否有用戶登入：`FirebaseAuth.instance.authStateChanges()` 假設 hasData 則表示當前有用戶登入
2. 取得當前用戶的 id：`FirebaseAuth.instance.currentUser?.uid`
3. 設置當前用戶的名稱：`FirebaseAuth.instance.currentUser?.updateDisplayName(name)`
4. 登出：`FirebaseAuth.instance.signOut()`
>其他相關資訊可查看[官方文件](https://firebase.google.com/docs/auth/flutter/manage-users)說明

## 安裝與使用 Firebase Storage(保存與顯示用戶頭像)

首先於專案項目 chatapp 中，執行命令： `flutter pub add firebase_storage` 進行安裝 firebase_storage

接著進入 firebase 專案總覽處，於左側選單找到 Storage 點擊開始使用
選用 test mode 並選取 Cloud Storage 位置並按下完成即可。
>這邊要注意，免費版本只能使用一個 bucket (值區)，
>假設原本的 Firebase 專案已經有使用 Storage 功能，建議重新申請一個 Firebase 帳號
>也可以選擇將 Firebase 升級為付費版本，建立新的 bucket (值區)：
>在 Storage 頁面的右上角有三個點點，點選後就會看到刪除與新增值區的選項

於 chatapp 中，我們為每個使用者添加頭像，
首先需要在註冊頁面中，新增關於圖片的函數，可以使用 image_picker 套件

通過命命： flutter pub add image_picker 安裝 image_picker 套件
安裝後針對 IOS 設置好 ios/Runner/Info.plist 檔案([參考](https://pub.dev/packages/image_picker#ios))
主要添加內容如下：
```plist=
<key>NSCameraUsageDescription</key>
<string>Places App need to use Camera.</string> // 輸入為什麼要存取相機
<key>NSPhotoLibraryUsageDescription</key>
<string>Places App need to use PhotoLibrary.</string> // 輸入為什麼要存取照片庫
```
>通常都是一個 key配一個 value，在新增上方四行時，
>需注意不要將其放置在某組 key 與 value 的中間。

完成後在註冊的表單中建立一個圖片預覽用的 CircleAvatar 小部件，
再新增一個點擊後可以開啟照片庫用的 IconButton 按鈕小部件，並為其添加一個用來獲取圖片的 onPressed 用函數：
```dart=
void _pickImage() async {
  final imageFile = await ImagePicker().pickImage(
    source: ImageSource.gallery, // 開啟照片庫
  );
  if (imageFile == null) { // 如果沒有選取圖片則返回
    return;
  }

  setState(() { // 新增一個 _previewImage 參數用於存放要顯示的預覽圖
    _previewImage = imageFile.path;
  });
  
  widget.imagePickFn(File(_previewImage)); // 呼叫外部函數用於傳遞圖片檔案給外部使用
}
```
>這邊是將圖片有關的小部件自己封裝成一支 user_image_picker.dart 檔案
>而外部則是主要的註冊表單 auth_form.dart 文件，於提交表單的 submit 函數中傳入用戶上傳的圖片

接著針對註冊的函數，原先在幫用戶建立帳號之後，會一併新增用戶的資料到 users 集合中
當時新增的資料為用戶 id 以及用戶名，
現在為其多新增一個欄位 user_image_url 用來存放圖片，
註冊函數應更新為：
```dart=
import 'package:firebase_storage/firebase_storage.dart'; // 引入 firebase_storage

void _submitAuthForm(bool isSignup, String name, String email, String password, File? userImageFile) async { // 多傳入圖片參數
  try {
    dynamic authResult;
    if (isSignup) {
      authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      final ref = FirebaseStorage.instance // 使用 firebase_storage
          .ref() // 創建飲用
          .child('user_image') // 新增文件夾 user_image
          .child('${_auth.currentUser!.uid}.jpg'); // 新增文件 ${_auth.currentUser!.uid}.jpg
      UploadTask uploadTask = ref.putFile(userImageFile!); // 將圖片檔案上傳為 user_image/${_auth.currentUser!.uid}.jpg
      String imgurl = await (await uploadTask).ref.getDownloadURL(); // 於上傳完成後獲取圖片連結

      FirebaseFirestore.instance.collection('users').doc(authResult.user.uid).set({
        'username': name,
        'email': email,
        'user_image_url': imgurl, // 新增欄位 user_image_url 存放圖片連結
      });
    } else { // 登入函數不動
      authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
  } on FirebaseAuthException catch (err) {
    // 處理錯誤並顯示 SnackBar
  }
}
```
接著就可以通過 Firestore 獲取 users 集合中存放的圖片來顯示用戶頭像：
```dart=
FutureBuilder( // 使用 FutureBuilder 小部件
  builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (snapshot.data!.data()!['user_image_url'] != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar( // 新增 CircleAvatar 小部件用於顯示用戶頭像
                  backgroundImage: NetworkImage(snapshot.data!.data()!['user_image_url']),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data!.data()!['username'],
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ],
            ),
          ],
        ),
  future: FirebaseFirestore.instance.collection('users').doc(userId).get(), // 使用 Firestore 提供的方法，針對 users 集合進行資料獲取
),
```

## 安裝與使用 Cloud Messaging(向手機發送推播通知)

首先於專案項目 chatapp 中，執行命令： `flutter pub add firebase_messaging` 進行安裝 firebase_messaging

### 接著針對 Android 進行設置

1. 確保 `android/build.gradle` 文件中有：
```
dependencies {
    classpath 'com.android.tools.build:gradle:7.2.0'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    classpath 'com.google.gms:google-services:4.3.15'
}
```
2. 確保 `android/app/build.gradle` 文件中有 `apply plugin: 'com.google.gms.google-services'`
3. 確保你的設備有安裝 Google Play 服務(可以通過 Android Studio 開啟 "AVD Manager" 確認模擬器是否擁有 Google Play 的播放鍵 icon 即可)
4. (此項可選)於 `android/app/src/main/AndroidManifest.xml` 文件中，往`<activity>`標籤中新增：
```
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

### 測試 Android 是否可成功接收推播通知

1. 在 chatapp 中關閉當前執行中的設備，並使用 Android 設備重新啟動服務
2. 進入 Firebase Messaging 中，點擊“建立第一個廣告活動”
3. 選擇“Firebase 通知訊息”進行建立
4. 輸入標題、文字，點擊下一步
5. 選取 Android 應用程式(下拉選項應該有你註冊的 IOS 與 Android 可選，點擊下一步
6. 排定時間設為現在，直接點擊右下角審查，點擊發表
7. 開啟執行中的 Android 設備，將 chatapp 整個關掉(螢幕網上滑動並將應用程式整個上滑移除)
8. 接著開啟 Android 的設定，點擊通知，點擊應用程式設定，將 chatapp 開啟通知
9. 回到 Firebase Messaging 中再次新增活動，即可看到通知(有時候需要幾分鐘的時間才會收到通知，可以多新增活動幾次)

### 針對 IOS 進行設置

1. 將 Apple 開發者帳號升級為付費版本
    1. 登入 Apple Developer 帳號
    2. 進入 account 頁面，將帳號升級為“蘋果開發者計劃”(應該會出現在 account 頁面問你是否要升級)
    3. 輸入個人資料進行購買計劃(費用是一年 99 美金)
    4. 等待審核通過會寄送電子郵件通知啟用
2. 下載 APNs key 檔案
    1. 於 Apple Developer 頁面最下方點擊進入 Certificates, IDs, & Profiles 頁面
    2. 於左側選單點擊進入 keys 頁面，點擊加號新增 key
    3. 設置 Key Name 並勾選 APNs
    4. 點擊右上角 Continue，接著確認配置無誤繼續點擊 Confirm
    5. 下載 key 檔案(注意：該檔案僅能下載一次，若遺失檔案就只能刪除現有的 key 並重新建立一個 key 了)
3. 設置 App ID
    1. 回到 Certificates, IDs, & Profiles 頁面，點擊進入 Identifiers 頁面
    2. 點擊加號新增，選擇 App ID 點擊 Continue
    3. 輸入簡短的描述(FLutter Chat Example 之類即可)、填上 Bundle ID(於 `/ios/Runner.xcodeproj/project.pbxproj` 文件中可找到 PRODUCT_BUNDLE_IDENTIFIER)
    4. 往頁面下方滾動，確保有勾選 “Push Notifications” 後點擊右上角 Continue，確認配置無誤繼續點擊 Confirm
4. 設置 Xcode
    1. 用 Xcode 開啟 cahtapp/ios
    2. 點選 Runner 並於右側選單切換至 Signing & Capabilities
    3. 點擊 “＋Capability” 選擇 “Push Notifications”(點兩下啟用)
    4. 再次點擊 “＋Capability” 選擇 “Background Modes”(點兩下啟用)
    5. 於 “Background Modes” 中勾選 “Background fetch” 跟 “Remote notifications”
5. 上傳 APNs key 到 Firebase 專案中
    1. 於 Firebase 中點擊左上角專案總覽旁的齒輪，並點選專案設定，切換至 “雲端通訊”
    2. 往下滾到 “Apple 應用程式設定” 於 APN 驗證金鑰處點擊上傳，上傳步驟 2 下載的 .p8 檔案
    3. 輸入金鑰 ID(於 Certificates, IDs, & Profiles 頁面進入 keys 後可看到) 與團隊 ID(在 Certificates, IDs, & Profiles 頁面的右上角可看到)

### 測試 IOS 是否可成功接收推播通知

1. 在 chatapp 中關閉當前執行中的設備，並使用真實 iPhone 設備進行測試(IOS 模擬器無法提供測試)
2. 將 chatapp 中的 chat_screen.dart 更改為有狀態小部件
3. 撰寫程式碼要求獲取通知權限：
```dart=
class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final fbn = FirebaseMessaging.instance;
    fbn.requestPermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //...
  }
}
```
4. 進入 Firebase Messaging 中，點擊“建立第一個廣告活動”
5. 選擇“Firebase 通知訊息”進行建立
6. 輸入標題、文字，點擊下一步
7. 選取 Android 應用程式(下拉選項應該有你註冊的 IOS 與 Android 可選，點擊下一步
8. 排定時間設為現在，直接點擊右下角審查，點擊發表
9. 開啟執行中的 Android 設備，將 chatapp 整個關掉(螢幕網上滑動並將應用程式整個上滑移除)
10. 接著開啟 Android 的設定，點擊通知，點擊應用程式設定，將 chatapp 開啟通知
11. 回到 Firebase Messaging 中再次新增活動，即可看到通知(有時候需要幾分鐘的時間才會收到通知，可以多新增活動幾次)

## 安裝與使用 Firebase Functions

開啟 Firebase 介面，於左側選單點選 Functions
升級為付費版本(會涵蓋所有免費版本的權益，基本上用量爆掉才真的會跟你收費)
點擊開始使用，按照步驟於終端機輸入指令：
1. 先 cd 到 chatapp 專案項目中
2. 安裝 Firebase 工具： `npm install -g firebase-tools`
3. 啟動專案： `firebase init`
```
? Which Firebase features do you want to set up for this directory? Press Space to select features, then Enter to confirm your choices. 
Functions: Configure a Cloud Functions directory and its files
? Please select an option:
Use an existing project
? Select a default Firebase project for this directory:
flutter-chatroom-xxxxx (flutter-chatroom)
? What language would you like to use to write Cloud Functions? 
JavaScript
? Do you want to use ESLint to catch probable bugs and enforce style?
Yes
? Do you want to install dependencies with npm now? 
Yes
```
4. 開啟 chatapp/functions/index.js 進行程式碼撰寫([主要的程式碼寫法說明](https://firebase.google.com/docs/functions/firestore-events))：
撰寫 Functions 於發送訊息時觸發推播通知：
```javascript=
const functions = require("firebase-functions"); // 引入 firebase-functions
const admin = require("firebase-admin"); // 引入 firebase-admin

admin.initializeApp(); // 初始化應用程序

exports.myFunction = functions.firestore // 呼叫 firestore
  .document("chat/{message}") // 監聽 chat 集合中的內容
  .onCreate( (snap, context) => { // 當建立新的文件就觸發函數
    return admin.firestore().collection("users").doc(snap.data().user_id).get().then((data) => // 回傳觸發推播通知
      admin.messaging().sendToTopic("chat", { // 使用 admin.messaging() 發送推播通知，此處的 sendToTopic("chat") 則表示向特定主題發送
        notification: { // 傳入推播通知內容
          title: data.data().username, // 推播通知標題
          body: snap.data().text, // 推播通知描述
          clickAction: "FLUTTER_NOTIFICATION_CLICK", // 針對安卓設置的 key-value 為了確保點擊後可正確跳轉至 chatapp
        },
      }),
    );
  });
```
>如需設置主題，可於 `.dart` 中撰寫 `const fbm = FirebaseMessaging.instance;` 處的最後添加一行：
>`fbm.subscribeToTopic('chat');` => 'chat' 為主題的名稱
5. 部署 index.js 內容到 Functions：執行 `firebase deploy`
6. 測試：
    1. 用 VS Code 執行安卓模擬器開啟 chatapp 並登入或註冊一個帳號
    2. 將安卓模擬器的 chatapp 滑掉
    3. 用真實 iPhone 開啟 chatapp 並登入或註冊另一個帳號
    4. 從 iPhone 發送一則訊息，至 Functions 點擊 myFunction 的三個點點，選擇查看紀錄檔
    5. 進入 Google Cloud 查看紀錄檔案
        1. 假設出現錯誤 `Error: An error occurred when trying to authenticate to the FCM servers. Make sure the credential used to authenticate this SDK has the proper permissions....`
        2. 到 Google Cloud 中，從左色選單找到 API 和服務頁面
        3. 點擊 “＋啟用 API 和服務”
        4. 確認左上角的專案是 chat 專案
        5. 於 “搜尋 API 和服務” 欄位中輸入 “Cloud Messaging” 點擊啟用
        6. 再次於 iPhone 中傳送一則訊息，並查看紀錄檔
    6. 於紀錄檔中看到 “Function execution took 1579 ms, finished with status: 'ok'” 即可於安卓模擬器中接收通知
    7. 接著反過來將 iPhone 中的 chatapp 滑到後台
    8. 開啟安卓模擬器模擬器的 chatapp 發送一則消息
    9. 確認 iPhone 是否收到訊息

## 使用真實設備進行測試

1. 將 iPhone 使用 USB 的方式連結電腦，並依序點擊信任此裝置、輸入手機密碼等等
2. 進入 iPhone 的“設定>隱私權與安全性>開發者模式”將開發者模式打開，此時手機會要求你重新開機
3. 開啟電腦的 Xcode 應用程式，點擊 “Open a project or file” ，選擇想開啟的 Flutter 專案底下的 ios 資料夾
4. 在 Xcode 上方選單列中的 Device 中選擇你的 iPhone
5. 在 Xcode 左側選單中點選 Runner ，檢查 Signing 是否有選擇 Team (沒有的話就用自己的 apple ID 申請一個)
6. 在 Xcode 中點擊左上角的播放鍵進行 build
    a. 假設出現 “build failed” ，請開啟終端機 cd 到想開啟的 Flutter 專案目錄中，執行 `flutter clean` 再執行 `flutter build ios`
    b. 假設出現錯誤 “Error (Xcode): No profiles for 'com.example.xxxxApp' were found: Xcode couldn't find any iOS App Development” 則將 Team 下方的 Bundle Identifier 更新成唯一的值(比如加上自己的名字之類的)，再重新執行一次 `flutter build ios`
6. 完成後手機會出現 Flutter APP 的 icon，但開啟失敗，並顯示提示 “開發者不受裝置信任的通知”，此時請到手機的 “設定>一般>VPN與裝置管理” 將自己的開發者帳號設為信任
7. 再次回到 Xcode 中點擊一次播放鍵，即可成功開啟 APP 進行實測
>假設出現錯誤顯示“無法打開 iproxy，因為無法驗證開發人員”可參考[此問答](https://github.com/flutter/flutter/issues/42969)進行處理