local _ = require 'shim'

local cache = {}

local tp = {
    open = '{{',
    close = '}}',
    cache = cache
}

function tp.escape(html)
    local ret = tostring(html)
        :gsub('&', '&amp;')
        :gsub('<', '&lt;')
        :gsub('>', '&gt;')
        :gsub('"', '&quot;')
    return ret
end

function tp.render(str, opt)
    opt = opt or {}
    opt.escape = tp.escape
    local fn, msg
    if opt.cache and opt.filename then
        fn = cache[opt.filename]
    else
        fn, msg = tp.compile(str, opt)
    end
    if type(fn) ~= 'function' then
        return nil, msg
    end
    if type(getfenv) == 'function' then
        setfenv(fn, _.extend(getfenv(fn), opt))
    else
        local _fn = fn
        fn = function()
            _ENV = _.extend(_ENV, opt)
            return _fn()
        end
    end
    return fn()
end

function tp.read(path)
    local file = io.open(path, 'r')
    if file then
        return file:read('*a')
    end
end

function tp.renderFile(path, opt)
    opt = opt or {}
    local basedir = opt.basedir or ''
    opt.filename = tp.pathResolve(basedir, path)
    return tp.render(tp.read(opt.filename), opt)
end

function tp.compile(str, opt)
    opt = opt or {}
    local func = tp.parse(str, opt)
    if func then
        local ret, msg = loadstring(func) -- here get error msg
        if ret then
            if opt.filename and opt.cache then
                cache[opt.filename] = ret
            end
            return ret
        end
        print(msg, '\n', func) -- TODO, handle it and more clear
    end
end

function tp.parse(str, opt)
    if not str then return end
    opt = opt or {}
    local func = {'local ret = {}'}
    local add = function(str, escape)
        if opt.escape ~= false and escape then
            str = 'escape(' .. str .. ')'
        end
        table.insert(func, 'table.insert(ret, ' .. str .. ')')
    end

    local function getLua(str)
        if not str then return end
        local flag = str:sub(1, 1)
        if flag == '=' then
            add(str:sub(2), true)
        elseif flag == '-' then
            add(str:sub(2))
        elseif _.indexOf(str, 'include') == 1 then
            local include = _.trim(str:sub(8))
            if opt.filename then
                include = tp.pathResolve(opt.filename, include)
                include = tp.read(include)
                include = tp.parse(include, opt)
                include = '(function() ' .. include .. ' end)()'
                add(include)
            end
        else
            table.insert(func, str)
        end
    end

    local function getPlain(str)
        add('"' .. str:gsub('\n', '\\n'):gsub('"', '\\"') .. '"')
    end

    _(str):chain():split(tp.open):each(function(x)
        local split = _.split(x, tp.close)
        if split[2] then
            getLua(split[1])
            getPlain(split[2])
        else
            getPlain(split[1])
        end
    end)

    table.insert(func, 'return table.concat(ret, "")')
    func = _.join(func, '\n')
    return func
end

function tp.pathResolve(path1, path2)
    if not path1 or not path2 then
        return path1 or path2
    end
    path1 = _.split(path1, '/')
    path1[#path1] = nil
    local pathArr = _.push(path1, unpack(_.split(path2, '/')))
    local up = 0
    local i = #pathArr
    repeat
        local last = pathArr[i]
        if last == '.' then
            pathArr[i] = nil
        elseif last == '..' then
            pathArr[i] = nil
            up = up + 1
        elseif up ~= 0 then
            pathArr[i] = nil
            up = up - 1
        end
        i = i - 1
    until i == 0
    pathArr = _.without(pathArr, nil)
    return table.concat(pathArr, '/')
end

return tp
