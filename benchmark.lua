local data = {}

local LEN = 1000

local COUNT = 10000000

for i = 1, LEN do
    table.insert(data, {
        index = i,
        user = '<em>Chunpu</em>',
        github = 'https://github.com/chunpu',
        weibo = 'http://weibo.com/ft15222919293'
    })
end

local tmpl = [[
<ul>
    {{ for i = 1, #list do }}
        {{ local item = list[i] }}
        <li>
            <span>用户: {{=item.user}}</span>
            <a href="{{=item.github}}">Github</a>
            <a href='{{=item.weibo}}'>Weibo</a>
        </li>
    {{ end }}
</ul>
]]

local tp = require 'tp'

local start = os.time()

for i = 0, COUNT do
    tp.render(tmpl, {
        list = data,
        filename = 'xxx',
        cache = true,
        escape = false
    })
end

print(os.time() - start)
