var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : '../scripts/Common/v3/',
    updateAzureAdApplication : {
      v3 : 'Update-AzureAdApplication/Update-AzureAdApplicationV3/'
    }
  },
  code : {
    root : '../',
    scripts : '../scripts/',
    manageAadApplications : {
      v3 : '../scripts/ManageAadApplications/v3/'
    },
    vstsAzureHelpers : '../scripts/VstsAzureHelpers/'
  }
}

function cleanUpdateAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.updateAzureAdApplication.v3);
  return del([
    paths.extension.updateAzureAdApplication.v3 + 'scripts',
    paths.extension.updateAzureAdApplication.v3 + 'CoreAz.ps1',
    paths.extension.updateAzureAdApplication.v3 + 'Utility.ps1',
    paths.extension.updateAzureAdApplication.v3 + psModulesFolderName
  ]);
}

function buildPsModulesUpdateAzureAdApplication() {
  console.log('Fill the ps modules');
  
  gulp.src(paths.code.scripts + 'CustomAzureDevOpsAzureHelpers/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + psModulesFolderName + "/CustomAzureDevOpsAzureHelpers"));

  gulp.src(paths.extension.psModules + 'TlsHelper_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + psModulesFolderName + "/TlsHelper_"));

  gulp.src(paths.extension.psModules + 'VstsAzureHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + psModulesFolderName + "/VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  gulp.src(paths.code.scripts + 'CoreAz.ps1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3));
  gulp.src(paths.code.scripts + 'Utility.ps1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3));

  console.log('Fill ' + paths.extension.updateAzureAdApplication.v3 + ' scripts from ' + paths.code.manageAadApplications.v3);
  return gulp.src(paths.code.manageAadApplications.v3 + 'ManageAadApplications.psm1')
    .pipe(gulp.dest(paths.extension.updateAzureAdApplication.v3 + 'scripts'));
}

var taskName = "UpdateAdApplication";
gulp.task('clean:' + taskName, cleanUpdateAzureAdApplication);
gulp.task('clean', cleanUpdateAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesUpdateAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesUpdateAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));