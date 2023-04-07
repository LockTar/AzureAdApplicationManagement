var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : '../scripts/Common/v4/',
    setAzureAdApplication : {
      v4 : 'Set-AzureAdApplication/Set-AzureAdApplicationv4/'
    }
  },
  code : {
    root : '../',
    scripts : '../scripts/',
    manageAadApplications : {
      v4 : '../scripts/ManageAadApplications/v4/'
    },
    vstsAzureHelpers : '../scripts/VstsAzureHelpers/'
  }
}

function cleanSetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.setAzureAdApplication.v4);
  return del([
    paths.extension.setAzureAdApplication.v4 + 'scripts',
    paths.extension.setAzureAdApplication.v4 + 'CoreAz.ps1',
    // paths.extension.setAzureAdApplication.v4 + 'Utility.ps1',
    paths.extension.setAzureAdApplication.v4 + psModulesFolderName
  ]);
}

function buildPsModulesSetAzureAdApplication() {
  console.log('Fill the ps modules');
  
  gulp.src(paths.code.scripts + 'CustomAzureDevOpsAzureHelpers/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + psModulesFolderName + "/CustomAzureDevOpsAzureHelpers"));

  gulp.src(paths.extension.psModules + 'TlsHelper_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + psModulesFolderName + "/TlsHelper_"));

  gulp.src(paths.extension.psModules + 'VstsAzureHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + psModulesFolderName + "/VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  gulp.src(paths.code.scripts + 'CoreAz.ps1')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4));
  // gulp.src(paths.code.scripts + 'Utility.ps1')
  //   .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4));
  
  console.log('Fill ' + paths.extension.setAzureAdApplication.v4 + ' scripts from ' + paths.code.manageAadApplications.v4);
  return gulp.src(paths.code.manageAadApplications.v4 + 'ManageAadApplications.psm1')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v4 + 'scripts'));
}

var taskName = "SetAdApplication";
gulp.task('clean:' + taskName, cleanSetAzureAdApplication);
gulp.task('clean', cleanSetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));
