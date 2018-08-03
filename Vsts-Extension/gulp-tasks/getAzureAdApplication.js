var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : psModulesFolderName + '/',
    getAzureAdApplication : {
      v1 : 'Get-AzureAdApplication/v1/'
    }
  },
  code : {
    root : '../',
    getAzureAdApplication : {
      v1 : '../Get-AzureAdApplication/v1/'
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

function buildCommonAadAppRegistration() {
  console.log('Fill the ps modules');
  return gulp.src(paths.extension.psModules + '**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v1 + psModulesFolderName));
}

function buildScriptFilesAzureADApplication() {
  console.log('Fill ' + paths.extension.getAzureAdApplication.v1 + ' scripts from ' + paths.features.getAzureAdApplication.v1);
  return gulp.src(paths.features.getAzureAdApplication.v1 + 'scripts/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v1 + 'scripts'));
}

gulp.task('clean:AadAppReg', cleanAadAppRegistration);
gulp.task('clean', cleanAadAppRegistration);

gulp.task('build:AadAppReg', gulp.parallel(buildCommonAadAppRegistration, buildFeatureFilesAadAppRegistration));
gulp.task('build', gulp.parallel(buildCommonAadAppRegistration, buildFeatureFilesAadAppRegistration));

gulp.task('reset:AadAppReg', gulp.series('clean:AadAppReg', 'build:AadAppReg'));
gulp.task('reset', gulp.series('clean:AadAppReg', 'build:AadAppReg'));