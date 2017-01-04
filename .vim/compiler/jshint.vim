if exists("current_compiler")
  finish
endif
let current_compiler = "jshint"

CompilerSet errorformat=\\[\\d\\d:\\d\\d:\\d\\d\\]%+G,%f:\ line\ %l\\,\ col\ %c\\,\ %m,
      \%D%*\\S\ Working\ directory\ changed\ to\ %f
