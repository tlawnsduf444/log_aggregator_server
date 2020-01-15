def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']

pipeline {

  agent any

  triggers {
    cron('00 16 * * 0-5')
    bitbucketPush()
  }

  options {
    skipDefaultCheckout(true)
    buildDiscarder(logRotator(numToKeepStr: '30'))
    timestamps()
  }

  environment {
    PATH = "/var/jenkins_home/miniconda3/bin:$PATH"
    REGISTRY = "yujinrobot/log_aggregator_server"
    REGISTRY_CREDENTIAL = 'dockerhub'
  }

  stages {
    stage('Code pull') {
      steps {
        checkout scm
      }
    }
    stage('Build environment') {
      steps {
        sh 'echo Build branch $BRANCH_NAME'
        sh  '''
            conda create --yes -n $BUILD_TAG python
            source activate $BUILD_TAG
            pip install -r requirements.txt
            pip install -r requirements_dev.txt
            '''
      }
    }
    stage('Test environment') {
      steps {
        sh  '''
            source activate $BUILD_TAG
            pip list
            which pip
            which python
            '''
      }
    }
    stage('Static code metrics') {
      steps {
        echo "Style check"
        sh  '''
            source activate $BUILD_TAG
            pylint gocart_registers || true
            '''
      }
    }
    stage('Unit tests') {
      steps {
        sh  '''
            source activate $BUILD_TAG
            python -m pytest --verbose --junit-xml reports/unit_tests.xml
            '''
      }
      post {
        always {
          // Archive unit tests for the future
          junit allowEmptyResults: true, testResults: 'reports/unit_tests.xml'
        }
      }
    }
    stage('Deploy tags') {
      when {
        expression {
          env.TAG_NAME != null
        }
      }
      steps {
        sh 'echo Deploy release version $TAG_NAME'
        script {
          img = docker.build REGISTRY + ":$TAG_NAME"
          docker.withRegistry('', REGISTRY_CREDENTIAL) {
            img.push()
          }
        }
        sh "docker rmi $REGISTRY:$TAG_NAME"
      }
    }
    stage('Deploy master') {
      when {
        expression {
          env.BRANCH_NAME == 'master'
        }
      }
      steps {
        sh 'echo Deploy master branch'
        script {
          img = docker.build REGISTRY + ":master-$BUILD_TIMESTAMP"
          docker.withRegistry('', REGISTRY_CREDENTIAL) {
            img.push()
          }
        }
        sh "docker rmi $REGISTRY:master-$BUILD_TIMESTAMP"
        script {
          img = docker.build REGISTRY + ":latest"
          docker.withRegistry('', REGISTRY_CREDENTIAL) {
            img.push()
          }
        }
        sh "docker rmi $REGISTRY:latest"
      }
    }
  }
  post {
    always {
      sh 'conda remove --yes -n $BUILD_TAG --all'
    }
    failure {
      echo 'failed CI/CD'
      slackSend channel: '#robot_sw_jenkins',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} branch ${BRANCH_NAME}\n More info at: ${env.BUILD_URL}"
    }
    success {
      echo 'success CI/CD'
    }
  }

}
