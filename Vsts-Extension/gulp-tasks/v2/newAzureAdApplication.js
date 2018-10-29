var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    newAzureAdApplication : {
      v2 : 'New-AzureAdApplication/New-AzureAdApplicationV2/'
    }
  },
  code : {
    root : '../',
    newAzureAdApplication : {
      v2 : '../scripts/New-AzureAdApplication/v2/'
    },
    vstsAzureHelpers : '../scripts/VstsAzureHelpers/'
  }
}

function cleanNewAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.newAzureAdApplication.v2);
  return del([
    paths.extension.newAzureAdApplication.v2 + 'scripts',
    paths.extension.newAzureAdApplication.v2 + psModulesFolderName
  ]);
}

function buildPsModulesNewAzureAdApplication() {
  console.log('Fill the ps modules');
  // gulp.src(paths.extension.psModules + 'AzureRM/**/*')
  //   .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + psModulesFolderName + "/AzureRM"));

  gulp.src(paths.extension.psModules + 'TelemetryHelper/**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + psModulesFolderName + "/TelemetryHelper"));
    
  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + psModulesFolderName + "/VstsTaskSdk"));

  return gulp.src(paths.code.vstsAzureHelpers + '**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + psModulesFolderName + "/VstsAzureHelpers"));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.newAzureAdApplication.v2 + ' scripts from ' + paths.code.newAzureAdApplication.v2);
  return gulp.src(paths.code.newAzureAdApplication.v2 + '**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v2 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanNewAzureAdApplication);
gulp.task('clean', cleanNewAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesNewAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesNewAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));