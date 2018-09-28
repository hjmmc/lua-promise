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
