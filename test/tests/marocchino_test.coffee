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

        it 'should do the right thing with asynchronous functions'
        it 'should keep all variables created within the same sandbox in scope, even if they are declared in different functions'
