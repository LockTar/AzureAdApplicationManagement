var gulp = require('gulp');
var del = require('del');

var psModulesFolderName = 'ps_modules'

var paths = {
  extension : {
    psModules : '../scripts/Common/v3/',
    setAzureAdApplication : {
      v3 : 'Set-AzureAdApplication/Set-AzureAdApplicationV3/'
    }
  },
  code : {
    root : '../',
    scripts : '../scripts/',
    setAzureAdApplication : {
      v3 : '../scripts/Set-AzureAdApplication/v3/'
    },
    newAzureAdApplication : {
      v3 : '../scripts/New-AzureAdApplication/v3/'
    },
    getAzureAdApplication : {
      v3 : '../scripts/Get-AzureAdApplication/v3/'
    },
    vstsAzureHelpers : '../scripts/VstsAzureHelpers/'
  }
}

function cleanSetAzureAdApplication() {
  console.log('Delete everything in ' + paths.extension.setAzureAdApplication.v3);
  return del([
    paths.extension.setAzureAdApplication.v3 + 'scripts',
    paths.extension.setAzureAdApplication.v3 + 'CoreAz.ps1',
    paths.extension.setAzureAdApplication.v3 + 'Utility.ps1',
    paths.extension.setAzureAdApplication.v3 + psModulesFolderName
  ]);
}

function buildPsModulesSetAzureAdApplication() {
  console.log('Fill the ps modules');
  
  gulp.src(paths.code.scripts + 'CustomAzureDevOpsAzureHelpers/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + psModulesFolderName + "/CustomAzureDevOpsAzureHelpers"));

  gulp.src(paths.extension.psModules + 'TlsHelper_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + psModulesFolderName + "/TlsHelper_"));

  gulp.src(paths.extension.psModules + 'VstsAzureHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureHelpers_"));

  gulp.src(paths.extension.psModules + 'VstsAzureRestHelpers_/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + psModulesFolderName + "/VstsAzureRestHelpers_"));

  return gulp.src(paths.extension.psModules + 'VstsTaskSdk/**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + psModulesFolderName + "/VstsTaskSdk"));
}

function buildScriptFilesAzureADApplication() {
  gulp.src(paths.code.scripts + 'CoreAz.ps1')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3));
  gulp.src(paths.code.scripts + 'Utility.ps1')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3));

  console.log('Fill ' + paths.extension.setAzureAdApplication.v3 + ' scripts from ' + paths.code.setAzureAdApplication.v3);
  gulp.src(paths.code.setAzureAdApplication.v3 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + 'scripts'));
  
  console.log('Fill ' + paths.extension.setAzureAdApplication.v3 + ' scripts from ' + paths.code.newAzureAdApplication.v3);
  gulp.src(paths.code.newAzureAdApplication.v3 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + 'scripts'));

  console.log('Fill ' + paths.extension.setAzureAdApplication.v3 + ' scripts from ' + paths.code.getAzureAdApplication.v3);
  return gulp.src(paths.code.getAzureAdApplication.v3 + '**/*')
    .pipe(gulp.dest(paths.extension.setAzureAdApplication.v3 + 'scripts'));
}

var taskName = "SetAdApplication";
gulp.task('clean:' + taskName, cleanSetAzureAdApplication);
gulp.task('clean', cleanSetAzureAdApplication);

gulp.task('build:' + taskName, gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));
gulp.task('build', gulp.parallel(buildPsModulesSetAzureAdApplication, buildScriptFilesAzureADApplication));

gulp.task('reset:' + taskName, gulp.series('clean:' + taskName, 'build:' + taskName));
gulp.task('reset', gulp.series('clean:' + taskName, 'build:' + taskName));