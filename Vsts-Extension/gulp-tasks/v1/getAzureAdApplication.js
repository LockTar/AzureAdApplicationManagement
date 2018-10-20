var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    getAzureAdApplication : {
      v1 : 'Get-AzureAdApplication/Get-AzureAdApplicationV1/'
    }
  },
  code : {
    root : '../',
    getAzureAdApplication : {
      v1 : '../scripts/Get-AzureAdApplication/v1/'
    }
  }
}

function cleanGetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.getAzureAdApplication.v1);
  return del([
    paths.extension.getAzureAdApplication.v1 + 'scripts',
    paths.extension.getAzureAdApplication.v1 + psModulesFolderName
  ]);
}

function buildPsModulesGetAzureAdApplication() {
  console.log('Fill the ps modules');
  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v1 + psModulesFolderName));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.getAzureAdApplication.v1 + ' scripts from ' + paths.code.getAzureAdApplication.v1);
  return gulp.src(paths.code.getAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v1 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanGetAzureAdApplication);
gulp.task('clean', cleanGetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));