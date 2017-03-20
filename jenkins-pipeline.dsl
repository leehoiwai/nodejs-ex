node {
stage 'build'
openshiftBuild(buildConfig: 'v2', showBuildLogs: 'true')
stage 'deploy integration'
openshiftVerifyDeployment(deploymentConfig: 'v2')
stage 'test integration'
sh 'curl -i -s http://v2-nodejs-integration.192.168.122.109.xip.io | head -1 |grep 200; exit $?'
stage 'promote to uat'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'v2', destinationAuthToken: '', destinationNamespace: 'nodejs-uat', namespace: 'nodejs-integration', srcStream: 'v2', srcTag: 'latest', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'nodejs-uat', namespace: 'nodejs-uat', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
stage 'deploy uat'
openshiftVerifyDeployment(namespace: 'nodejs-uat', deploymentConfig: 'helloworld')
openshiftScale(namespace: 'nodejs-uat', deploymentConfig: 'helloworld',replicaCount: '2')
stage 'test uat'
sh 'curl -i -s http://helloworld-nodejs-uat.192.168.122.109.xip.io | head -1 |grep 200; exit $?'
stage 'promote to production'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'v2', destinationAuthToken: '', destinationNamespace: 'nodejs-production', namespace: 'nodejs-uat', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'green', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'nodejs-production', namespace: 'nodejs-production', srcStream: 'helloworld', srcTag: 'v2', verbose: 'false')
stage 'deploy production'
openshiftVerifyDeployment(namespace: 'nodejs-production', deploymentConfig: 'green')
openshiftScale(namespace: 'nodejs-production', deploymentConfig: 'green', replicaCount: '2')
}
