marocchino = {}

# Array.reduce polyfill.
# Production steps of ECMA-262, Edition 5, 15.4.4.21
# Reference: http://es5.github.io/#x15.4.4.21
if not Array.prototype.reduce
    Array.prototype.reduce = (callback) ->
        unless @?
            throw new TypeError('Array.prototype.reduce called on null or undefined');
        if typeof callback isnt 'function'
            throw new TypeError(callback + ' is not a function');
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
    constructor: ->
        # Create the iframe.
        @iframe = document.createElement 'iframe'
        @iframe.className = 'marocchino-frame'

    initialize: ->
        # Append the iframe.
        document.body.appendChild @iframe

    run: (fn, args) ->
        script = document.createElement 'script'
        if args instanceof Array
            argString = args.reduce ((memo, val) -> if memo then "#{memo},#{JSON.stringify val}" else JSON.stringify(val)), ""
        else if args?
            argString = JSON.stringify args
        else
            argString = ""
        script.text = "(#{fn.toString()})(#{argString})"
        @iframe.contentDocument.head.appendChild script

marocchino.create = ->
    sandbox = new Sandbox()
    sandbox.initialize()
    return sandbox

marocchino.remove = (sandbox) ->
    document.body.removeChild sandbox.iframe

# Export this as a global for use in the browser.
window.marocchino = marocchino
