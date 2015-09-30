describe 'Marocchino', ->
    describe '#create', ->
        it 'should add an iframe to the current page', ->
            s = marocchino.create()
            expect(document.getElementsByClassName('marocchino-frame')).to.have.length 1
            marocchino.remove s

    describe '#remove', ->
        it 'should remove the iframe from the current test page', ->
            s = marocchino.create()
            marocchino.remove s
            expect(document.getElementsByClassName('marocchino-frame')).to.have.length 0

    describe '#run', ->
        sandbox = null

        beforeEach ->
            sandbox = marocchino.create()

        afterEach ->
            marocchino.remove sandbox

        it 'should return a promise', ->
            expect(sandbox.run -> return true).to.respondTo('then')

        it 'should be able to execute functions inside the iframe', ->
            testValue = "appcues"
            sandbox.run (value) ->
                window._testValue = value
            , testValue
            expect(sandbox.iframe.contentWindow._testValue).to.equal testValue

        it 'should catch exceptions from inside the frame and throw them in the parent context', ->
            expect(sandbox.run -> throw new Error('test error')).to.be.rejectedWith('test error')

        it 'should be able to manipulate the DOM inside the frame'
        it 'should do the right thing with asynchronous functions'
        it 'should keep all variables created within the same sandbox in scope, even if they are declared in different functions'
