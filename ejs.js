var ejs = require('ejs')

var LEN = 1000
var COUNT = 10000

var data = []

for (var i = 0; i < LEN; i++) {
    data.push({
        index: i,
        user: '<em>Chunpu</em>',
        github: 'https://github.com/chunpu',
        weibo: 'http://weibo.com/ft15222919293'
    })
}

var tmpl = '\
<ul>\
    {{ for (var i = 0; i < list.length; i++) { }}\
        {{ var item = list[i] }}\
        <li>\
            <span>用户: {{=item.user}}</span>\
            <a href="{{=item.github}}">Github</a>\
            <a href="{{=item.weibo}}">Weibo</a>\
        </li>\
    {{ } }}\
</ul>\
'

ejs.open = '{{'
ejs.close = '}}'

console.time(1)

for (var i = 0; i < COUNT; i++) {
    ejs.render(tmpl, {
        list: data,
        filename: 'xxx',
        cache: true
    })
}
console.timeEnd(1)
