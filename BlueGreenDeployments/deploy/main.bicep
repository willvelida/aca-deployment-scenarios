@description('The name of the application')
param applicationName string = uniqueString(resourceGroup().id)

@description('The location to deploy our resources to')
param location string = resourceGroup().location

@description('The name of our Container App environment')
param containerAppEnvName string = 'env-${applicationName}'

@description('The name of the log analytics workspace that will be deployed')
param logAnalyticsWorkspaceName string = 'law-${applicationName}'

@description('The name of the container registry that will be deployed')
param containerRegistryName string = 'acr${applicationName}'

@description('The name of the container app that will be deployed')
param weatherApiName string = 'weather-api'

@description('The name of the container app that will be deployed')
param weatherFrontEndName string = 'weather-frontend'

@description('The docker container image to deploy')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('The minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(30)
param minReplica int = 1

@description('The maximum number of replicas that will be deployed')
@minValue(1)
@maxValue(30)
param maxReplica int = 30

var tags = {
  DeploymentScenario: 'BlueGreen'
  Owner: 'Will Velida'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  tags: tags
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: containerAppEnvName
  location: location
  tags: tags
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource weatherapi 'Microsoft.App/containerApps@2022-10-01' = {
  name: weatherApiName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
      secrets: [
        {
          name: 'containerregistry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          passwordSecretRef: 'containerregistry-password'
          username: containerRegistry.listCredentials().username
        }
      ]
      activeRevisionsMode: 'Multiple'
    }
    template: {
      containers: [
        {
          name: weatherApiName
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource weatherFrontEnd 'Microsoft.App/containerApps@2022-10-01' = {
  name: weatherFrontEndName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
      secrets: [
        {
          name: 'containerregistry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          passwordSecretRef: 'containerregistry-password'
          username: containerRegistry.listCredentials().username
        }
      ]
      activeRevisionsMode: 'Multiple'
    }
    template: {
      containers: [
        {
          name: weatherFrontEndName
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
