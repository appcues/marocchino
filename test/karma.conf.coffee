module.exports = (config) ->

    baseConfig =
        # base path, that will be used to resolve files and exclude
        basePath: '../'

        # list of files / patterns to load in the browser
        files: [
            'lib/marocchino.js'

            'test/helper.coffee'
            'test/**/*_test.coffee'
        ]

        # web server port
        port: 8080

        # cli runner port
        runnerPort: 9100

        # enable / disable colors in the output (reporters and logs)
        colors: yes

        # level of logging
        # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
        logLevel: config.LOG_INFO

        # enable / disable watching file and executing tests whenever any file changes
        autoWatch: yes

        # Start these browsers, currently available:
        # - Chrome
        # - ChromeCanary
        # - Firefox
        # - Opera
        # - Safari
        # - PhantomJS
        browsers: [
            'PhantomJS'
            'Chrome'
            'Firefox'
        ]

        # Continuous Integration mode
        # if true, it capture browsers, run tests and exit
        singleRun: yes

        # compile coffee scripts
        preprocessors:
            '**/*.coffee': 'coffee'

        frameworks: [
            'mocha'
            'chai-as-promised'
            'chai'
        ]

        plugins: [
            'karma-mocha'
            'karma-coffee-preprocessor'
            'karma-phantomjs-launcher'
            'karma-firefox-launcher'
            'karma-chrome-launcher'
            'karma-chai-as-promised'
            'karma-chai'
        ]

        reporters: [
            'dots'
        ]

    config.set baseConfig
