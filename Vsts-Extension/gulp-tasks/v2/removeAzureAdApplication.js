var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    removeAzureAdApplication : {
      v2 : 'Remove-AzureAdApplication/Remove-AzureAdApplicationV2/'
    }
  },
  code : {
    root : '../',
    removeAzureAdApplication : {
      v2 : '../scripts/Remove-AzureAdApplication/v2/'
    }
  }
}

function cleanRemoveAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.removeAzureAdApplication.v2);
  return del([
    paths.extension.removeAzureAdApplication.v2 + 'scripts',
    paths.extension.removeAzureAdApplication.v2 + psModulesFolderName
  ]);
}

function buildPsModulesRemoveAzureAdApplication() {
  console.log('Fill the ps modules');
  gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v2 + psModulesFolderName + "AzureRM"));

  gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v2 + psModulesFolderName + "TelemetryHelper"));
    
  gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v2 + psModulesFolderName + "VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v2 + psModulesFolderName + "VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.removeAzureAdApplication.v2 + ' scripts from ' + paths.code.removeAzureAdApplication.v2);
  return gulp.src(paths.code.removeAzureAdApplication.v2 + '**/*')
    .pipe(gulp.dest(paths.extension.removeAzureAdApplication.v2 + 'scripts'));
}

var taskName = "RemoveAdApplication";
gulp.task('clean:' + taskName, cleanRemoveAzureAdApplication);
gulp.task('clean', cleanRemoveAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesRemoveAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesRemoveAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));