module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      glob_to_multiple:
        expand: true,
        flatten: true,
        cwd: 'src/scripts',
        src: ['*.coffee'],
        dest: 'tmp/scripts/',
        ext: '.js'
    requirejs:
      compile:
        options:
          baseUrl: "./tmp/scripts"
          name: "main"
          out: "build/scripts/main.js"
    clean: ["tmp/", "build/"]
    copy:
      main:
        files: [{
          src: ["src/index.html"]
          dest: "build/index.html"
        }]

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'

  grunt.registerTask 'default', ['coffee', 'requirejs', 'copy']
