# resolve-bower

based off of substack's [resolve](http://github.com/substack/node-resolve)

implements the [node `require.resolve()`
algorithm](http://nodejs.org/docs/v0.4.8/api/all.html#all_Together...)
such that you can `require.resolve()` on behalf of a bower file asynchronously and
synchronously

[![build status](https://secure.travis-ci.org/substack/node-resolve.png)](http://travis-ci.org/substack/node-resolve)

# example

asynchronously resolve:

``` js
var resolve = require('resolve-bower');
resolve('tap', { basedir: __dirname }, function (err, res) {
    if (err) console.error(err)
    else console.log(res)
});
```

```
$ node example/async.js
/home/substack/projects/node-resolve/bower_components/tap/lib/main.js
```

synchronously resolve:

``` js
var resolve = require('resolve-bower');
var res = resolve.sync('tap', { basedir: __dirname });
console.log(res);
```

```
$ node example/sync.js
/home/substack/projects/node-resolve/bower_components/tap/lib/main.js
```

# methods

``` js
var resolve = require('resolve-bower')
```

## resolve(pkg, opts={}, cb)

Asynchronously resolve the module path string `pkg` into `cb(err, res)`.

options are:

* opts.basedir - directory to begin resolving from

* opts.package - package from which module is being loaded

* opts.extensions - array of file extensions to search in order

* opts.readFile - how to read files asynchronously

* opts.isFile - function to asynchronously test whether a file exists

* opts.packageFilter - transform the parsed bower.json contents before looking
at the "main" field

* opts.paths - require.paths array to use if nothing is found on the normal
bower_components recursive walk (probably don't use this)

* opts.moduleDirectory - directory to recursively look for modules in. default:
`"bower_components"`

default `opts` values:

``` javascript
{
    paths: [],
    basedir: __dirname,
    extensions: [ '.js' ],
    readFile: fs.readFile,
    isFile: function (file, cb) {
        fs.stat(file, function (err, stat) {
            if (err && err.code === 'ENOENT') cb(null, false)
            else if (err) cb(err)
            else cb(null, stat.isFile())
        });
    },
    moduleDirectory: 'bower_components'
}
```

## resolve.sync(pkg, opts)

Synchronously resolve the module path string `pkg`, returning the result and
throwing an error when `pkg` can't be resolved.

options are:

* opts.basedir - directory to begin resolving from

* opts.extensions - array of file extensions to search in order

* opts.readFile - how to read files synchronously

* opts.isFile - function to synchronously test whether a file exists

* opts.packageFilter - transform the parsed bower.json contents before looking
at the "main" field

* opts.paths - require.paths array to use if nothing is found on the normal
bower_components recursive walk (probably don't use this)

* opts.moduleDirectory - directory to recursively look for modules in. default:
`"bower_components"`

default `opts` values:

``` javascript
{
    paths: [],
    basedir: __dirname,
    extensions: [ '.js' ],
    readFileSync: fs.readFileSync,
    isFile: function (file) {
        try { return fs.statSync(file).isFile() }
        catch (e) { return false }
    },
    moduleDirectory: 'bower_components'
}
````

## resolve.isCore(pkg)

Return whether a package is in core.

# install

With [npm](https://npmjs.org) do:

```
npm install resolve
```

# license

MIT
