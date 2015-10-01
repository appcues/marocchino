# marocchino
A tool for running client-side tests in a sandboxed environment. You execute your tests with your normal testing framework but can execute code and tests within a sandboxed iframe. This allows you to safely run DOM tests without affecting any other tests.

### Simple example
```
sandbox = null

beforeEach ->
    sandbox = marocchino.create({
        src: '/base/test/blank.html'
    })

afterEach ->
    marocchino.remove sandbox

it 'should be able to execute functions inside the iframe', ->
    sandbox.run( ->
        window._testValue = "appcues"
    ).then ->
        expect(sandbox.iframe.contentWindow._testValue).to.equal "appcues"
```
### Full example
See the tests for this library in the `test/` directory for a full example using `karma`, `mocha` and `chai`.

## Building
1. Run `npm install`.
2. Run `grunt`. This will build the library file and run the tests in PhantomJS, Chrome and Firefox.
3. The built file should be in the `lib/` directory.

## Usage
1. Get the `lib/marocchino.js` loaded on your test page.
2. Create a new `sandbox` with `marocchino.create()`.
3. Execute code in the `sandbox` by using the `sandbox.run(func)` call.
