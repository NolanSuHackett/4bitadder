pipeline {
  agent any
  options { timestamps() }
  stages {
    stage('Checkout'){ steps { checkout scm } }

    stage('Simulate'){
      steps {
        sh '''
          set -e
          echo "== Compile =="
          iverilog -g2012 -s tb_adder4 -o sim.vvp adder4.sv tb_adder4.sv

          echo "== Run =="
          vvp sim.vvp | tee sim.log

          echo "== Parse =="
          perl parse_results.pl sim.log
        '''
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'sim.log,results.csv,report.html,*.vcd', allowEmptyArchive: true
      junit 'junit.xml'
    }
  }
}
