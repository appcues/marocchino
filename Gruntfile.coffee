module.exports = (grunt) ->
    grunt.initConfig
        coffee:
            compile:
                files:
                    'lib/marocchino.js': ['src/*.coffee']
        karma:
            unit:
                configFile: 'test/karma.conf.coffee'

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-karma'

    grunt.registerTask 'default', ['coffee', 'karma']
