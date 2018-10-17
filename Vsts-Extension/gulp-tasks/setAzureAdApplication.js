var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    setAzureAdApplication : {
      v1 : 'Set-AzureAdApplication/Set-AzureAdApplicationV1/'
    }
  },
  code : {
    root : '../',
    setAzureAdApplication : {
      v1 : '../scripts/Set-AzureAdApplication/v1/'
    },
    newAzureAdApplication : {
      v1 : '../scripts/New-AzureAdApplication/v1/'
    },
    getAzureAdApplication : {
      v1 : '../scripts/Get-AzureAdApplication/v1/'
    }
  }
}

function cleanSetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.setAzureAdApplication.v1);
  return del([
    paths.extension.setAzureAdApplication.v1 + 'scripts',
    paths.extension.setAzureAdApplication.v1 + psModulesFolderName
  ]);
}

function buildPsModulesSetAzureAdApplication() {
  console.log('Fill the ps modules');
  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v1 + psModulesFolderName));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.setAzureAdApplication.v1 + ' scripts from ' + paths.code.setAzureAdApplication.v1);
  gulp.src(paths.code.setAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v1 + 'scripts'));
  
  console.log('Fill ' + paths.extension.setAzureAdApplication.v1 + ' scripts from ' + paths.code.newAzureAdApplication.v1);
  gulp.src(paths.code.newAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v1 + 'scripts'));

  console.log('Fill ' + paths.extension.setAzureAdApplication.v1 + ' scripts from ' + paths.code.getAzureAdApplication.v1);
  return gulp.src(paths.code.getAzureAdApplication.v1 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v1 + 'scripts'));
}

var taskName = "SetAdApplication";
gulp.task('clean:' + taskName, cleanSetAzureAdApplication);
gulp.task('clean', cleanSetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));