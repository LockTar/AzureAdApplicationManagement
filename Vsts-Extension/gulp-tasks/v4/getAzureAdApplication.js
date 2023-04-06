var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : '../scripts/Common/v4/',
    getAzureAdApplication : {
      v4 : 'Get-AzureAdApplication/Get-AzureAdApplicationv4/'
    }
  },
  code : {
    root : '../',
    scripts : '../scripts/',
    manageAadApplications : {
      v4 : '../scripts/ManageAadApplications/v4/'
    },
    vstsAzureHelpers : '../scripts/Common/v4/VstsAzureHelpers_/'
  }
}

function cleanGetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.getAzureAdApplication.v4);
  return del([
    paths.extension.getAzureAdApplication.v4 + 'scripts',
    paths.extension.getAzureAdApplication.v4 + 'CoreAz.ps1',
    paths.extension.getAzureAdApplication.v4 + 'Utility.ps1',
    paths.extension.getAzureAdApplication.v4 + psModulesFolderName
  ]);
}

function buildPsModulesGetAzureAdApplication() {
  console.log('Fill the ps modules');
  
  gulp.src(paths.code.scripts + 'CustomAzureDevOpsAzureHelpers/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + psModulesFolderName + "/CustomAzureDevOpsAzureHelpers"));

  gulp.src(paths.extension.psModules + 'TlsHelper_/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + psModulesFolderName + "/TlsHelper_"));

  gulp.src(paths.extension.psModules + 'VstsAzureHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + psModulesFolderName + "/VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  gulp.src(paths.code.scripts + 'CoreAz.ps1')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4));
  gulp.src(paths.code.scripts + 'Utility.ps1')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4));

  console.log('Fill ' + paths.extension.getAzureAdApplication.v4 + ' scripts from ' + paths.code.manageAadApplications.v4);
  return gulp.src(paths.code.manageAadApplications.v4 + 'ManageAadApplications.psm1')
    .pipe(gulp.dest(paths.extension.getAzureAdApplication.v4 + 'scripts'));
}

var taskName = "GetAdApplication";
gulp.task('clean:' + taskName, cleanGetAzureAdApplication);
gulp.task('clean', cleanGetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesGetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));