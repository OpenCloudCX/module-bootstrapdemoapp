{
  "keepWaitingPipelines": false,
  "lastModifiedBy": "anonymous",
  "limitConcurrent": true,
  "spelEvaluator": "v4",
  "stages": [
    {
      "continuePipeline": false,
      "failPipeline": true,
      "job": "opencloudcx-demo-app",
      "master": "k8s-jenkins",
      "name": "Jenkins Build",
      "parameters": {},
      "refId": "1",
      "requisiteStageRefIds": [],
      "type": "jenkins"
    },
    {
      "account": "default",
      "app": "${jenkins_job_name}",
      "cloudProvider": "kubernetes",
      "cluster": "deployment opencloudcx-demo-app",
      "completeOtherBranchesThenFail": false,
      "continuePipeline": true,
      "criteria": "oldest",
      "failPipeline": false,
      "kind": "deployment",
      "location": "default",
      "mode": "dynamic",
      "name": "Cleanup",
      "options": {
        "cascading": true
      },
      "refId": "2",
      "requisiteStageRefIds": [
        "1"
      ],
      "type": "deleteManifest"
    },
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "manifests": [
        {
          "apiVersion": "v1",
          "kind": "Service",
          "metadata": {
            "annotations": {
              "artifact.spinnaker.io/location": "opencloudcx-tracer-round",
              "artifact.spinnaker.io/name": "opencloudcx-tracer-round",
              "artifact.spinnaker.io/type": "kubernetes/service",
              "moniker.spinnaker.io/application": "opencloudcx-demo-app",
              "moniker.spinnaker.io/cluster": "service opencloudcx-tracer-round"
            },
            "labels": {
              "app.kubernetes.io/instance": "opencloudcx-tracer-round",
              "app.kubernetes.io/managed-by": "spinnaker",
              "app.kubernetes.io/name": "opencloudcx-tracer-round",
              "app.kubernetes.io/version": "2.0.0",
              "io.portainer.kubernetes.application.stack": "opencloudcx-tracer-round"
            },
            "name": "opencloudcx-demo-app",
            "namespace": "default"
          },
          "spec": {
            "ports": [
              {
                "name": "http",
                "port": 80,
                "protocol": "TCP",
                "targetPort": 80
              }
            ],
            "selector": {
              "app.kubernetes.io/instance": "opencloudcx-tracer-round",
              "app.kubernetes.io/name": "opencloudcx-tracer-round"
            },
            "type": "LoadBalancer"
          }
        }
      ],
      "moniker": {
        "app": "opencloudcx-demo-app"
      },
      "name": "Deploy Load Balancer",
      "refId": "3",
      "requisiteStageRefIds": [
        "2"
      ],
      "skipExpressionEvaluation": false,
      "source": "text",
      "trafficManagement": {
        "enabled": false,
        "options": {
          "enableTraffic": false,
          "services": []
        }
      },
      "type": "deployManifest"
    },
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "manifests": [
        {
          "apiVersion": "apps/v1",
          "kind": "Deployment",
          "metadata": {
            "annotations": {
              "artifact.spinnaker.io/location": "opencloudcx-tracer-round",
              "artifact.spinnaker.io/name": "opencloudcx-tracer-round",
              "artifact.spinnaker.io/type": "kubernetes/deployment",
              "moniker.spinnaker.io/application": "opencloudcx-demo-app",
              "moniker.spinnaker.io/cluster": "deployment opencloudcx-demo-app"
            },
            "labels": {
              "app.kubernetes.io/instance": "opencloudcx-tracer-round",
              "app.kubernetes.io/managed-by": "spinnaker",
              "app.kubernetes.io/name": "opencloudcx-tracer-round",
              "app.kubernetes.io/version": "2.0.0",
              "io.opencloudcx.kubernetes.application.stack": "opencloudcx-tracer-round"
            },
            "name": "opencloudcx-demo-app",
            "namespace": "default"
          },
          "spec": {
            "replicas": 1,
            "selector": {
              "matchLabels": {
                "app.kubernetes.io/instance": "opencloudcx-tracer-round",
                "app.kubernetes.io/name": "opencloudcx-tracer-round"
              }
            },
            "strategy": {
              "type": "Recreate"
            },
            "template": {
              "metadata": {
                "annotations": {
                  "artifact.spinnaker.io/location": "opencloudcx-tracer-round",
                  "artifact.spinnaker.io/name": "opencloudcx-tracer-round",
                  "artifact.spinnaker.io/type": "kubernetes/deployment",
                  "moniker.spinnaker.io/application": "opencloudcx-demo-app",
                  "moniker.spinnaker.io/cluster": "deployment opencloudcx-tracer-round"
                },
                "labels": {
                  "app.kubernetes.io/instance": "opencloudcx-tracer-round",
                  "app.kubernetes.io/managed-by": "spinnaker",
                  "app.kubernetes.io/name": "opencloudcx-tracer-round"
                }
              },
              "spec": {
                "containers": [
                  {
                    "image": "rivasolutionsinc/opencloudcx-bootstrap-app:1.0",
                    "imagePullPolicy": "Always",
                    "livenessProbe": {
                      "httpGet": {
                        "path": "/",
                        "port": 80
                      }
                    },
                    "name": "opencloudcx-demo-app",
                    "ports": [
                      {
                        "containerPort": 80,
                        "name": "http",
                        "protocol": "TCP"
                      }
                    ],
                    "readinessProbe": {
                      "httpGet": {
                        "path": "/",
                        "port": 80
                      }
                    },
                    "resources": {}
                  }
                ]
              }
            }
          }
        }
      ],
      "moniker": {
        "app": "opencloudcx-demo-app"
      },
      "name": "Deploy Application",
      "refId": "4",
      "requisiteStageRefIds": [
        "3"
      ],
      "skipExpressionEvaluation": false,
      "source": "text",
      "trafficManagement": {
        "enabled": false,
        "options": {
          "enableTraffic": false,
          "services": []
        }
      },
      "type": "deployManifest"
    }
  ],
  "triggers": [
    {
      "branch": "main",
      "enabled": true,
      "project": "OpenCloudCX",
      "secret": "${github_hook_pw}",
      "slug": "opencloudcx-demo-app",
      "source": "github",
      "type": "git"
    }
  ],
  "updateTs": "1639081741000"
}