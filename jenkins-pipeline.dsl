node {
stage 'build'
openshiftBuild(buildConfig: 'v1', showBuildLogs: 'true')
stage 'deploy v1'
openshiftVerifyDeployment(deploymentConfig: 'v1')
}
