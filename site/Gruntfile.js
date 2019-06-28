require('dotenv').config({path: '../.env'})

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    exec: {
      build: {
        command: 'gatsby build --prefix-paths',
        stdout: 'inherit'
      },
      serve: {
        command: 'gatsby serve',
        stdout: 'inherit'
      },
      develop: {
        command: 'gatsby develop',
        stdout: 'inherit'
      },
      clean: {
        command: 'rm -Rf ./.cache ./public'
      },
      publish: {
        command: `aws s3 sync ./public s3://${process.env.S3BUCKET}/${process.env.S3PATH} --acl public-read`
      },
      unpublish: {
        command: `aws s3 rm s3://${process.env.S3BUCKET}/${process.env.S3PATH} --recursive`
      }
    }
  });

  grunt.loadNpmTasks('grunt-exec');

  // Default task(s).
  grunt.registerTask('default', ['exec:develop']);
  grunt.registerTask('develop', ['exec:develop']);
  grunt.registerTask('publish', ['exec:clean', 'exec:build', 'exec:publish']);
  grunt.registerTask('republish', ['exec:publish']);
  grunt.registerTask('unpublish', ['exec:unpublish']);
  grunt.registerTask('build', ['exec:build']);
  grunt.registerTask('serve', ['exec:build', 'exec:serve']);
  grunt.registerTask('clean', ['exec:clean']);

};
