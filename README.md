[![Build Status](https://travis-ci.org/mmmpa/tanemaki.svg)](https://travis-ci.org/mmmpa/tanemaki)
[![Coverage Status](https://coveralls.io/repos/mmmpa/tanemaki/badge.svg?branch=master)](https://coveralls.io/r/mmmpa/tanemaki?branch=master)
[![Code Climate](https://codeclimate.com/github/mmmpa/tanemaki/badges/gpa.svg)](https://codeclimate.com/github/mmmpa/tanemaki)

# Tanemaki

Tanemaki（たねまき）はRuby on Railsの`rake db:seed`で使われるseed.rbを整理するために書かれました。

こうなっているのが
```ruby
AreaCode.create([
  {ken_code: 27, sityouson_code: 0, tiiki_code: 27000, ken_name: ,'大阪府', sityouson_name1: , sityouson_name2: '', sityouson_name3: , yomigana: 'おおさかふ'},
  {ken_code: 27, sityouson_code: 100, tiiki_code: 27100, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name2: '', sityouson_name3: , yomigana: 'おおさかし'},
  {ken_code: 27, sityouson_code: 102, tiiki_code: 27102, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name2: '', sityouson_name3: '都島区', yomigana: 'みやこじまく'},
  {ken_code: 27, sityouson_code: 103, tiiki_code: 27103, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name2: '', sityouson_name3: '福島区', yomigana: 'ふくしまく'},
# 略
  {ken_code: 27, sityouson_code: 128, tiiki_code: 27128, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name2: '', sityouson_name3: '中央区', yomigana: 'ちゅうおうく'},
])
```

用意したCSVファイルと
```csv
ken_code,sityouson_code,tiiki_code,ken_name,sityouson_name1,sityouson_name2,sityouson_name3,yomigana
27,0,27000,大阪府,,,,おおさかふ
27,100,27100,大阪府,大阪市,,,おおさかし
27,102,27102,大阪府,大阪市,,都島区,みやこじまく
27,103,27103,大阪府,大阪市,,福島区,ふくしまく
# 略
27,128,27128,大阪府,大阪市,,中央区,ちゅうおうく
```

```ruby
AreaCode.tanemaki(csv_path).seed
```

になります。
## Installation
```ruby
gem 'tanemaki', require: false
```
    $ bundle install
使う場所で

    require 'tanemaki'

## Usage

こういうmodelがあるとして
```ruby
pry(main)> AreaCode
class AreaCode < ActiveRecord::Base {    
                   :id => :integer,  
             :ken_code => :integer,   
       :sityouson_code => :integer, 
           :tiiki_code => :integer,   
             :ken_name => :string,   
      :sityouson_name1 => :string,   
      :sityouson_name2 => :string,   
      :sityouson_name3 => :string,  
             :yomigana => :string,  
           :created_at => :datetime, 
           :updated_at => :datetime  
}                                    
```

`create`に必要なキーワード引数の**キーを一行目に書いたCSV**（例えば area_code.csv）を用意。

```csv
ken_code,sityouson_code,tiiki_code,ken_name,sityouson_name1,sityouson_name2,sityouson_name3,yomigana
27,0,27000,大阪府,,,,おおさかふ
27,100,27100,大阪府,大阪市,,,おおさかし
27,102,27102,大阪府,大阪市,,都島区,みやこじまく
27,103,27103,大阪府,大阪市,,福島区,ふくしまく
# 略
27,128,27128,大阪府,大阪市,,中央区,ちゅうおうく
```

ゴー。

```ruby
AreaCode.tanemaki('area_code.csv').seed
```

内部的には各行においてこのようなことが起こります。

```ruby
AreaCode.create({ken_code: 27, sityouson_code: 102, tiiki_code: 27102, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name2: '', sityouson_name3: '都島区', yomigana: 'みやこじまく'})
```
返り値は`create`の返り値の`Array`。

## create以外を使う
ぼくはどちらかというと`create!`が好きなので
```ruby
AreaCode.tanemaki('area_code.csv', method: :create!).seed
```

## 名前無し引数に使う

こういうのです。

    FactoryGirl.build(:user, :invalid, name: 'MMMPA', name_reading: 'ンンンパ')

名前無し引数のカラムの名前を省いたfactory.csvを用意します。

```csv
,name,name_reading,
:user,MMMPA,ンンンパ,:invalid
:user,o296sm,おふくろさま,:valid
```

こうすると1列目（[0]）と4列目（[3]）は普通の引数としてメソッドに渡されます。カラムの位置にかかわらず、出現順に引数の頭に回されます。

突然ですが`evaluate`に渡した名前のカラム、もしくは名前無しカラムのインデックスと一致するカラムは式として評価されます（この場合`Symbol`になる）。

    FactoryGirl.tanemaki('factory.csv', method: :build).evaluate(0, 3).seed


## select

CSVから必要なカラムのみ使います。
```ruby
AreaCode.tanemaki('area_code.csv').select(:tiiki_code, :ken_name, :sityouson_name1, :sityouson_name3).seed
```
内部的には各行においてこのようなことが起こります。
```ruby
AreaCode.create({tiiki_code: 27102, ken_name: ,'大阪府', sityouson_name1: ,'大阪市', sityouson_name3: '都島区'})
```

## evaluate
指定したカラムの値を式として評価します。
インスタンス変数の参照先は`scope: self`などと設定します。`Tanemaki.default_eva_scope =self`なども可能です。
（記述中）


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

