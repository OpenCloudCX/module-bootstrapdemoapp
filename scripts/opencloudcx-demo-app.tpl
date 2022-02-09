<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.42">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@1.9.2"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@1.9.2">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.93">
    <script>pipeline {
  environment {
    PROJECT_GITHUB = &quot;https://github.com/OpenCloudCX/opencloudcx-demo-app.git&quot;
	  PROJECT_NAME   = &quot;opencloudcx-demo&quot;
	  IMAGE_NAME     = &quot;opencloudcx-demo-app&quot;
	  BUILD_NUMBER   = &quot;1.0&quot;
    REGISTRY       = &quot;index.docker.io&quot;
    REPOSITORY     = &quot;rivasolutionsinc&quot;
    BRANCH         = &quot;main&quot;
  }
  agent {
    kubernetes {
      label &apos;opencloudcx-demo-build&apos;;
      yaml &quot;&quot;&quot;
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: alpine
    workingDir: /home/jenkins
    image: alpine:latest
    imagePullPolicy: Always
    command:
    - /bin/cat
    tty: true
  - name: crane
    workingDir: /home/jenkins
    image: gcr.io/go-containerregistry/crane:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /root/.docker/
  - name: jnlp
    workingDir: /home/jenkins
  - name: kaniko
    workingDir: /home/jenkins
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: riva-dockerhub
          items:
            - key: .dockerconfigjson
              path: config.json
&quot;&quot;&quot;
    }
  }
stages {
    stage(&apos;Checkout&apos;) {
      steps {
        git branch: env.BRANCH, url: env.PROJECT_GITHUB
      }
    }
	stage(&apos;Bake image and create tarball&apos;) {
      environment {
        PATH        = &quot;/busybox:/kaniko:$PATH&quot;
      }
      steps {
        container(name: &apos;kaniko&apos;, shell: &apos;/busybox/sh&apos;) {
            
          sh &apos;&apos;&apos;#!/busybox/sh
            /kaniko/executor --context `pwd` --verbosity debug --no-push --destination $${REGISTRY}/$${REPOSITORY}/$${IMAGE_NAME} --tarPath image.tar
          &apos;&apos;&apos;
        }
      }
    }
    stage(&quot;Grype scans of tarball&quot;) {
      steps { 
        container(name: &apos;alpine&apos;) {      
          sh &apos;apk add bash curl&apos;
          sh &apos;curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin&apos;
          sh &apos;grype image.tar --output table&apos;
        }
      }
    }
    stage(&quot;Push image to repository&quot;) {
      steps {
        container(name: &apos;crane&apos;) {
		  sh &apos;crane push image.tar $${REGISTRY}/$${REPOSITORY}/$${IMAGE_NAME}:$${BUILD_NUMBER}&apos;
        }
      } 
    }
  }
}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>