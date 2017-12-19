# 如何参与开发 Homeland

```bash
$ bundle install
$ cd test/dummy
$ rake db:create
$ rake db:migrate
$ rake db:seed
$ rails s
```

然后浏览器访问: http://localhost:3000

# 如何允许测试

```
$ rails db:migrate RAILS_ENV=test
$ rake
```

# 在测试程序中开发

如果在，engine 中，添加了新的模型，可以通过执行 `rails g homeland:install` 来实现安装。




