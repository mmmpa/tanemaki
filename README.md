[![Build Status](https://travis-ci.org/mmmpa/tanemaki.svg)](https://travis-ci.org/mmmpa/tanemaki)

# Tanemaki

Tanemaki（たねまき）はRuby on Railsの`rake db:seed`で使われるseed.rbを整理するために書かれました。

こうなっているのが
```
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
```
ken_code,sityouson_code,tiiki_code,ken_name,sityouson_name1,sityouson_name2,sityouson_name3,yomigana
27,0,27000,大阪府,,,,おおさかふ
27,100,27100,大阪府,大阪市,,,おおさかし
27,102,27102,大阪府,大阪市,,都島区,みやこじまく
27,103,27103,大阪府,大阪市,,福島区,ふくしまく
# 略
27,128,27128,大阪府,大阪市,,中央区,ちゅうおうく
```

```
AreaCode.tanemaki(csv_path).seed
```

になります。
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tanemaki'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tanemaki

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tanemaki.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

