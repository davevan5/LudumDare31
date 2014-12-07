module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    gitinfo: {}
    coffee:
      options:
        sourceMap: true
      glob_to_multiple:        
        expand: true,
        flatten: true,
        cwd: 'src/scripts',
        src: ['*.coffee'],
        dest: 'build/scripts/',
        ext: '.js'
    clean: ["tmp/", "build/", "./*.tar.gz"]
    copy:
      main:
        files: [
          { expand: true, src: ['src/scripts/**/*.coffee'], dest: 'build' }
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

  grunt.registerTask 'default', ['gitinfo', 'coffee', 'copy']
  grunt.registerTask 'dist', ['default', 'compress']
