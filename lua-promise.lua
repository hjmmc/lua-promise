PENDING = "pending"
FULFILLED = "fulfilled"
REJECTED = "rejected"

Promise = {
    _CLASS_NAME = 'Promise',
    status = PENDING,
    value = nil,
    reason = nil,
    onResolves = {},
onRejects = {}}
Promise.__index = Promise

function Promise.new(excutor)
    self = {}
    setmetatable(self, Promise)
    
    local _resolve = function (value)
        if(self.status == PENDING) then
            self.status = FULFILLED
            self.value = value
            for i = 1, #self.onResolves do
                self.onResolves[i](value)
            end
        end
    end
    
    local resolve = function (value)
        if(type(value) == 'table' and value._CLASS_NAME == 'Promise') then
            value:next(resolve, reject)
        else
            _resolve(value)
        end
    end
    
    local reject = function (reason)
        if(self.status == PENDING) then
            self.status = REJECTED
            self.reason = reason
            for i = 1, #self.onRejects do
                self.onRejects[i](value)
            end
        end
    end
    
    xpcall(excutor, function (err)
        reject(err)
    end, resolve, reject)
    
    return self
end

function Promise:next(onResolve, onReject)
    if(type(onResolve) ~= 'function') then
        onResolve = function (value)
            return value
        end
    end
    if(type(onReject) ~= 'function') then
        onReject = function (reason)
            error(reason)
        end
    end
    return Promise.new(function (resolve, reject)
        if (self.status == FULFILLED) then
            local success, x = xpcall(onResolve, function(err)
                reject(err)
            end, self.value)
            if(success) then
                resolve(x)
            end
        end
        if (self.status == REJECTED)then
            local success, x = xpcall(onReject, function(err)
                reject(err)
            end, self.reason)
            if(success) then
                resolve(x)
            end
        end
        if (self.status == PENDING) then
            table.insert(self.onResolves, function (value)
                local success, x = xpcall(onResolve, function(err)
                    reject(err)
                end, self.value)
                if(success) then
                    resolve(x)
                end
            end)
            table.insert(self.onRejects, function (value)
                local success, x = xpcall(onReject, function(err)
                    reject(err)
                end, self.reason)
                if(success) then
                    resolve(x)
                end
            end)
        end
    end)
end

function Promise:catch(onReject)
    return self:next(nil, onReject)
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
