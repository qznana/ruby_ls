class ListSegments
    require 'optparse' # オプションを実装するためのライブラリの呼び出し
    require 'etc'　# /etc に存在するデータベースから情報を得るためのモジュール??? => カーネルモードを通して使うプログラムを呼び出すためのライブラリ
    def self.exec # "self.exec"というmethodを定義　execは特異メソッドなのでself.が必要
      @options = {} # オプションを使用したいときにrubyに渡されたオプションを確認したい。{}はhashと呼ばれるもの　=>文字列とデータを関連つける　順番にこだわらずに済むのが強み（後々改変も楽）
      OptionParser.new do |o| # "o"にOptionParser.newオブジェクトを格納して繰り返す効果を付与　OptionParser=メソッド　oはインスタンスオブジェクト？
        o.on("-a","like \"ls -a\""){ @options[:all] = true } # -aオプションの処理　=> -a を受け取ったときにallをtrueにする　
        o.on("-l","like \"ls -l\"") { @options[:long] = true } # -lオプションの処理
        o.parse!(ARGV) # ここでオプションの解析が始まる　ARGV => コマンドライン引数が入ってる配列。　ls "-a"ここを読むためのコード　上の２行は条件に合致したときの特定の処理とその条件を表す。　ARGVの中のオプションをぶち殺すparse!くん
      end
      args = get_args() # get_argsってメソッドをargsって変数に代入している args=>引数の受け渡し　argsには
      multi_flag =  args.count >= 2# ? true : false # get_argsのカウントが２以上の真偽値を返す処理をする変数？ ディレクトリの数が2以上の時true　未満の時false
      dirs = args.count != 0 ? validate_args(args) : ["."] # get_argsのカウントが・・・・？？？？？？ . => カレントディレクトリ（ターミナルくんがいるディレクトリ）を表す。　validate(検証する)　ってことは引数(args)を検証する
      dirs.each do |dir| # dirsをdirに格納して繰り返す効果付与 for文だと配列の中身だけ繰り返す書き方をしなくてはならない。for文は[0.2.4]みたいに飛び石処理ができる。わろた。
        display(dir, multi_flag) # display(out = $stdout) オブジェクトをoutに出力するのを繰り返す？？？ 35行目参照
      end
    end
    
    private　# クラス内からのみアクセスを許可しますよ〜ってこと
    def self.get_args # self.get_argsメソッドを定義します（特異メソポタミア文明
      ARGV # "ARGV"です。以上です。は？ rubyスクリプトに与えられた引数を表す配列ってことだからoption("-a"とか)を出力するのかな
    end
    def self.validate_args(args) # self.validate_argsに変数argsを引数として渡してメソッドとして産みます
      valid_dir = [] # valid_dirって変数は[]です。ちなみにvalidは有効って意味です。
      args.each do |arg| # 変数args(11行目で定義したやつ)をargに格納して繰り返し効果を付与
        if Dir.exist?(arg) # ファイルパスが存在する場合true しない場合false
          valid_dir.push(arg) # 配列にファイルパスをぶちこむ
        else　# falseの場合
          printf("%s: %s: No such file or directory\n", $0, arg)　# No~ って表示する　%s=>$0 %s=>arg (%sには変数を入れることができる) \n => 改行コード（文章の最後に改行が入る） $0 => 現在実行しているファイル名
        end
      end
      valid_dir　# 上記valid_dirを戻す。
    end

    def self.display(dir, multi_flag) # self.displayメソッドに引数dirとmulti_flagを渡して定義 以下中身
      printf("%s:\n", dir) if multi_flag # もし渡されたディレクトリの数が2以上なら右詰にして改行、変数dirを表示
      if @options[:long] # もし-lのオプションコマンドが入力されたら
        display_list(get_path(dir)) # display_listメソッド引数get_path(dir)=>入力されたディレクトリのフル住所を渡して実行（get_path(dir)は180行目で定義)
      else
        display_normal(get_path(dir))# -lが入力されていなければdisplay_nomalメソッドに引数get_path(dir)を渡して実行
      end
    end

    def self.display_list(dir) # self.display_listに引数(dir=.渡されたディレクトリのフル住所)を渡して定義
      total_blocks = 0 # total_blocks変数に0を定義
      files = get_files(dir) # files変数にget_files(dir)を定義
      lists = [] # lists変数に配列を定義
      files.each do |file| # filesをfileに格納して繰り返す効果付与
        parsed_info = [] # parsed_info変数に配列を定義
        fs = File::Stat.new("#{dir}/#{file}") # fs変数にフル住所で指定したファイルのステータス(権限とかサイズとかの情報)が入ってくる
        total_blocks += fs.blocks # total_blocks=0にfs.blocks(情報のうちブロック数を参照したもの）のブロック数をたし上げ
        parsed_info.push(get_mode(fs)) # 配列をfsのmodeをgetして出力？？
        
        parsed_info.push(get_nlink(fs)) # 上記mode=>nlink版　以下同文 ハードリンクの数　を配列に入れる
        parsed_info.push(get_owner(fs)) # 所有者
        parsed_info.push(get_group(fs)) # ファイルが属しているグループの情報　
        parsed_info.push(get_size(fs)) # フィアルサイズ
        date, time = get_time(fs) # ディレクトリとファイルの最終更新時間を取得
        parsed_info.push(date) # 日を配列に入れる
        parsed_info.push(time) # 時間を配列に入れる
        parsed_info.push(file) # file ファイルエントリ名を配列に入れる
        lists.push(parsed_info) # 配列をまとめて表示する用listsに入れる
      end
        print_list(lists, total_blocks) # 使用しているブロック数と上記でまとめた配列を出力
    end
    def self.get_mode(fs) # メソッドself.get_mdoe(引数fs)を定義
      parsed_mode = "" # 変数paesed_modeに文字列を定義
      mode = "%o" % fs.mode # 変数modeをfs(エントリ)のファイルやらディレクトリやらの情報（mode)を8進数("%o")に変換して定義
      if mode.length == 6 # もしmodeの長さが6と等しいなら
         case mode[0,2] # 対象オブジェmode[0,2]
         when "14" # 14の場合
           parsed_mode.concat("s") # paesed以下略をsと連結
         when "12" # 12の場合
           parsed_mode.concat("l") # parsed以下略をl(linkの略)と連結 シンボリックリンクだったらlがつく
         when "10" # 10の場合
           parsed_mode.concat("-") # parsed以下略を-と連結
         end
         mode = mode[3,3] # mode変数にmode[3,3]を代入 3番目から数えて3ｺとってくる
      else
        case mode[0,1] # またはmode[0,1]なら
        when "6" # 6の場合
          parsed_mode.concat("b") # parsed_modeをbと連結 
         when "4" # 4の場合
           parsed_mode.concat("d") # parsed_modeをdと連結 ディレクトリだったらdがつく
         when "2" # 2の場合
           parsed_mode.concat("c") # parsed_modeをcと連結 
         when "1" # 1の場合
           parsed_mode.concat("p") # parsed_modeをpと連結 
         when "0" # 0の場合
           parsed_mode.concat("?") # parsed_modeを?と連結 osが認識できるものじゃ無い（存在しない形式のもの)
        end
        mode = mode[2,3] # 変数modeにmode[2,3]を代入 2番目から3ｺとってくる　そのエントリの権限情報をとってきている　rwx 421
      end
       permissions = mode.chars.map{ |c| ("%b" % c).delete_prefix("0b0").chars } # 変数permissionsにmode情報を2進数に変換 charsは1文字1文字を分解して配列にする
       permissions.each do |permission| # 上記permissions変数をpermissionに格納して繰り返す効果を付与
        parsed_mode.concat(permission.shift == '1' ? "r" : "-") # 
        parsed_mode.concat(permission.shift == '1' ? "w" : "-")
        parsed_mode.concat(permission.shift == '1' ? "x" : "-")
      end
       parsed_mode # 変数parsed_modeを戻す ディレクトリだったりシンボリックリンクだったりの情報に加えrwxの権限情報が戻り値になる
       # TODO:add access control list
    end
    def self.get_nlink(fs) # get_nlinkに引数dsを渡して定義 nlink=ハードリンク　ファイルリンクの一種　ハードリンクが削除されると元ファイルも削除される　シンボリックリンクは消しても元のリンクは消えない（ショートカットみたいなもの）
      nlink = fs.nlink.to_s # 変数nlinkにfs.nlink.to_sを代入 はードリンクの数が帰ってくる
    end
    def self.get_owner(fs) # メソッドself.get_owner(fs)を定義
      owner = Etc.getpwuid(fs.uid).name # passwd データベースを検索し、ユーザ ID が uid である passwd エントリを返します。 所有者の名前情報をとってくるメソッドの処理
      # 全ての物事をファイルとして扱う。etcはユーザーidとかが保存されているライブラリ。/etcに/paswdがあってそれを便利につかうためのコード。
      # ls -l   root wheel =>管理者がwheelに属していること（root=管理者)
      # lrwxr-xr-x => s xxx zzz yyy S=シンボリックリンク（それが何かを表す）　
      # -a 隠しファイルを表示するオプション
    end
    
    def self.get_group(fs) # self.get_groupメソッドに引数fsを渡して定義
      group = Etc.getgrgid(fs.gid).name　# グループの名前情報をとってくるメソッドの処理　=> staff
    end
    def self.get_size(fs) # self.get_size(fs)を定義
      size = fs.size.to_s # size変数にfs.size.to_sを代入して定義
    end
    def self.get_time(fs) # メソッドself.get_timeに引数fsを渡して定義
      mtime = fs.mtime # 変数mtimeにfs.mtimeを代入して定義
      month = mtime.strftime("%m") # 変数monthにmtime.strftime("%m")を代入して定義
      month[0] = (" ") if month[0] == '0' # 変数month[0]にもしmonth[0]なら文字列を代入して定義
      day = mtime.strftime("%e") # 変数dayにmtime.strftime("%e")を代入して定義
      date = month.concat(" ",day) # 変数dateに変数monthに(" ",day)を連結したものを代入して定義
      half_year = 15552000 # 変数half_yearに数字15552000
      if (mtime - Time.now).abs >= half_year # もし(mtime-Time.now).absがhalf_year以上なら
        year = mtime.year.to_s # 変数yearにmtime.year.to_sを代入して定義
        return date, year # dateとyearを戻す
      else
        time = mtime.strftime("%R") # 変数timeにmtime.strftime("%R")を代入して定義
        return date, time # dateとtimeを戻す
      end
    end
    
    def self.print_list(lists,total_blocks) #メソッドself.print_list(引数lists,total_blocks)を定義
      print("total #{total_blocks.to_s}\n") # total_blocksを文字列に変換して改行して "total~"の形で表示
      block_len = 1 # block_lenに1を代入して定義(変数の初期化)　以下同文
      owner_len = 1
      group_len = 1
      size_len = 1
      time_len = 1
      
      lists.map { |info| # .map=>配列やハッシュオブジェクトの要素がひとつずつ取り出され変数に要素が代入されていき、指定した変数名をブロック内で使用することができます。listsの配列が変数infoに代入されて処理が実行される。
                        block_len = info[1].length if block_len < info[1].length # もしblock_lenがinfo[1].lengthより小さいならbloks_lenはinfo[1].lengthになる以下同文
                        owner_len = info[2].length if owner_len < info[2].length 
                        group_len = info[3].length if group_len < info[2].length
                        size_len = info[4].length if size_len < info[4].length 
                        time_len = info[6].length if time_len < info[6].length
                }
      lists.each do |info| # listsをinfoに格納して繰り返す効果付与
        printf("%s %#{block_len + 1}s %-#{owner_len}s  %-#{group_len}s %#{size_len + 1}s %s %#{time_len}s %s\n",
               info[0], info[1], info[2], info[3], info[4], info[5], info[6], info[7])
      end
    end
    def self.display_normal(dir)  # self.display_nomalに引数dirを渡してメソッド定義
      
      files = get_files(dir)
      files_count = files.length
      name_len = 1
      files.map { |file| name_len = file.length if name_len < file.length }
      total_length = (name_len + 5) * files.count
      # case ls -G: total_length = (name_len + 1) * files.count
      columns = `tput cols`.to_i
      line_count = (total_length + (columns - 1)) / columns
      column_count = (files.count + (line_count / 2)) / line_count
      line_count = 1 if line_count == 0
  
  
      (0...line_count).each do |line|
        (0..column_count).each do |column|
        (0...column_count).each do |column|
          idx = line_count * column + line
          printf("%-#{name_len}s\t", files[idx]) if idx < files_count
          # case ls -G: printf("%-#{name_len + 1}s", files[idx]) if idx < files_count
        end
        print("\n")
      end
    end
    def self.get_path(dir)
      Dir.chdir(dir) do 
        dir = Dir.pwd # 入力されたディレクトリにdo~endだけ移動してカレントディレクトリのフル住所を返す。
      end
    end
    def self.get_files(dir)
      @options[:all] ? Dir.entries(dir).sort : Dir.children(dir).filter{ |file| file[0] != "." }.sort # -aが入力されたら全てのファイル名（エントリ）を返す。そうで無い時、先頭文字 "."でないファイル名（エントリ）を返す。
    end
  end
end

ListSegments.exec # exec => execute  クラス内のself.execだけを実行するコード