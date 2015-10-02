module.exports = (config) ->
    isCI = process.env['WERCKER'] or process.env['CI']

    baseConfig =
        # base path, that will be used to resolve files and exclude
        basePath: '../'

        # list of files / patterns to load in the browser
        files: [
            'lib/marocchino.js'

            { pattern: 'test/blank.html', included: false }
            { pattern: 'test/lib/global.js', included: false }
            { pattern: 'node_modules/es6-promise/dist/es6-promise.js', included: false }
            'test/helper.coffee'
            'test/**/*_test.coffee'
        ]

        # web server port
        port: 8081

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
            'sinon-chai'
            'sinon'
            'chai'
        ]

        plugins: [
            'karma-mocha'
            'karma-coffee-preprocessor'
            'karma-phantomjs-launcher'
            'karma-firefox-launcher'
            'karma-chrome-launcher'
            'karma-chai-as-promised'
            'karma-sinon-chai'
            'karma-sinon'
            'karma-chai'
        ]

        reporters: [
            'dots'
        ]

    if isCI
        # Config for Open Sauce.
        baseConfig.plugins.push 'karma-sauce-launcher'
        baseConfig.sauceLabs =
            testName: 'Marocchino Unit Tests'
        baseConfig.customLaunchers =
            sl_firefox_41:
                base: 'SauceLabs',
                browserName: 'firefox',
                version: '41'
            sl_chrome_45:
                base: 'SauceLabs',
                browserName: 'chrome',
                version: '45'
            sl_safari_81:
                base: 'SauceLabs',
                browserName: 'safari',
                version: '8.1'
                platform: 'OS X 10.11'
            sl_ie_9:
                base: 'SauceLabs'
                browserName: 'internet explorer'
                version: '9.0'
                platform: 'Windows 7'
            sl_ie_10:
                base: 'SauceLabs'
                browserName: 'internet explorer'
                version: '10.0'
                platform: 'Windows 8'
        baseConfig.reporters.push 'saucelabs'
        baseConfig.browsers = Object.keys baseConfig.customLaunchers
        baseConfig.singleRun = true

    config.set baseConfig
