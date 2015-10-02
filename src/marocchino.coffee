Promise = require('es6-promise').Promise
uuid = require 'uuid'

marocchino = {}

# Array.reduce polyfill.
# Production steps of ECMA-262, Edition 5, 15.4.4.21
# Reference: http://es5.github.io/#x15.4.4.21
if not Array.prototype.reduce
    Array.prototype.reduce = (callback) ->
        unless @?
            throw new TypeError('Array.prototype.reduce called on null or undefined')
        if typeof callback isnt 'function'
            throw new TypeError(callback + ' is not a function')
        t = Object(@)
        len = t.length >>> 0
        k = 0
        if arguments.length is 2
            value = arguments[1]
        else
            while k < len and not (k of t)
                k++
            if k >= len
                throw new TypeError('Reduce of empty array with no initial value')
            value = t[k++]
        for i in [k..len]
            if i of t
                value = callback value, t[i], i, t
        return value

# Polyfill for Function.prototype.bind.
# Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind?redirectlocale=en-US&redirectslug=JavaScript%2FReference%2FGlobal_Objects%2FFunction%2Fbind#Polyfill
if not Function.prototype.bind
    Function.prototype.bind = (oThis) ->
        if typeof @ isnt 'function'
            # closest thing possible to the ECMAScript 5
            # internal IsCallable function
            throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable')
        aArgs = Array.prototype.slice.call(arguments, 1)
        fToBind = @
        fNOP = ->
        fBound = ->
            return fToBind.apply (if @ instanceof fNOP then @ else oThis), aArgs.concat(Array.prototype.slice.call(arguments))
        if @.prototype
            # native functions don't have a prototype
            fNOP.prototype = @.prototype
        fBound.prototype = new fNOP()
        return fBound


class Sandbox

    handleLogMessage = (evt) ->
        if evt.data.action is 'console.log'
            console.log "(Sandbox Frame): #{evt.data.message}"

    appendExecutingScriptTag = (code, el) ->
        script = document.createElement 'script'
        script.text = code
        el.appendChild script

    constructor: ->
        # Create the iframe.
        @iframe = document.createElement 'iframe'
        @iframe.className = 'marocchino-frame'

    initialize: (options={}) ->
        if options.src?
            @iframe.src = options.src
        # Append the iframe.
        document.getElementsByTagName('body')[0].appendChild @iframe

        # Tells us when the iframe is loaded.
        @ready = new Promise (resolve, reject) =>
            @iframe.addEventListener 'load', =>
                # Add script to override console.log in sandbox frame, unless we're loading a page in the frame.
                override = ->
                    window.console.log = (msg) ->
                        parent.postMessage { action: 'console.log', message: msg }, '*'
                appendExecutingScriptTag "(#{override.toString()})();", @iframe.contentWindow.document.getElementsByTagName('head')[0]
                resolve()

        # Delegate console.log to parent frame.
        window.addEventListener 'message', handleLogMessage

    run: (fn, args) ->
        runId = uuid.v4()
        @ready.then =>
            new Promise (resolve, reject) =>
                numArgs = 0
                if args instanceof Array
                    numArgs = args.length
                    argString = args.reduce ((memo, val) -> if memo then "#{memo},#{JSON.stringify val}" else JSON.stringify(val)), ""
                else if args?
                    numArgs = 1
                    argString = JSON.stringify args
                else
                    argString = ""
                handleMessage = (evt) ->
                    {data} = evt
                    if data.runId is runId
                        window.removeEventListener 'message', handleMessage
                        if data.action is 'error'
                            # Rebuild the error object.
                            err = new Error(data.error.message)
                            err.stack = data.error.stack
                            err.name = data.error.name
                            reject err
                        else if data.action is 'done'
                            resolve data.result
                window.addEventListener 'message', handleMessage

                # If there is an extra argument defined on the function vs what is passed,
                # then we assume its the place for the done callback and we treat this as
                # an asychronous call.
                isAsync = fn.length is (numArgs + 1)
                appendExecutingScriptTag """
                    try {
                        var isAsync = #{isAsync};
                        var _done = function(result, e) {
                            if(typeof e !== "undefined" && e !== null) {
                                parent.postMessage({ action: "error", error: { message: e.message, stack: e.stack, name: e.name }, runId: "#{runId}" }, '*');
                            }
                            else {
                                parent.postMessage({ action: "done", result: result, runId: "#{runId}" }, '*');
                            }
                        };
                        // Try catching errors that occur in async functions.
                        window.addEventListener('error', function (evt) {
                            var errObj = evt.error ? evt.error : { name: "Error", stack: evt.filename + ":" + evt.lineno + ":" + evt.colno, message: evt.message }
                            _done(null, errObj);
                        });
                        var res = (#{fn.toString()})(#{argString}#{if numArgs > 0 then ', _done' else '_done'});
                        if(!isAsync) {
                            // See if we've got a promise here.
                            if (typeof res !== "undefined" && res !== null && typeof res.then === 'function') {
                                // We've got something that looks promise like.
                                res.then(_done, function(err) {
                                    _done(null, err)
                                });
                            }
                            else {
                                _done(res);
                            }
                        }
                    } catch (e) {
                        _done(null, e)
                    }
                """, @iframe.contentWindow.document.getElementsByTagName('head')[0]

    cleanUp: ->
        window.removeEventListener 'message', handleLogMessage

marocchino.create = (options) ->
    sandbox = new Sandbox()
    sandbox.initialize(options)
    return sandbox

marocchino.remove = (sandbox) ->
    sandbox.cleanUp()
    document.getElementsByTagName('body')[0].removeChild sandbox.iframe

# Export this as a global for use in the browser.
window.marocchino = marocchino
