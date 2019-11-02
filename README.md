# フォトギャラリーのような複雑なView構造を伴うアプリのサンプル

こちらは、複雑なView構造をはじめ色々なエッセンスが詰め込まれているUIサンプルの実装例になります。

+ ①  UICollectionViewCell + ContainerViewを利用した画面
+ ②  Twitterのプロフィールページの様なスクロールに伴って画面が変化するアニメーション
+ ③  画面が拡大される＆引っ張って画面を閉じるカスタムトランジション

### 画面キャプチャ

![キャプチャ1](https://github.com/fumiyasac/ContainerViewInUICollectionView/blob/master/images/list_screen.png)

![キャプチャ2](https://github.com/fumiyasac/ContainerViewInUICollectionView/blob/master/images/detail_screen.png)

### 利用したライブラリ

Instagramの様なMosaicLayoutの構築や視差効果を伴うスクロールを利用した表現は、自前で実装をすると大変な部分でもあるので下記のライブラリを利用して構築しています。

+ [AnimatedCollectionViewLayout](https://github.com/KelvinJin/AnimatedCollectionViewLayout)
+ [Blueprints](https://github.com/zenangst/Blueprints)

### TwitterのUIトレースを試みる場合の参考資料

下記にポイントとなる ＆ 参考にすると良い部分についてまとめておく。見た目以上に面倒な部分が多い実装になりやすいので、その点にも気を配ること。

__【1. 基本的な構造に関する部分】__

UIScrollViewと連動した「ヘッダー部分にひっつくView要素」のヒントとなり得る部分。

+ [Keep Hero Banner Floating in UIScrollView - qbo - Medium](https://medium.com/@qbo/keep-hero-banner-floating-in-uiscrollview-ca32be46127)
+ [How to collapse a custom header view in iOS while scrolling](https://blog.usejournal.com/how-to-collapse-a-custom-header-view-in-ios-while-scrolling-5e0949c64ecd)

基本は「UIScrollView + UITableView」の組み合わせで実現する構造である！

+ [Twitterアプリのプロフィール風UI - Qiita](https://qiita.com/netetahito/items/11c97092f75b91af9804)

こちらはつなぎ目となる部分を「自然にスクロールさせる」ためのヒントとなり得る部分。

+ [swift - How to Make the scroll of a TableView inside ScrollView behave naturally - Stack Overflow](https://stackoverflow.com/questions/33292427/how-to-make-the-scroll-of-a-tableview-inside-scrollview-behave-naturally)

もちろん前提として「UIScrollViewDelegate」への理解は必須になります。

+ [【Swift4】UIScrollViewのデリゲート、スクロール開始・中・停止、ズーム開始・中・停止まとめ【iOS11】](https://program-life.com/724)
+ [UIScrollViewDelegate について - xykのブログ](http://xyk.hatenablog.com/entry/2017/03/09/134136)

__【2. 実際にトレースをした際の知見】__

細かな部分をシビアにこだわろうとすると、AutoLayoutやサイズの調整が大変になるので「どの部分がお互いに影響を及ぼし合っているのか？」を明確にすることに気をつける。

+ Article:
  [[Swift❤️] Implementing Twitter iOS App UI - @yipyipisyip - Medium](https://medium.com/@yipyipisyip/swift-%EF%B8%8F-implementing-twitter-ios-app-ui-74c8a8cd0ff3)
+ Code: 
  [GitHub - roytang121/iOS-TwitterProfile: Twitter-like Profile viewController with easy to use API](https://github.com/roytang121/iOS-TwitterProfile)

※ さらに見つけた実装例:

+ UIScrollViewとUITableViewの組み合わせ事例:
  + 記事: [Twitterアプリのプロフィール風UI](https://qiita.com/netetahito/items/11c97092f75b91af9804)
  + サンプル: [TwitterLikeUI](https://github.com/osanaikoutarou/TwitterLikeUI)
+ 画面を切り替える部分にライブラリを利用するのも良い案のようにも思います:
  + 記事: [タブスワイプで画面を切り替えるメニューUI](https://qiita.com/yysskk/items/fe4cdd58209384270ce3)
  + サンプル: [SwipeMenuViewController](https://github.com/yysskk/SwipeMenuViewController)

__【3. ライブラリを利用した実装の参考資料】__

このタイプのUIは自前で実装すると、派手にとっちらかりやすいものの代表例。特にStoryboardをなるべく活用して簡単に管理する方針にするためにライブラリを活用した実装へ寄せていく方針をとっても良さそうです。

+ 事例: 
  [MXParallaxHeaderとTabmanでTwitterのプロフィール画面のようなヘッダーとページングメニューをサクッと実装する](https://tech.recruit-mp.co.jp/mobile/post-18199/)

この記事で触れられているライブラリは下記の通りです。

+ [GitHub - maxep/MXParallaxHeader: Simple parallax header for UIScrollView](https://github.com/maxep/MXParallaxHeader)
+ [GitHub - uias/Tabman: ™️ A powerful paging view controller with interactive indicator bars](https://github.com/uias/Tabman)
+ [GitHub - rechsteiner/Parchment: A paging view controller with a highly customizable menu ✨](https://github.com/rechsteiner/Parchment/)

また、Star数は少ないが下記のようなライブラリもあるので、必要な部分にForkを入れて利用するのも手段かと思います。

+ [GitHub - cillyfly/MXScroll: Easier with scroll](https://github.com/cillyfly/MXScroll)

（ケースバイケースにはなるかと思いますが、フルスクラッチで無理やりなコードを組むよりもライブラリの仕様や実装にあやかった方が却って楽にいける場合もあります。）

### このサンプルでのDetailViewControllerにおける簡単な図解

この様に、複雑にそれぞれのView同士の位置関係が変化したり、UIScrollViewの操作のハンドリングを伴う処理の場合は、このようにお互いの関係が見えにくくなってしまう場合も...、。
（ちなみにこの部分はアンチパターンな実装だと個人的には思っています。）

![概要図](https://github.com/fumiyasac/ContainerViewInUICollectionView/blob/master/images/design_structure.png)
