module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    gitinfo: {}
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
    clean: ["tmp/", "build/", "./*.tar.gz"]
    copy:
      main:
        files: [
          { src: ["src/index.html"], dest: "build/index.html" },
          { expand: true, cwd: "src/content/", src: ['*', '**'], dest: "build/content/"}
        ]
    compress:
      main:
        options:
          mode: 'tgz'
          archive: () -> "ld31-" + grunt.config.get('gitinfo.local.branch.current.shortSHA') + ".tar.gz"
        files: [{src: ['build/**'], dest: './'}]
     

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-gitinfo'

  grunt.registerTask 'default', ['gitinfo', 'coffee', 'requirejs', 'copy']
  grunt.registerTask 'dist', ['default', 'compress']
