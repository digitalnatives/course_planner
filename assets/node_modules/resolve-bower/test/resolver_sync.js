var test = require('tap').test;
var resolveBower = require('../');

test('foo', function (t) {
    var dir = __dirname + '/resolver';

    t.equal(
        resolveBower.sync('./foo', { basedir : dir }),
        dir + '/foo.js'
    );

    t.equal(
        resolveBower.sync('./foo.js', { basedir : dir }),
        dir + '/foo.js'
    );

    t.throws(function () {
        resolveBower.sync('foo', { basedir : dir });
    });

    t.end();
});

test('bar', function (t) {
    var dir = __dirname + '/resolver';

    t.equal(
        resolveBower.sync('foo', { basedir : dir + '/bar' }),
        dir + '/bar/bower_components/foo/index.js'
    );
    t.end();
});

test('baz', function (t) {
    var dir = __dirname + '/resolver';

    t.equal(
        resolveBower.sync('./baz', { basedir : dir }),
        dir + '/baz/quux.js'
    );
    t.end();
});

test('biz', function (t) {
    var dir = __dirname + '/resolver/biz/bower_components';
    t.equal(
        resolveBower.sync('./grux', { basedir : dir }),
        dir + '/grux/index.js'
    );

    t.equal(
        resolveBower.sync('tiv', { basedir : dir + '/grux' }),
        dir + '/tiv/index.js'
    );

    t.equal(
        resolveBower.sync('grux', { basedir : dir + '/tiv' }),
        dir + '/grux/index.js'
    );
    t.end();
});

test('normalize', function (t) {
    var dir = __dirname + '/resolver/biz/bower_components/grux';
    t.equal(
        resolveBower.sync('../grux', { basedir : dir }),
        dir + '/index.js'
    );
    t.end();
});

test('cup', function (t) {
    var dir = __dirname + '/resolver';
    t.equal(
        resolveBower.sync('./cup', {
            basedir : dir,
            extensions : [ '.js', '.coffee' ]
        }),
        dir + '/cup.coffee'
    );

    t.equal(
        resolveBower.sync('./cup.coffee', {
            basedir : dir
        }),
        dir + '/cup.coffee'
    );

    t.throws(function () {
        resolveBower.sync('./cup', {
            basedir : dir,
            extensions : [ '.js' ]
        })
    });

    t.end();
});

test('mug', function (t) {
    var dir = __dirname + '/resolver';
    t.equal(
        resolveBower.sync('./mug', { basedir : dir }),
        dir + '/mug.js'
    );

    t.equal(
        resolveBower.sync('./mug', {
            basedir : dir,
            extensions : [ '.coffee', '.js' ]
        }),
        dir + '/mug.coffee'
    );

    t.equal(
        resolveBower.sync('./mug', {
            basedir : dir,
            extensions : [ '.js', '.coffee' ]
        }),
        dir + '/mug.js'
    );

    t.end();
});

test('other path', function (t) {
    var resolveBowerDir = __dirname + '/resolver';
    var dir = resolveBowerDir + '/bar';
    var otherDir = resolveBowerDir + '/other_path';

    var path = require('path');

    t.equal(
        resolveBower.sync('root', {
            basedir : dir,
            paths: [otherDir] }),
        resolveBowerDir + '/other_path/root.js'
    );

    t.equal(
        resolveBower.sync('lib/other-lib', {
            basedir : dir,
            paths: [otherDir] }),
        resolveBowerDir + '/other_path/lib/other-lib.js'
    );

    t.throws(function () {
        resolveBower.sync('root', { basedir : dir, });
    });

    t.throws(function () {
        resolveBower.sync('zzz', {
            basedir : dir,
            paths: [otherDir] });
    });

    t.end();
});

test('incorrect main', function (t) {
    var resolveBowerDir = __dirname + '/resolver';
    var dir = resolveBowerDir + '/incorrect_main';

    t.equal(
        resolveBower.sync('./incorrect_main', { basedir : resolveBowerDir }),
        dir + '/index.js'
    )

    t.end()
});

test('#25: node modules with the same name as node stdlib modules', function (t) {
    var resolveBowerDir = __dirname + '/resolver/punycode';

    t.equal(
        resolveBower.sync('punycode', { basedir : resolveBowerDir }),
        resolveBowerDir + '/bower_components/punycode/index.js'
    )

    t.end()
});
