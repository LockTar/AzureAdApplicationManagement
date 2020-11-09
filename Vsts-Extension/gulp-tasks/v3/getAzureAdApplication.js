var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    getAzureAdApplication : {
      v3 : 'Get-AzureAdApplication/Get-AzureAdApplicationV3/'
    }
  },
  code : {
    root : '../',
    getAzureAdApplication : {
      v3 : '../scripts/Get-AzureAdApplication/v3/'
    },
    vstsAzureHelpers : '../scripts/VstsAzureHelpers/'
  }
}

function cleanGetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.getAzureAdApplication.v3);
  return del([
    paths.extension.getAzureAdApplication.v3 + 'scripts',
    paths.extension.getAzureAdApplication.v3 + psModulesFolderName
  ]);
}

function buildPsModulesGetAzureAdApplication() {
  console.log('Fill the ps modules');

  gulp.src(paths.extension.psModules + 'TelemetryHelper/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v3 + psModulesFolderName + "/TelemetryHelper"));
    
  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v3 + psModulesFolderName + "/VstsTaskSdk"));

  return gulp.src(paths.code.vstsAzureHelpers + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureHelpers"));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.getAzureAdApplication.v3 + ' scripts from ' + paths.code.getAzureAdApplication.v3);
  return gulp.src(paths.code.getAzureAdApplication.v3 + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v3 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanGetAzureAdApplication);
gulp.task('clean', cleanGetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));