var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : '../scripts/Common/v4/',
    updateAzureAdApplication : {
      v4 : 'Update-AzureAdApplication/Update-AzureAdApplicationv4/'
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

function cleanUpdateAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.updateAzureAdApplication.v4);
  return del([
    paths.extension.updateAzureAdApplication.v4 + 'scripts',
    paths.extension.updateAzureAdApplication.v4 + 'CoreAz.ps1',
    paths.extension.updateAzureAdApplication.v4 + 'Utility.ps1',
    paths.extension.updateAzureAdApplication.v4 + psModulesFolderName
  ]);
}

function buildPsModulesUpdateAzureAdApplication() {
  console.log('Fill the ps modules');
  
  gulp.src(paths.code.scripts + 'CustomAzureDevOpsAzureHelpers/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + psModulesFolderName + "/CustomAzureDevOpsAzureHelpers"));

  gulp.src(paths.extension.psModules + 'TlsHelper_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + psModulesFolderName + "/TlsHelper_"));

  gulp.src(paths.extension.psModules + 'VstsAzureHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + psModulesFolderName + "/VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  gulp.src(paths.code.scripts + 'CoreAz.ps1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4));
  gulp.src(paths.code.scripts + 'Utility.ps1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4));

  console.log('Fill ' + paths.extension.updateAzureAdApplication.v4 + ' scripts from ' + paths.code.manageAadApplications.v4);
  return gulp.src(paths.code.manageAadApplications.v4 + 'ManageAadApplications.psm1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v4 + 'scripts'));
}

var taskName = "UpdateAdApplication";
gulp.task('clean:' + taskName, cleanUpdateAzureAdApplication);
gulp.task('clean', cleanUpdateAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesUpdateAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesUpdateAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));
