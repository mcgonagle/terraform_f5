node {
   stage('Preparation') { 
      // Get some code from a GitHub repository
      git 'https://github.com/mcgonagle/terraform_f5.git'
   }
   stage('Build') {
      sh '/usr/local/bin/terraform apply'

   }
}
