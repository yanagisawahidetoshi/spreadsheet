## 概要
前日（月曜の場合は金曜日）のスリープログの最初と最後を取得し、その時間をGoogle App Scriptに投げます。
Google App Script側では受け取った情報を基に対象のスプレッドシートに時間を記入します。


## 環境構築手順
### gemをインストール
```
bundle install
```

### chromeドライバインストール
Homebrewでchromeドライバをインストールします
```
brew install chromedriver
```

### config.ymlの修正

#### Googleアカウントの入力
自身のGoogleアカウントのmailとpasswordに入力
- mail
- password

#### スプレッドシートの入力
##### 対象のスプレッドシートのIDをbookIdに入力
スプレッドシートのIDは以下URLのXXXXXXXXの部分になります
```
https://docs.google.com/spreadsheets/d/XXXXXXXX/edit
```
##### 修正したいスプレッドシートのシート名をsheetNameに入力
対象のシート名を入力
- sheetName

## 実行
以下を実行するとchromeが自動で立ち上がり、googleアカウントにログイン後に{value::○○}と表示されれば正常に終了しているので
スプレッドシートで値が正常に入力されているか確認お願いします。

```
ruby spredsgeet.rb
```

これで問題なければcronなどで定期実行すれば自動化も可能です
