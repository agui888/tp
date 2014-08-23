local tp = require 'tp'

local tmpl = [[
<p>Hi {{=name}}</p>
<ul>
    {{for i = 1, #arr do}}
        <li>{{=arr[i]}}</li>
    {{end}}
</ul>
]]
local opt = {
    name = 'monkey',
    arr = {1, 2, 3},
    basedir = '/tmp/'
}

print(tp.render(tmpl, opt))
print(tp.renderFile('xxx.tmpl', opt))

