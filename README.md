# lua-promise
promise(A+) for lua. like ES6

## Build Setup

``` bash
# install dependencies
luarocks install lua-promise
```
## Interface

* **For the Promsie class, call with '.'**

**Promise.new(executor)**

> ```lua
> promise = Promise.new(function(resolve, reject) .. end);
> ```

**Promise.all(array)**

> ```
> promise = Promise.all(array)  -- a table as array
> ```

**Promise.race(array)**

> ```lua
> promise = Promise.race(array) -- a table as array
> ```

**Promise.reject(reason)**

> ```lua
> promise = Promise.reject(reason); -- reason is anything
> ```

**Promise.resolve(value)**

> ```lua
> promise = Promise.resolve(value);
> promise = Promise.resolve(promise);
> ```

* **For promise instance, call with ':'**

**promise:next(onResolve, onRejecte)**

> ```lua
> promise2 = promise:next(functoin(value) ... end);
> promise2 = promise:next(nil, functoin(reason) ... end);
> ```

**promise:catch(onRejecte)**

> ```lua
> promise2 = promise:catch(functoin(reason) ... end)
> ```

## Usage
example
```lua
Promise = require('lua-promise2')

login = Promise.resolve({err = 0, data = {id = '1001', name = 'admin'}}):next(function (ret)
    if(ret.err == 0) then
        -- login success
        return ret.data.id
    else
        error(ret)
    end
end)
getMenuConfig = function(id)
    return Promise.resolve({home = '/home/'..id..'.html'})
end
getNickName = function (id)
    return Promise.resolve('nickName'..id)
end

login:next(getMenuConfig):next(function (menu)
    print(menu.home)
end)
login:next(getNickName):next(function (nickName)
    print(nickName)
end)
```

test code
```lua
Promise = require('lua-promise')

Promise.new(function (resolve, reject)
    resolve('aaaa')
end):next(function (ret)
    print('1', ret)
    return Promise.resolve('bbbb'):next(function (ret0)
        print('1.1', ret0)
        return ret0..'cccc'
    end)
end):next(function (ret)
    print('2', ret)
    return Promise.reject({code = -1})
end):catch(function(err)
    print('err', err, err.code)
    return '000'
end):next(function (ret)
    print('3', ret)
    return 0 / nil
end):next(function (ret)
    print('4', ret)
end):catch(function(err)
    print('err2', err)
end)

Promise.all({Promise.resolve(1), Promise.resolve(2)}):next(function (rets)
    for i = 1, #rets do
        print('rets', rets[i])
    end
end)

Promise.race({Promise.resolve('a'), Promise.reject('b'), Promise.resolve('c')}):next(function (ret)
    print(ret)
end):catch(function(err)
    print('err', err)
end)
```