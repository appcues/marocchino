describe 'Marocchino', ->
    describe '#create', ->
        it 'should add an iframe to the current page', ->
            s = marocchino.create()
            expect(document.getElementsByClassName('marocchino-frame')).to.have.length 1
            marocchino.remove s

        it 'should load specified resources into the frame through a page specified by src', ->
            s = marocchino.create({
                src: '/base/test/blank.html'
            })
            s.run ->
                return window.MarocchinoTestGlobal
            .then (chaiVersion) ->
                expect(chaiVersion).to.be.ok
                marocchino.remove s

    describe '#remove', ->
        it 'should remove the iframe from the current test page', ->
            s = marocchino.create()
            marocchino.remove s
            expect(document.getElementsByClassName('marocchino-frame')).to.have.length 0

    describe '#run', ->
        sandbox = null

        beforeEach ->
            sandbox = marocchino.create({
                src: '/base/test/blank.html'
            })

        afterEach ->
            marocchino.remove sandbox

        it 'should return a promise', ->
            expect(sandbox.run -> return true).to.respondTo('then')

        it 'should be able to execute functions inside the iframe', ->
            testValue = "appcues"
            sandbox.run((value) ->
                window._testValue = value
            , testValue).then ->
                expect(sandbox.iframe.contentWindow._testValue).to.equal testValue

        it 'should log the iframes console.log messages in the parent frames context', ->
            stub = sinon.stub console, 'log'
            testMsg = 'This is a test.'
            sandbox.run((msg) ->
                console.log(msg)
            , testMsg).then ->
                stub.restore()
                expect(stub).to.have.been.calledWithExactly "(Sandbox Frame): #{testMsg}"

        it 'should catch exceptions from inside the frame and throw them in the parent context', ->
            expect(sandbox.run -> throw new Error('test error')).to.be.rejectedWith('test error')

        it 'should be able to manipulate and make assertions about the DOM inside the frame', ->
            sandbox.run ->
                div = document.createElement 'div'
                div.className = 'foo'
                div.textContent = 'Foo'
                document.body.appendChild div
                expect(document.querySelectorAll('.foo')).to.have.length 1
                expect(document.querySelector('.foo').textContent).to.equal('Foo')
                return

        it 'should return the result of an asynchronous function', ->
            testValue = 'testing!'
            sandbox.run((val, done) ->
                fn = ->
                    done(val)
                window.setTimeout fn, 5
            , testValue).then (res) ->
                expect(res).to.equal testValue

        it 'should handle an error that occurs inside an asynchronous function', ->
            testValue = 'error!'
            expect(sandbox.run((val, done) ->
                fn = ->
                    throw new Error(val)
                window.setTimeout fn, 5
            , testValue)
            ).to.eventually.be.rejectedWith testValue

        it 'should return the resolved value of a function that returns a promise', ->
            testValue = 'resolved!'
            sandbox.run((val) ->
                new Promise (resolve, reject) ->
                    fn = ->
                        resolve(val)
                    window.setTimeout fn, 5
            , testValue).then (res) ->
                expect(res).to.equal testValue

        it 'should reject if the returned promise rejects', ->
            testValue = 'rejected!'
            expect(sandbox.run((val) ->
                new Promise (resolve, reject) ->
                    fn = ->
                        reject(new Error(val))
                    window.setTimeout fn, 5
            , testValue)
            ).to.eventually.be.rejectedWith testValue

        it 'should handle an error that occurs inside the promise function', ->
            testValue = 'error!'
            expect(sandbox.run((val) ->
                new Promise (resolve, reject) ->
                    throw new Error(val)
            , testValue)
            ).to.eventually.be.rejectedWith testValue

        # For some weird reason mocha seems to clean up the last test before the
        # promise resolves or something. Either way, this is causing Chrome to
        # reload the window, according to karma. Placing a pending test at the
        # seems to make this not happen. Hacky but it appears to work. I'll get
        # around to figuring this out eventually. It seems like it's a timing
        # issue because running the test in debug mode seems to make it go away
        # as well.
        it 'should do other things'
