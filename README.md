# セレンディピティを考慮した推薦システム
## 概要
```Webニュース記事のキュレーションサービスです。  
通常では興味ありとした記事に似た記事がサジェストされるとてもシンプルな推薦システムです。  
グラフモードと呼ばれる仕組みを使うと、自分の興味（プロファイル）がインターネット上にある記事群の中でどの辺りに存在しているかが見える化されます。  
自分の近くにある記事にはざっくりとしたトピック単語が表示され、興味があればトピック単語に自分のプロファイルを近づけることや、自分のプロファイルに一時的に加えることができます。   
たとえば「北朝鮮」のニュースを日常的には興味ないけれど、ミサイル発射などの影響で一時的に詳しく知りたいときは「北朝鮮」というトピック単語をプロファイルに加えます。  
そうすることで自分のプロファイルに近く「北朝鮮」に関連するニュースが推薦されてきます。  
このようにユーザーが自分の意志で推薦をコントロールしているような感覚をあたえ、裏では推薦のアルゴリズムがそのコントロールを加味して情報を提示すると、ユーザーにとって提示された情報の満足度は増加する仕組みになっています。
```  

<img src="https://user-images.githubusercontent.com/6761278/40274505-e508682e-5c12-11e8-9db7-7055a8e187bc.png" width="500px"/>
<img src="https://user-images.githubusercontent.com/6761278/40274506-e52f8cba-5c12-11e8-8ce9-22ea3fa6e77f.png" width="500px"/>
<img src="https://user-images.githubusercontent.com/6761278/40274507-e553fcee-5c12-11e8-9af5-4b161015f537.png" width="300px"/>