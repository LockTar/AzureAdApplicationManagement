var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    newAzureAdApplication : {
      v1 : 'New-AzureAdApplication/v1/'
    }
  },
  code : {
    root : '../',
    newAzureAdApplication : {
      v1 : '../scripts/New-AzureAdApplication/v1/'
    }
  }
}

function cleanNewAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.newAzureAdApplication.v1);
  return del([
    paths.extension.newAzureAdApplication.v1 + 'scripts',
    paths.extension.newAzureAdApplication.v1 + psModulesFolderName
  ]);
}

function buildPsModulesNewAzureAdApplication() {
  console.log('Fill the ps modules');
  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v1 + psModulesFolderName));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.newAzureAdApplication.v1 + ' scripts from ' + paths.code.newAzureAdApplication.v1);
  return gulp.src(paths.code.newAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.newAzureAdApplication.v1 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanNewAzureAdApplication);
gulp.task('clean', cleanNewAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesNewAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesNewAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));