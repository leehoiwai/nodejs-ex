node {
stage 'build'
openshiftBuild(buildConfig: 'master', showBuildLogs: 'true')
stage 'deploy integration'
openshiftVerifyDeployment(deploymentConfig: 'master')
stage 'test integration'
sh 'curl -i -s http://master-nodejs-integration.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to uat'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'master', destinationAuthToken: '', destinationNamespace: 'nodejs-uat', namespace: 'nodejs-integration', srcStream: 'master', srcTag: 'latest', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'nodejs-uat', namespace: 'nodejs-uat', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
stage 'deploy uat'
openshiftVerifyDeployment(namespace: 'nodejs-uat', deploymentConfig: 'helloworld')
openshiftScale(namespace: 'nodejs-uat', deploymentConfig: 'helloworld',replicaCount: '2')
stage 'test uat'
sh 'curl -i -s http://helloworld-nodejs-uat.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to production'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'master', destinationAuthToken: '', destinationNamespace: 'nodejs-production', namespace: 'nodejs-uat', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'blue', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'nodejs-production', namespace: 'nodejs-production', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
stage 'deploy production'
openshiftVerifyDeployment(namespace: 'nodejs-production', deploymentConfig: 'blue')
openshiftScale(namespace: 'nodejs-production', deploymentConfig: 'blue', replicaCount: '2')
}
