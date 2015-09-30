module.exports = (grunt) ->
    grunt.initConfig
        browserify:
            dist:
                files:
                    'lib/marocchino.js': ['src/**/*.coffee']
                options:
                    transform: ['coffeeify']
        karma:
            unit:
                configFile: 'test/karma.conf.coffee'

    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-karma'

    grunt.registerTask 'default', ['browserify', 'karma']
