PENDING = "pending"
FULFILLED = "fulfilled"
REJECTED = "rejected"

local Promise = {}
local promise = {
    _CLASS_NAME = 'Promise',
    status = PENDING,
    value = nil,
    reason = nil,
    onResolves = {},
    onRejects = {}
}

promise.__index = promise

function promise:next(onResolve, onReject)
    if(type(onResolve) ~= 'function') then
        onResolve = function (value) return value end
    end
    -- if(type(onReject) ~= 'function') then
    --     onReject = function (reason)
    --         error(reason)  -- not beautiful : this will catch '/usr/local/share/lua/5.3/lua-promise.lua:23: ...'
    --     end
    -- end
    return Promise.new(function (resolve, reject)
        if (self.status == FULFILLED) then
            local success, x = pcall(onResolve, self.value)
            if(success) then
                resolve(x)
            else
                reject(x)
            end
        elseif (self.status == REJECTED) then
            if(type(onReject) ~= 'function') then
                reject(self.reason)
            else
                local success, x = pcall(onReject, self.reason)
                if(success) then
                    resolve(x)
                else
                    reject(x)
                end
            end
        elseif (self.status == PENDING) then
            table.insert(self.onResolves, function (value)
                local success, x = pcall(onResolve, value)
                if(success) then
                    resolve(x)
                else
                    reject(x)
                end
            end)
            
            table.insert(self.onRejects, function (reason)
                if(type(onReject) ~= 'function') then
                    reject(reason)
                else
                    local success, x = pcall(onReject, reason)
                    if(success) then
                        resolve(x)
                    else
                        reject(x)
                    end
                end
            end)
        end
    end)
end

function promise:catch(onReject)
    return self:next(nil, onReject)
end

function promise_resolve(self, value)
    if(type(value) == 'table' and value._CLASS_NAME == 'Promise') then
        value:next(function (ret) promise_resolve(self, ret) end, function (err) promise_reject(self, err) end)
    else
        if(self.status == PENDING) then
            self.status = FULFILLED
            self.value = value
            for i = 1, #self.onResolves do
                self.onResolves[i](value)
            end
        end
    end
end

function promise_reject(self, reason)
    if(self.status == PENDING) then
        self.status = REJECTED
        self.reason = reason
        for i = 1, #self.onRejects do
            self.onRejects[i](reason)
        end
    end
end

function Promise.new(excutor)
    local self = setmetatable({}, promise)
    self._CLASS_NAME = 'Promise'
    self.status = PENDING
    self.value = nil
    self.reason = nil
    self.onResolves = {}
    self.onRejects = {}
    local ok, x = pcall(excutor, function(value) return promise_resolve(self, value) end, function (reason) return promise_reject(self, reason) end)
    if(ok == false) then
        promise_reject(self, x)
    end
    return self
end

function Promise.all(promises)
    return Promise.new(function (resolve, reject)
        local count = 0
        local rets = {}
        for i = 1, #promises do
            promises[i]:next(function (ret)
                count = count + 1
                rets[i] = ret
                if(count == #promises) then
                    resolve(rets)
                end
            end, reject)
        end
    end)
end

function Promise.race(promises)
    return Promise.new(function (resolve, reject)
        for i = 1, #promises do
            promises[i]:next(resolve, reject)
        end
    end)
end

function Promise.resolve(value)
    return Promise.new(function (resolve, reject)
        resolve(value)
    end)
end

function Promise.reject(value)
    return Promise.new(function (resolve, reject)
        reject(value)
    end)
end

return Promise