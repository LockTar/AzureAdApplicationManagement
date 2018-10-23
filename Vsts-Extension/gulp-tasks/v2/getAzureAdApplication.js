var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    getAzureAdApplication : {
      v2 : 'Get-AzureAdApplication/Get-AzureAdApplicationV2/'
    }
  },
  code : {
    root : '../',
    getAzureAdApplication : {
      v2 : '../scripts/Get-AzureAdApplication/v2/'
    }
  }
}

function cleanGetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.getAzureAdApplication.v2);
  return del([
    paths.extension.getAzureAdApplication.v2 + 'scripts',
    paths.extension.getAzureAdApplication.v2 + psModulesFolderName
  ]);
}

function buildPsModulesGetAzureAdApplication() {
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
  console.log('Fill ' + paths.extension.getAzureAdApplication.v2 + ' scripts from ' + paths.code.getAzureAdApplication.v2);
  return gulp.src(paths.code.getAzureAdApplication.v2 + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v2 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanGetAzureAdApplication);
gulp.task('clean', cleanGetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));