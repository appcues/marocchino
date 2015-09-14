module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'lib/marocchino.js': ['src/*.coffee']
    mochaTest:
      options:
        reporter: 'dot'
      src: ['test/*.coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['coffee', 'mochaTest']
