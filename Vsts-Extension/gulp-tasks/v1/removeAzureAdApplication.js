var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    removeAzureAdApplication : {
      v1 : 'Remove-AzureAdApplication/Remove-AzureAdApplicationV1/'
    }
  },
  code : {
    root : '../',
    removeAzureAdApplication : {
      v1 : '../scripts/Remove-AzureAdApplication/v1/'
    }
  }
}

function cleanRemoveAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.removeAzureAdApplication.v1);
  return del([
    paths.extension.removeAzureAdApplication.v1 + 'scripts',
    paths.extension.removeAzureAdApplication.v1 + psModulesFolderName
  ]);
}

function buildPsModulesRemoveAzureAdApplication() {
  console.log('Fill the ps modules');
  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.removeAzureAdApplication.v1 + psModulesFolderName));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.removeAzureAdApplication.v1 + ' scripts from ' + paths.code.removeAzureAdApplication.v1);
  return gulp.src(paths.code.removeAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.removeAzureAdApplication.v1 + 'scripts'));
}

var taskName = "RemoveAdApplication";
gulp.task('clean:' + taskName, cleanRemoveAzureAdApplication);
gulp.task('clean', cleanRemoveAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesRemoveAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesRemoveAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));