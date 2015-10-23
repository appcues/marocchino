module.exports = (grunt) ->
    grunt.initConfig

        coffeelint:
            app: ['Gruntfile.coffee', 'src/**/*.coffee', 'test/**/*.coffee']
            options:
                indentation:
                    value: 4
                    level: 'error'

                max_line_length:
                    value: 80
                    level: 'ignore'

                no_backticks:
                    level: 'warn'

        browserify:
            dist:
                files:
                    'lib/marocchino.js': ['src/**/*.coffee']
                options:
                    transform: ['coffeeify']
        karma:
            unit:
                configFile: 'test/karma.conf.coffee'

        release:
            options:
                commitMessage: 'Release <%= version %>.'

    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-karma'
    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-release'

    grunt.registerTask 'build', ['coffeelint', 'browserify']

    grunt.registerTask 'default', ['build', 'karma']
